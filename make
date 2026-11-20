#!/usr/bin/env lua
-- Copyright 2026 Jamie Drinkell
--- Make & Test system for Deedpoll

local lfs = require('lfs')
local tests = require('tests')
local colors = require('lib.ansicolors')

local isWindows = type(package) == 'table' and type(package.config) == 'string' and
	package.config:sub(1, 1) == '\\'

local install = arg[2] and arg[2] or '/usr/local'

local function run_command(cmd)
		if os.execute(cmd) ~= '0' then
			io.write(colors'[%{red}FAIL%{reset}%{reset}]\n')
		else
			io.write(colors'[%{green}DONE%{reset}%{reset}]\n')
		end
end

if arg[1] == 't' or arg[1] == 'test' then
	-- TODD: Search mode is inherently different as it searches within files

	local null_redirect = isWindows and 'nul' or '/dev/null'
	local delete_dir = isWindows and 'rmdir /s /q ' or 'rm -rf '

	print(colors'%{bright cyan}===== DEEDPOLL TEST SUITE =====')
	for _, test in ipairs(tests) do
		io.write(colors'%{yellow}TEST: ' .. test.name)

		-- Create temp test directory for this run
		lfs.mkdir('test')
		lfs.chdir('test')

		-- Create test file(s)
		for _, name in ipairs(test.input) do io.open(name, "w"):close() end

		-- Run rename operation
		os.execute('lua ../' .. test.cmd:gsub('deedpoll', 'deedpoll.lua') .. ' --yes > ' ..
			null_redirect)

		-- Check expected filename(s) exist
		for _, name in ipairs(test.expected) do
			if not lfs.attributes(name) then
				io.write(colors' [%{red}FAIL%{reset}]\n')
			else
				io.write(colors' [%{green}PASS%{reset}]\n')
			end
		end
		lfs.chdir('..')
		os.execute(delete_dir .. 'test')
	end

elseif arg[1] == 'i' or arg[1] == 'install' then
	if isWindows then
	else
		local cmd = string.format('cp build/deedpoll %s/bin || sudo cp build/deedpoll %s/bin',
			install, install)
		io.write('INSTALLING TO "' .. install .. '"... ')
		run_command(cmd)
	end

elseif arg[1] == 'u' or arg[1] == 'uninstall' then
	if isWindows then
	else
		local cmd = string.format('rm -f %s/bin/deedpoll || sudo rm -f %s/bin/deedpoll', install,
			install)
		io.write('UNINSTALLING FROM "' .. install .. '"... ')
		run_command(cmd)
	end

elseif arg[1] == 'c' or arg[1] == 'clean' then
	io.write('CLEANING... ')
	io.flush()
	local clean = isWindows and 'rmdir /S /Q build & rmdir /S /Q test' or 'rm -r build test > /dev/null 2>&1'
	os.execute(clean)
	if lfs.attributes('build') or lfs.attributes('test') then
		io.write(colors'[%{red}FAIL%{reset}%{reset}]\n')
	else
		io.write(colors'[%{green}DONE%{reset}%{reset}]\n')
	end

elseif arg[1] == 'b' or arg[1] == 'build' or not arg[1] then
	io.write('BUILDING... ')
	lfs.mkdir('build')
	if isWindows then

	else
		-- Presume Lua is installed and add shebang
		os.execute("cp deedpoll.lua build/deedpoll")
		os.execute(
			"echo '#!/usr/bin/env lua' | cat - build/deedpoll > temp && mv temp build/deedpoll")
		os.execute("chmod +x build/deedpoll")
	end
	io.write(colors'[%{green}DONE%{reset}]\n')
else
	print('NO OPTION "' .. arg[1] .. '"')
end
