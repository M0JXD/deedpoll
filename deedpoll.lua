-- Copyright 2026 Jamie Drinkell

---------- ANSICOLOR LIBRARY ----------

-- ansicolors.lua v1.0.4 (2026-11)

-- Copyright (c) 2009 Rob Hoelz <rob@hoelzro.net>
-- Copyright (c) 2011 Enrique García Cota <enrique.garcia.cota@gmail.com>
-- Copyright (c) 2026 Jamie Drinkell <jamiedrinkell@gmail.com>
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

--- Detect if color mode would be supported.
local function colorSupport()
	local isWindows = type(package) == 'table' and type(package.config) == 'string' and
		package.config:sub(1, 1) == '\\'
	return isWindows and (os.getenv("ANSICON") or os.getenv('WT_SESSION')) or true
end

--- Color Mode Keys table.
local keys = {
	-- reset
	reset = 0,
	-- misc
	bright = 1, dim = 2, underline = 4, blink = 5, reverse = 7, hidden = 8,
	-- foreground colors
	black = 30, red = 31, green = 32, yellow = 33, blue = 34, magenta = 35, cyan = 36, white = 37,
	-- background colors
	blackbg = 40, redbg = 41, greenbg = 42, yellowbg = 43, bluebg = 44, magentabg = 45, cyanbg = 46,
	whitebg = 47
}

local escapeString = string.char(27) .. '[%dm'
local function escapeNumber(number)
	return escapeString:format(number)
end

local colorsSupported = colorSupport()
local function escapeKeys(str)
	if not colorsSupported then return "" end
	local buffer = {}
	local number
	for word in str:gmatch("%w+") do
		number = keys[word]
		assert(number, "Unknown key: " .. word)
		table.insert(buffer, escapeNumber(number))
	end

	return table.concat(buffer)
end

local function replaceCodes(str)
	str = string.gsub(str, "(%%{(.-)})", function(_, str) return escapeKeys(str) end)
	return str
end

local function colors(str)
	str = tostring(str or '')
	return replaceCodes('%{reset}' .. str .. '%{reset}')
end

---------- DEEDPOLL ----------

local lfs = require('lfs')

--- Error printing utility.
-- Automatically exits with error message when called.
local function pr_err(str)
	print(colors'%{red}ERROR:%{reset} ' .. str)
	os.exit()
end

--- Info printing utility.
local function pr_info(str)
	print(colors'%{blue}INFO:%{reset} ' .. str)
end

