--- Make & Test system for Deedpoll

local lfs = require('lfs')

local isWindows = type(package) == 'table' and type(package.config) == 'string' and
		package.config:sub(1, 1) == '\\'

local install = arg[2] and arg[2] or '/usr/local'

local function generate_test_suite()
	lfs.mkdir('test/dir1/dir space')
	io.open('test/short', 'w+'):write('find'):close()
	io.open('test/test.txt', 'w+'):write('find2'):close()
	io.open('test/test two.txt', 'w+'):write('find3'):close()
	io.open('test/test two three (brackets).txt', 'w+'):write('find4'):close()
	io.open('test/test_underscore.txt', 'w+'):write('find5'):close()
	io.open('test/újjáválaszthatóságáról', 'w+'):write('find6'):close()
	io.open('test/A really Long name with No meaningful Case Pattern.txt', 'w+'):write('find7'):close()
end

if arg[1] == 't' or arg[1] == 'test' then
	print('BEGINNING TESTS...')
	generate_test_suite()
elseif arg[1] == 'i' or arg[1] == 'install' then
	if isWindows then
	else
		print('INSTALLING TO "' .. install .. '"...')
		os.execute(string.format('cp build/deedpoll %s/bin || sudo cp build/deedpoll %s/bin', install, install))
	end
	print('INSTALL DONE')
elseif arg[1] == 'u' or arg[1] == 'uninstall' then
	if isWindows then
	else
		print('UNINSTALLING FROM "' .. install .. '"...')
		os.execute(string.format('rm -f %s/bin/deedpoll || sudo rm -f %s/bin/deedpoll', install, install))
	end
	print('UNINSTALL DONE')
elseif arg[1] == 'c' or arg[1] == 'clean' then
	print('CLEANING...')
	io.flush()
	local clean = isWindows and 'rmdir /S /Q build & rmdir /S /Q test' or 'rm -r build test'
	os.execute(clean)
	print('CLEANING DONE!\n')
elseif arg[1] == 'b' or arg[1] == 'build' or not arg[1] then
	print('BUILDING...')
	lfs.mkdir('build')
	if isWindows then

	else
		-- Presume Lua is installed and add shebang
		os.execute("cp deedpoll.lua build/deedpoll")
		os.execute("echo '#!/usr/bin/env lua' | cat - build/deedpoll > temp && mv temp build/deedpoll")
		os.execute("chmod +x build/deedpoll")
	end
	print('BUILDING DONE')
else
	print('NO OPTION "' .. arg[1] .. '"')
end
