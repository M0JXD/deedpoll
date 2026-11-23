#!/usr/bin/env lua
-- Copyright 2026 Jamie Drinkell
--- Make & Test system for Deedpoll

require('lfs')
local tests = require('tests')
local colors = require('lib.ansicolors')

local isWindows = type(package) == 'table' and type(package.config) == 'string' and
	package.config:sub(1, 1) == '\\'

local install = arg[2] and arg[2] or '/usr/local'

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

--- Main Script Starts
-- @section main

if arg[1] == 't' or arg[1] == 'test' then
	local null_redirect = isWindows and '> nul' or '> /dev/null'
	local delete_dir = isWindows and 'rmdir /s /q ' or 'rm -rf '
	if arg[2] == '-V' or arg[2] == '--verbose' then null_redirect = '' end

	print(colors'%{bright cyan}===== DEEDPOLL TEST SUITE =====')

	for _, test in ipairs(tests) do
		if arg[2] == '-V' or arg[2] == '--verbose' then print('> ' .. test.cmd) end
		io.write(colors'%{yellow}TEST: ' .. test.name)

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

		-- Check expected file/dir (s) exist
		local pass = colors(' [%{green}PASS%{reset}]\n')
		for _, name in ipairs(test.expected) do
			if not lfs.attributes(name) then pass = colors(' [%{red}FAIL%{reset}]\n') end
		end
		io.write(pass)
		lfs.chdir('..')
		os.execute(delete_dir .. 'test')
		if arg[2] == '-V' or arg[2] == '--verbose' then print('\n') end
	end
	-- TODD: Planned search mode would be inherently different as it searches within files

elseif arg[1] == 'i' or arg[1] == 'install' then
	if isWindows then
		print(colors('Installing on Windows is not yet supported. [%{red}FAIL%{reset}%{reset}]'))
	else
		io.write('INSTALLING TO "' .. install .. '"...')
		local cmd = string.format(
			'cp build/deedpoll %s/bin 2>/dev/null || sudo cp build/deedpoll %s/bin 2>/dev/null',
			install, install)
		run_command(cmd, function() return lfs.attributes(install .. '/bin/deedpoll') end)
	end

elseif arg[1] == 'u' or arg[1] == 'uninstall' then
	if isWindows then
		print(colors('Installing on Windows is not yet supported. [%{red}FAIL%{reset}%{reset}]'))
	else
		io.write('UNINSTALLING FROM "' .. install .. '"... ')
		local cmd = string.format(
			'rm -f %s/bin/deedpoll 2>/dev/null || sudo rm -f %s/bin/deedpoll 2>/dev/null', install,
			install)
		run_command(cmd, function()
			return lfs.attributes(install .. '/bin/deedpoll') and false or true
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
elseif arg[1] == 'b' or arg[1] == 'build' or not arg[1] then
	io.write('BUILDING... ')
	lfs.mkdir('build')
	lfs.mkdir('build/windows')

	-- Windows build
	-- Fetch LuaBinaries Lua5.4 and extract
	os.execute('curl -s -L -J --output-dir build/windows -O https://sourceforge.net/projects/luabinaries/files/5.4.8/Tools%20Executables/lua-5.4.8_Win32_bin.zip/download')
	os.execute('cd build/windows && tar -xf lua-5.4.8_Win32_bin.zip && cd ../..')
	os.remove('build/windows/lua-5.4.8_Win32_bin.zip')
	os.remove('build/windows/luac54.exe')
	os.remove('build/windows/wlua54.exe')

	-- Fetch lfs.dll for Lua5.4 from ZeroBrane Studio
	os.execute('curl -s -L -J --output-dir build/windows -O https://github.com/pkulchenko/ZeroBraneStudio/raw/refs/heads/master/bin/clibs54/lfs.dll')
	os.execute('cp deedpoll.lua build/windows/deedpoll.lua')
	-- Create deedpoll.bat to launch
	local file = io.open('build/windows/deedpoll.bat', 'w')
	file:write('@echo off\n.\\lua54.exe deedpoll.lua %*')
	file:close()

	-- *nix build
	-- Add shebang and call it a day
	local source = io.open('deedpoll.lua')
	local file = io.open('build/deedpoll', 'w')
	local src = source:read('a')
	source:close()
	src = '#!/usr/bin/env lua\n' .. src
	file:write(src)
	file:close()

	local cmd = 'chmod +x build/deedpoll'
	run_command(cmd, function() return lfs.attributes('build/deedpoll') and lfs.attributes('build/windows/lfs.dll') end)

else
	print('NO OPTION FOR "' .. arg[1] .. '"')
end