--- Print help info and exit.
local function pr_help()
	-- LuaFormatter off
	local mode = colors('%{green}[MODE]')
	local parameters = colors('%{yellow}[PARAMETERS]')
	local options = colors('%{magenta}[OPTIONS]')
	local files = colors('%{blue}[FILES]')
	local usage = string.format(colors('%{bright}Usage:%{reset}') .. ' deedpoll %s %s %s %s\n', mode, parameters, options, files)
	print(usage)
	print(mode)
	print(colors '  %{cyan}case    (c)%{reset}  Changes character cases.')
	print(colors '  %{cyan}delete  (d)%{reset}  Delete characters from a position to another.')
	print(colors '  %{cyan}search  (s)%{reset}  Search and replace within file contents.')
	print(colors '  %{cyan}insert  (i)%{reset}  Insert text.')
	print(colors '  %{cyan}replace (r)%{reset}  Replace text.\n')
	print(parameters)
	print(colors '  %{bright}ACTION%{reset}  Case change to apply in case mode.')
	print(colors '    %{cyan}title   (t)%{reset}  Changes names to title case.')
	print(colors '    %{cyan}lower   (l)%{reset}  Changes names to lower case.')
	print(colors '    %{cyan}upper   (u)%{reset}  Changes names to upper case')
	print(colors '    %{cyan}accents (a)%{reset}  Removes accents in the file name.')
	print(colors '    %{cyan}first   (f)%{reset}  Makes first character uppercase.')
	print(colors '  %{bright}FIND%{reset}  Find text for search/replace. Wildcards ? and * are supported.')
	print(colors '  %{bright}TEXT%{reset}  Text for search/insert/replace. Use %n, %0n, %00n etc. to enumerate.\n')
	print(options)
	print(colors '  %{cyan}-c/--case%{reset}         Enable case sensitivity in replace mode.')
	print(colors '  %{cyan}-d/--disallow%{reset}     Listed files are not processed from current directory.')
	print(colors '  %{cyan}-e/--exp%{reset}          Treat replace mode find strings as Lua patterns.')
	print(colors '  %{cyan}-f/--full%{reset}         Use full file list including hidden dotfiles.')
	print(colors '  %{cyan}-h/--help%{reset}         Show help text.')
	print(colors '  %{cyan}-i=/--increment=%{reset}  Increment step for %n patterns in insert/replace mode.')
	print(colors '  %{cyan}-m/--mock%{reset}         Mock run without changing files or confirmation prompt.')
	print(colors '  %{cyan}-n=/--name=%{reset}       [(b)ase/(e)xt/(f)ull] aspect of filename to change.')
	print(colors '  %{cyan}-o/--overwrite%{reset}    Enable overwrite for insert mode.')
	print(colors '  %{cyan}-p=/--pos=%{reset}        Start position for insert/delete.')
	print(colors '  %{cyan}-r/--recurse%{reset}      Recurse directories for all files.')
	print(colors '  %{cyan}-s=/--start=%{reset}      Start number for incremented %n patterns.')
	print(colors '  %{cyan}-t=/--to=%{reset}         Position to delete to in delete mode.')
	print(colors '  %{cyan}-v/--version%{reset}      Show version information.')
	print(colors '  %{cyan}-y/--yes%{reset}          Rename files without confirmation step.\n')
	print(colors'%{bright red}NOTES%{reset}')
	print('  ' .. files .. ' will resolve to those in the current directory if omitted.')
	print(colors '  Default behaviour is to operate on basename, with all values defaulted to 1.')
	print(colors '  Unless "mock" or "yes" are enabled, Deedpoll requires confirmation.')
	print(colors '  For pos/to, pre/postfix the letter \'e\' to the value to specify from the end.\n')
	print(colors '%{bright}EXAMPLES%{reset}')
	print(colors '  %{dim}# Delete characters from 2nd to 5th letter')
	print(colors '  deedpoll delete --pos=2 --to=5')
	print(colors '  %{dim}# Change whole filename including the extension to uppercase')
	print(colors '  deedpoll case upper -n=full')
	print(colors '  %{dim}# Insert "text {n}" at start, incrementing in 2\'s, no confirmation')
	print(colors '  deedpoll insert "text %n" -i=2 -y')
	os.exit()
	-- LuaFormatter on
end

--- Print version information and exit.
local function pr_version()
	print('Deedpoll 0.0.1  Copyright (C) 2026 Jamie Drinkell')
	os.exit()
end

--- Prints option information for given mode.
local function pr_options(mode, params, opt)
	-- LuaFormatter off
	local dict = {
		c = 'CASE',
		d = 'DELETE',
		s = 'SEARCH',
		i = 'INSERT',
		r = 'REPLACE',
		t = 'Changing names to title case.',
		l = 'Changing names to lowercase.',
		u = 'Changing names to uppercase.',
		a = 'Removing accents from names.',
		f = 'Changing names to first character uppercase.',
		b = 'basenames.',
		e = 'filename extensions.',
		action = colors '%{yellow}ACTION:',
		find = colors '%{yellow}FIND:',
		replace = colors '%{yellow}REPLACE:',
		insert = colors '%{yellow}INSERT:',
		insert_pos = colors '%{magenta}AT:',
		increment = colors '%{magenta}INCREMENT:',
		start = colors '%{magenta}START NUMBER:',
		sensitivity = colors '%{magenta}CASE SENSITIVITY:',
		pattern = colors '%{magenta}PATTERN:',
		from = colors '%{magenta}DELETE FROM:',
		to = colors '%{magenta}DELETE TO:',
		overwrite = colors '%{magenta}OVERWRITE:'
	}
	-- LuaFormatter on

	print(colors('%{bright green}===== ' .. dict[mode] .. ' MODE ====='))

	-- Mode details
	-- LuaFormatter off
	if mode == 'c' then
		print(dict.action .. ' ' .. dict[params.case])
	elseif mode == 'd' then
		print(string.format('%s %d %s', dict.from, opt.pos, opt.pos_end and 'from the end.' or '\b'))
		print(string.format('%s %d %s', dict.to, opt.to, opt.to_end and 'from the end.' or '\b'))
	elseif mode == 's' or mode == 'r' then
		print(string.format('%s "%s"', dict.find, params.find))
		print(string.format('%s "%s"', dict.replace, params.text))
		print(string.format('%s %s, %s %s, %s %d, %s %d',
			dict.pattern, opt.pattern and 'ON' or 'OFF',
			dict.sensitivity, opt.sensitive and 'ON' or 'OFF',
			dict.increment, opt.increment,
			dict.start, opt.start
		))
	elseif mode == 'i' then
		print(string.format('%s "%s"', dict.insert, params.text))
		print(string.format('%s %d %s',
			dict.insert_pos, opt.pos, opt.pos_end and 'from the end.' or '\b'))
		print(string.format('%s %s, %s %d, %s %d',
			dict.overwrite, opt.overwrite and 'ON' or 'OFF',
			dict.increment, opt.increment,
			dict.start, opt.start
		))
	end
	-- LuaFormatter on

	-- Info warnings
	if opt.mock then pr_info('Running in mock mode. No changes will be made.') end
	if opt.disallow then
		pr_info('Running in disallow mode. Listed files are ignored from current directory.')
	end
	if opt.recurse then
		pr_info('Running with recurse mode. Files in subdirectories will be processed.')
	end
	pr_info('Operating on ' .. (opt.name == 'f' and 'full filenames.' or dict[opt.name]))
	if opt.yes then pr_info('Skipping confirmation!') end
	print()
