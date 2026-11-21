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

	print(colors'%{bright cyan}===== DEEDPOLL TEST SUITE =====')

	for _, test in ipairs(tests) do
		io.write(colors'%{yellow}TEST: ' .. test.name)

		-- Create temp test directory for this run
		lfs.mkdir('test')
		lfs.chdir('test')

		-- Create test file/dir (s)
		for _, name in ipairs(test.input) do
			if name:find('.*/') then
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
	end
	-- TODD: Planned search mode would be inherently different as it searches within files

elseif arg[1] == 'i' or arg[1] == 'install' then
	io.write('INSTALLING TO "' .. install .. '"...')
	if isWindows then
	else
		local cmd = string.format(
			'cp build/deedpoll %s/bin 2>/dev/null || sudo cp build/deedpoll %s/bin 2>/dev/null',
			install, install)
		run_command(cmd, function() return lfs.attributes(install .. '/bin/deedpoll') end)
	end

elseif arg[1] == 'u' or arg[1] == 'uninstall' then
	io.write('UNINSTALLING FROM "' .. install .. '"... ')
	if isWindows then
	else
		local cmd = string.format(
			'rm -f %s/bin/deedpoll 2>/dev/null || sudo rm -f %s/bin/deedpoll 2>/dev/null', install,
			install)
		run_command(cmd, function()
			return lfs.attributes(install .. '/bin/deedpoll') and false or true
		end)
	end

elseif arg[1] == 'c' or arg[1] == 'clean' then
	io.write('CLEANING... ')
	local clean = isWindows and 'rmdir /S /Q build & rmdir /S /Q test' or
		'rm -r build test > /dev/null 2>&1'
	run_command(clean, function()
		if lfs.attributes('build') or lfs.attributes('test') then return false end
		return true
	end)
elseif arg[1] == 'b' or arg[1] == 'build' or not arg[1] then
	io.write('BUILDING... ')
	lfs.mkdir('build')
	local cmd = ''
	if isWindows then
	else
		cmd = string.format('%s && %s && %s', 'cp deedpoll.lua build/deedpoll',
			'echo \'#!/usr/bin/env lua\' | cat - build/deedpoll > temp && mv temp build/deedpoll',
			'chmod +x build/deedpoll')
	end
	run_command(cmd, function()
		if isWindows then
			return false
		else
			return lfs.attributes('build/deedpoll')
		end
	end)
else
	print('NO OPTION FOR "' .. arg[1] .. '"')
end
