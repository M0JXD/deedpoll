#!/usr/bin/env lua
-- Copyright 2026 Jamie Drinkell
--- Make & Test system for Deedpoll.

local lfs = require('lfs')
local tests = require('tests')
local colors = require('lib.ansicolors')

local isWindows = type(package) == 'table' and type(package.config) == 'string' and
	package.config:sub(1, 1) == '\\'

local posix_install = arg[2] and arg[2] or '/usr/local'

-- Windows build URLs
local luabin52_url =
	'https://sourceforge.net/projects/luabinaries/files/5.2.4/Tools%20Executables/lua-5.2.4_Win32_bin.zip/download'
local lfs52_url =
	'https://github.com/pkulchenko/ZeroBraneStudio/raw/56d8589d43c552e573939a696fee9e6256d75105/bin/clibs52/lfs.dll'

local luabin54_url =
	'https://sourceforge.net/projects/luabinaries/files/5.4.8/Tools%20Executables/lua-5.4.8_Win32_bin.zip/download'
local lfs54_url =
	'https://github.com/pkulchenko/ZeroBraneStudio/raw/refs/heads/master/bin/clibs54/lfs.dll'

--- Run a command with a custom success checker.
-- @param cmd Command to run.
-- @param check Check function to run after command, return truthy on pass.
local function run_command(cmd, check)
	os.execute(cmd)
	if check() then
		io.write(colors' [%{green}SUCCESS%{reset}%{reset}]\n')
	else
		io.write(colors' [%{red}FAIL%{reset}%{reset}]\n')
	end
end

--- Main script starts.
-- @section main

if arg[1] == 't' or arg[1] == 'test' then
	local null_redirect = isWindows and '> nul' or '> /dev/null'
	local delete_dir = isWindows and 'rmdir /s /q ' or 'rm -rf '
	if arg[2] == '-V' or arg[2] == '--verbose' then null_redirect = '' end

	print(colors'%{bright cyan}===== DEEDPOLL TEST SUITE =====')

	for _, test in ipairs(tests) do
		local verbose = (arg[2] == '-V' or arg[2] == '--verbose')
		if verbose then print('> ' .. test.cmd) end
		io.write(colors'%{yellow}TEST: ' .. test.name)
		if not verbose then io.flush() end

		-- Create temp test directory for this run
		lfs.mkdir('test')
		lfs.chdir('test')

		-- Create test file/dir (s)
		for _, name in ipairs(test.input) do
			if name:sub(-1) == '/' then
				lfs.mkdir(name)
			else
				io.open(name, "w"):close()
			end
		end

		-- Run rename operation
		test.cmd = test.cmd .. ' --yes'
		if test.files then
			for _, file in ipairs(test.files) do
				test.cmd = string.format('%s "%s"', test.cmd, file)
			end
		end
		os.execute('lua ../' .. test.cmd:gsub('deedpoll', 'deedpoll.lua') .. null_redirect)
		-- We can nab Lua from our build on Windows
		-- os.execute('..\\build\\windows\\lua52\\lua52.exe ../' ..
		-- 	test.cmd:gsub('deedpoll', 'deedpoll.lua') .. null_redirect)

		-- Check expected file/dir (s) exist
		local pass = colors(' [%{green}PASS%{reset}]\n')
		for _, name in ipairs(test.expected) do
			if not lfs.attributes(name) then pass = colors(' [%{red}FAIL%{reset}]\n') end
		end
		io.write(pass)
		lfs.chdir('..')
		os.execute(delete_dir .. 'test')
		if verbose then print('\n') end
	end
	-- TODD: Planned search mode would be inherently different as it searches within files

elseif arg[1] == 'i' or arg[1] == 'install' then
	if isWindows then
		print(colors('Installing on Windows is not yet supported. [%{red}FAIL%{reset}%{reset}]'))
	else
		io.write('INSTALLING TO "' .. posix_install .. '"...')
		local cmd = string.format(
			'cp build/deedpoll %s/bin 2>/dev/null || sudo cp build/deedpoll %s/bin 2>/dev/null',
			posix_install, posix_install)
		run_command(cmd, function() return lfs.attributes(posix_install .. '/bin/deedpoll') end)
	end