end

--- Closure to enumerate with given increment
local function enumerate(start, increment)
	local count = start - increment
	local inc = increment
	return function()
		count = count + inc
		return count
	end
end

--- Find and replace %n patterns
local function modulo_n(str, opt)
	if str:find('%%0*n') then
		local enumerate_val = opt._enumerator()
		return str:gsub('%%0*n', function(mat)
			if mat:find('0') then
				local leading_zeros = mat:match('0+'):len()
				local no_len = tostring(enumerate_val):len()
				leading_zeros = leading_zeros - no_len + 1
				if leading_zeros < 0 then leading_zeros = 0 end
				return string.rep('0', leading_zeros) .. enumerate_val
			else
				return enumerate_val
			end
		end)
	end
	return str
end

--- Table of renamer functions.
-- Caller is expected to have trimmed out the ext or basename depending.
local renamers = {
	-- Title Case Renamer
	t = function(name, params, opt)
		-- Source - https://stackoverflow.com/a/22548737
		-- Posted by Joe
		-- Retrieved 2026-11-17, License - CC BY-SA 3.0
		function titleCase(first, rest) return first:upper() .. rest:lower() end
		return string.gsub(name, "(%a)([%w_']*)", titleCase)
	end,
	-- Lower Case Renamer
	-- TODO: Handle accented characters
	l = function(name, params, opt) return name:lower() end,
	-- Upper Case Renamer
	-- TODO: Handle accented characters
	u = function(name, params, opt) return name:upper() end,
	-- Accent Remove Renamer
	a = function(name, params, opt)
		-- Source - https://stackoverflow.com/a/56275419
		-- Posted by Gamora
		-- Retrieved 2026-11-17, License - CC BY-SA 4.0
		-- LuaFormatter off
		local accent_map = {
			["À"] = "A", ["Á"] = "A", ["Â"] = "A", ["Ã"] = "A", ["Ä"] = "A", ["Å"] = "A",["Æ"] = "AE",
			["ß"] = "s",
			["Ç"] = "C",
			["Ð"] = "D",
			["È"] = "E", ["É"] = "E", ["Ê"] = "E", ["Ë"] = "E",
			["Ì"] = "I", ["Í"] = "I", ["Î"] = "I", ["Ï"] = "I",
			["Ñ"] = "N",
			["Ò"] = "O", ["Ó"] = "O", ["Ô"] = "O", ["Õ"] = "O", ["Ö"] = "O", ["Ø"] = "O",
			["Þ"] = "P",
			["Ù"] = "U", ["Ú"] = "U", ["Û"] = "U", ["Ü"] = "U",
			["Ý"] = "Y",
			["à"] = "a", ["á"] = "a", ["â"] = "a", ["ã"] = "a", ["ä"] = "a", ["å"] = "a", ["æ"] = "ae",
			["ç"] = "c",
			["è"] = "e", ["é"] = "e", ["ê"] = "e", ["ë"] = "e",
			["ì"] = "i", ["í"] = "i", ["î"] = "i", ["ï"] = "i",
			["ñ"] = "n",
			["ò"] = "o", ["ó"] = "o", ["ô"] = "o", ["õ"] = "o", ["ö"] = "o", ["ø"] = "o", ["ð"] = "eth",
			["ù"] = "u", ["ú"] = "u", ["û"] = "u", ["ü"] = "u",
			["ý"] = "y", ["ÿ"] = "y",
			["þ"] = "p"
		}
		-- LuaFormatter on
		local normalised_string = ''
		normalised_string = name:gsub("[%z\1-\127\194-\244][\128-\191]*", accent_map)
		return normalised_string
	end,
	-- First Character Uppercase Renamer
	-- TODO: Handle accented characters
	f = function(name, params, opt) return name:sub(1, 1):upper() .. name:sub(2):lower() end,
	-- Delete Renamer
	d = function(name, params, opt)
		local index1, index2, index3, index4
		local len = name:len()
		if not opt.pos_end and not opt.to_end then
			index1, index2, index3, index4 = 1, opt.pos - 1, opt.to, -1
		elseif opt.pos_end and not opt.to_end then
			index1, index2 = 1, opt.to - 1
			index3, index4 = -opt.pos + 1, opt.pos <= 1 and 1 or -1
		elseif not opt.pos_end and opt.to_end then
			-- TODO
			index1, index2 = 1, -opt.to - 1
			index3, index4 = opt.pos + 1, opt.pos <= 1 and 1 or -1
		elseif opt.pos_end and opt.to_end then
			-- TODO
			index1, index2, index3, index4 = 1, 2, 3, 4
		end
		name = name:sub(index1, index2) .. name:sub(index3, index4)
		return name
	end,
	-- Insert Renamer
	i = function(name, params, opt)
		local text = modulo_n(params.text, opt)
		if opt.pos_end then
			return name:sub(1, name:len() - opt.pos) .. params.text ..
				name:sub(name:len() - opt.pos + 1)
		else
			return name:sub(1, opt.pos - 1) .. text .. name:sub(opt.pos)
		end

	end,
	-- Replace Renamer
	r = function(name, params, opt) return name:gsub(params.find, params.text, 1) end,
	-- Search Renamer
	s = function(name, params, opt) return name end
}

--- Handles leading paths and base/ext/full behaviour before running rename action.
local function rename_action(name, action, params, opt)
	local prepath = ''
	if name:find('/') then
		prepath = colors(name:match('.*/'))
		name = name:match('[^/]+$')
	end

	if opt.name == 'b' and name:match('%..*') then
		name = action(name:match('[^%.]*'), params, opt) .. name:match('%..*')
	elseif opt.name == 'e' then
		local ext = name:match('%..*') and action(name:match('%..*'), params, opt) or ''
		name = name:match('[^%.]*') .. ext
	elseif opt.name == 'f' or opt.name == 'b' then
		name = action(name, params, opt)
	end
	return prepath .. name
end

--- Run rename action of files with given options and parameters.
local function rename(files, action, params, opt)
	local function name_clash(names)
		local seen = {}
		for _, value in pairs(names) do
			if seen[value] then return true end
			seen[value] = true
		end
		return false
	end

	local new_names = {}
	for _, file in ipairs(files) do
		local color = lfs.attributes(file, 'mode') == 'directory' and '%{bright blue}' or ''
		local arrow = '%{reset bright yellow} -> %{reset}'
		local new_name = rename_action(file, action, params, opt)
		table.insert(new_names, new_name)
		if new_name == file then arrow = '%{reset bright cyan} -> %{reset}' end
		print(colors(color .. file .. arrow .. color .. new_name))
	end

	if name_clash(new_names) then
		print()
		pr_err('Name clash(es) occured! Can\'t rename.')
	end

	local confirm = 'n'
	if not (opt.mock or opt.yes) then
		io.write(colors'\nContinue with operation? %{underline}(Y/n)%{reset}: ')
		confirm = io.read(1)
	end

	if not opt.mock and (opt.yes or confirm:find('[Yy]')) then
		for _, file in ipairs(files) do
			os.rename(file, rename_action(file, action, params, opt))
			print(colors('\n%{cyan}Files renamed!'))
		end
	else
		print(colors('\n%{red}Files not renamed.'))
	end
end

--- Get's list of files from remaining CLI arguments, or failing that the current directory.
local function get_files(index, opt)
	local file_list = {}
	if not index then
		-- Presume current directory
		pr_info('No files/paths specified, using current directory.')
		for file in lfs.dir(lfs.currentdir()) do
			if file:sub(1, 1) ~= '.' then table.insert(file_list, file) end
		end
	else
		for i = index, #arg do
			-- Check it's not an option
			if arg[i]:sub(1, 1) == '-' then
				pr_err('Please list all options before files!')
			end
			-- Check the file actually exists
			if not lfs.attributes(arg[i]) then
				pr_err('File "' .. arg[i] .. '" does not exist!')
			end
			-- Add it to the table (remove any trailing / for directories)
			table.insert(file_list, (arg[i]:gsub('/$', '')))
		end
	end
	table.sort(file_list, function(a, b) return a:lower() < b:lower() end)
	return file_list
end