elseif arg[1] == 'u' or arg[1] == 'uninstall' then
	if isWindows then
		print(colors('Installing on Windows is not yet supported. [%{red}FAIL%{reset}%{reset}]'))
	else
		io.write('UNINSTALLING FROM "' .. posix_install .. '"... ')
		local cmd = string.format(
			'rm -f %s/bin/deedpoll 2>/dev/null || sudo rm -f %s/bin/deedpoll 2>/dev/null',
			posix_install, posix_install)
		run_command(cmd, function()
			return lfs.attributes(posix_install .. '/bin/deedpoll') and false or true
		end)
	end

elseif arg[1] == 'c' or arg[1] == 'clean' then
	io.write('CLEANING... ')
	local clean = isWindows and 'rmdir /S /Q build 2>nul & rmdir /S /Q test 2>nul' or
		'rm -r build test > /dev/null 2>&1'
	run_command(clean, function()
		if lfs.attributes('build') or lfs.attributes('test') then return false end
		return true
	end)

elseif arg[1] == 'f' or arg[1] == 'fetch' then
	io.write('FETCHING... ')
	-- Fetch an updated ansicolors
	local cmd =
		'curl -L -s --output-dir lib -O https://raw.githubusercontent.com/M0JXD/ansicolors-ng/refs/heads/master/ansicolors.lua'
	run_command(cmd, function() return lfs.attributes('lib/ansicolors.lua') end)

elseif arg[1] == 'b' or arg[1] == 'build' or not arg[1] then
	io.write('BUILDING... ')
	io.flush()
	lfs.mkdir('build')
	lfs.mkdir('build/windows')

	-- Windows build
	local function build_windows(path, url_bin, url_dll)
		lfs.mkdir(path)
		local bin_zip = url_bin:match('lua%-5.*_Win32_bin%.zip')
		local lua_ver = bin_zip:match('5..')
		lua_ver = lua_ver:sub(1, 1) .. lua_ver:sub(3)

		local zip = isWindows and 'tar -a -c -f' or 'zip -rq'
		local unzip = (isWindows and 'tar -xf ' or 'unzip -o ') .. bin_zip
		unzip = unzip .. (isWindows and '' or ' > /dev/null')

		-- Fetch LuaBinaries and extract
		os.execute(string.format('curl -s -L -J --output-dir %s -O %s', path, url_bin))
		os.execute(string.format('cd %s && %s && cd ../..', path, unzip))
		os.remove(path .. '/' .. bin_zip)
		os.remove(path .. '/luac' .. lua_ver .. '.exe')
		os.remove(path .. '/wlua' .. lua_ver .. '.exe')

		-- Fetch lfs.dll from ZeroBrane Studio
		os.execute(string.format('curl -s -L -J --output-dir %s -O %s', path, url_dll))
		os.execute('cp deedpoll.lua ' .. path .. '/deedpoll.lua')

		-- Create deedpoll.bat to launch
		local file = io.open(path .. '/deedpoll.bat', 'w')
		file:write('@echo off\n.\\lua' .. lua_ver .. '.exe deedpoll.lua %*')
		file:close()

		-- Create .zips for distribution
		lfs.chdir('build/windows')
		os.execute(string.format('%s win32-lua%d.zip %s', zip, lua_ver, 'lua' .. lua_ver))
		lfs.chdir('../..')

	end

	build_windows('build/windows/lua52', luabin52_url, lfs52_url)
	build_windows('build/windows/lua54', luabin54_url, lfs54_url)

	-- *nix build
	-- Add shebang and call it a day
	local source = io.open('deedpoll.lua')
	local file = io.open('build/deedpoll', 'w')
	local src = source:read('*all')
	source:close()
	src = '#!/usr/bin/env lua\n' .. src
	file:write(src)
	file:close()

	local cmd = 'chmod +x build/deedpoll'
	run_command(cmd, function()
		return lfs.attributes('build/deedpoll') and lfs.attributes('build/windows/lua54/lfs.dll')
	end)

else
	print('NO OPTION FOR "' .. arg[1] .. '"')
end