-- Parses options and filenames after mode parameters are parsed.
local function parse_opts_files(index)
	--- Options table
	-- LuaFormatter off
	local opt = {
		sensitive = false,
		disallow = false,
		full = false,
		pattern = false,
		increment = 1,
		mock = false,
		name = 'b',
		overwrite = false,
		pos = 1,
		pos_end = false,
		recurse = false,
		start = 1,
		to = 1,
		to_end = false,
		yes = false,
		-- Lookup values
		['-c'] = 'sensitive',
		['-d'] = 'disallow',
		['-f'] = 'full',
		['-e'] = 'pattern',
		['-m'] = 'mock',
		['-o'] = 'overwrite',
		['-r'] = 'recurse',
		['-y'] = 'yes',
		['-i'] = 'increment',
		['-n'] = 'name',
		['-p'] = 'pos',
		['-s'] = 'start',
		['-t'] = 'to'
	}
	-- LuaFormatter on

	local first_file
	for i = index, #arg do
		if not arg[i] then break end
		if arg[i]:sub(1, 1) == '-' then
			-- Set boolean options
			if arg[i]:find('%-[cdefmory]') then
				opt[opt[arg[i]:match('%-[cdefmory]')]] = true
			end

			-- Handle "=" options
			if arg[i]:find('%-[inpst]') then
				if not arg[i]:find('=') then
					pr_err("Value options must be of the form -o=value or --opt=value!")
				end
				opt[opt[arg[i]:match('%-[inpst]')]] = arg[i]:match('=.*'):sub(2)

				-- Fix name operation
				opt.name = opt.name:match('[bef]')

				-- Handle 'e' behaviour in pos/to
				if type(opt.pos) == 'string' then
					if opt.pos:find('e') then opt.pos_end = true end
					opt.pos = tonumber(opt.pos:match('%d'))
				end

				if type(opt.to) == 'string' then
					if opt.to:find('e') then opt.to_end = true end
					opt.to = tonumber(opt.to:match('%d'))
				end

				-- Convert number arguments
				if type(opt.increment) == 'string' then
					opt.increment = tonumber(opt.increment)
				end

				if type(opt.start) == 'string' then opt.start = tonumber(opt.start) end

				-- Check and correct errors
				if not opt.name then pr_err('Could not parse "name" argument!') end
				if not opt.pos then pr_err('Could not parse "position" argument!') end
				if not opt.to then pr_err('Could not parse "to" argument!') end
				if not opt.increment then
					pr_err('Could not parse "increment" argument!')
				end
				if not opt.start then pr_err('Could not parse "start" argument!') end

			end
		else
			-- Must be start of file list
			first_file = i
			break
		end
	end

	-- Set up enumerator
	opt._enumerator = enumerate(opt.start, opt.increment)
	return opt, get_files(first_file, opt)
end

--- Table of CLI parameter parsers for each mode.
local parse = {
	-- Case mode parser
	c = function()
		-- Parse arg[2]
		local params = {}
		params.case = arg[2] and arg[2]:sub(1, 1) or 'n'
		if not params.case:find('[tluaf]') then
			pr_err('Please specify a valid case mode parameter as second argument!')
		end
		return 3, params
	end,
	-- Delete mode parser
	d = function() return 2, {} end,
	-- Insert mode parser
	i = function()
		local params = {}
		if not arg[2] or arg[2]:sub(1, 1) == '-' then
			pr_err('Please provide text to insert as second argument!')
		end
		params.text = arg[2]
		return 3, params
	end,
	-- Replace/Search mode parser
	r = function()
		local params = {}
		if not arg[2] or arg[2]:sub(1, 1) == '-' then
			pr_err('Please provide text to find as second argument!')
		end
		params.find = arg[2]
		if not arg[3] or arg[3]:sub(1, 1) == '-' then
			pr_err('Please provide replace text as third argument!')
		end
		params.text = arg[3]
		return 4, params
	end
}

-- Check if any arg is a version or help request
if not arg[1] then pr_help() end
for k, v in ipairs(arg) do
	if v:find('-h', 1, true) then pr_help() end
	if v:find('-v', 1, true) then pr_version() end
end

local mode = arg[1]:sub(1, 1)
if not mode:find('[cidsr]') then pr_err('Invalid mode specified!') end
-- Index is for the next CLI item that needs parsed after parameters are understood
local index, params = parse[mode == 's' and 'r' or mode]()
local action = renamers[mode == 'c' and params.case or mode]
local opt, files = parse_opts_files(index)
pr_options(mode, params, opt)
rename(files, action, params, opt)
