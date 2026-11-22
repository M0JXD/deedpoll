-- Copyright 2026 Jamie Drinkell. MIT LICENSE.

--- Terminal Color Library
-- @section ansicolor

local colors = (function()
	-- ansicolors.lua v1.0.4 (2026-08)

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

	--- Color Mode Keys Map.
	local keys = {
		-- reset
		reset = 0, -- misc
		bright = 1, dim = 2, underline = 4, blink = 5, reverse = 7, hidden = 8,
		-- foreground colors
		black = 30, red = 31, green = 32, yellow = 33, blue = 34, magenta = 35, cyan = 36,
		white = 37, -- background colors
		blackbg = 40, redbg = 41, greenbg = 42, yellowbg = 43, bluebg = 44, magentabg = 45,
		cyanbg = 46, whitebg = 47
	}

	local escapeString = string.char(27) .. '[%dm'

	--- Inserts the escape character to the terminal number.
	-- @param terminal number to insert.
	local function escapeNumber(number) return escapeString:format(number) end

	local supported = colorSupport()

	--- Converts key to terminal escape code.
	-- @param str key to substitute with escape code.
	local function escapeKeys(str)
		if not supported then return "" end

		local buffer = {}
		local number
		for word in str:gmatch("%w+") do
			number = keys[word]
			assert(number, "Unknown key: " .. word)
			table.insert(buffer, escapeNumber(number))
		end

		return table.concat(buffer)
	end

	--- Replaces %{key} codes.
	-- @param str String with %{key} entries to apply colors to.
	local function replaceCodes(str)
		str = string.gsub(str, "(%%{(.-)})", function(_, str) return escapeKeys(str) end)
		return str
	end

	--- Apply terminal colors with automatic reset.
	-- @param str String with %{key} to color in.
	local function ansicolors(str)
		str = tostring(str or '')
		return replaceCodes('%{reset}' .. str .. '%{reset}')
	end

	return setmetatable({noReset = replaceCodes},
		{__call = function(_, str) return ansicolors(str) end})
end)()

--- Deedpoll
-- @section deedpoll

require('lfs')

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
	local usage = string.format(colors('%{bright}Usage:%{reset}') .. ' deedpoll %s %s %s %s', mode, parameters, options, files)
	print(usage)
	print('\n' .. mode)
	print(colors '  %{cyan}accent  (a)%{reset}  Removes accents in the file name.')
	print(colors '  %{cyan}delete  (d)%{reset}  Delete characters between specified positions.')
	print(colors '  %{cyan}first   (f)%{reset}  Makes first character uppercase.')
	print(colors '  %{cyan}insert  (i)%{reset}  Insert text into filename.')
	print(colors '  %{cyan}lower   (l)%{reset}  Changes names to lower case.')
	print(colors '  %{cyan}replace (r)%{reset}  Replace text in filename.')
	-- print(colors '  %{cyan}search  (s)%{reset}  Search and replace within file contents.')
	print(colors '  %{cyan}title   (t)%{reset}  Changes names to title case.')
	print(colors '  %{cyan}upper   (u)%{reset}  Changes names to upper case')
	print('\n' .. parameters)
	print(colors '  %{bright}FIND%{reset}  Find text for replace mode. Wildcards ? and * are supported.')
	print(colors '  %{bright}TEXT%{reset}  Text for insert/replace mode. Use %n, %0n, %00n etc. to enumerate.')
	print('\n' .. options)
	print(colors '  %{cyan}-c/--case%{reset}       Enable case sensitivity in replace mode (Non-Windows only).')
	print(colors '  %{cyan}-d/--disallow%{reset}   Listed files are not processed from current directory.')
	print(colors '  %{cyan}-e/--exp%{reset}        Treat replace mode find strings as Lua patterns.')
	print(colors '  %{cyan}-f/--full%{reset}       Use full file list including hidden dotfiles.')
	print(colors '  %{cyan}-h/--help%{reset}       Show help text.')
	print(colors '  %{cyan}-i=/--inc=%{reset}      Increment step for %n patterns in insert/replace mode.')
	print(colors '  %{cyan}-m/--mock%{reset}       Mock run without changing files or confirmation prompt.')
	print(colors '  %{cyan}-n=/--name=%{reset}     [(b)ase/(e)xt/(f)ull] aspect of filename to change.')
	print(colors '  %{cyan}-o/--overwrite%{reset}  Enable overwrite for insert mode.')
	print(colors '  %{cyan}-p=/--pos=%{reset}      Start position for insert/delete.')
	print(colors '  %{cyan}-r/--recurse%{reset}    Recurse search for files. Directories are not be renamed.')
	print(colors '  %{cyan}-s=/--start=%{reset}    Start number for incremented %n patterns.')
	print(colors '  %{cyan}-t=/--to=%{reset}       Position to delete to in delete mode.')
	print(colors '  %{cyan}-v/--version%{reset}    Show version information.')
	print(colors '  %{cyan}-y/--yes%{reset}        Rename files without confirmation step.\n')
	print(colors'%{bright red}NOTES%{reset}')
	print('  ' .. files .. ' will resolve to those in the current directory if omitted.')
	print(colors '  Default behaviour is to operate on basename, with all values set to 1.')
	print(colors '  Unless "mock" or "yes" are enabled, Deedpoll requires confirmation.')
	print(colors '  For pos/to, pre/postfix the letter \'e\' to the value to specify from the end.\n')
	print(colors '%{bright}EXAMPLES%{reset}')
	print(colors '  %{dim}# Change whole filename including the extension to uppercase')
	print(colors '  deedpoll upper -n=full')
	print(colors '  %{dim}# Delete characters from 2nd to 5th letter')
	print(colors '  deedpoll delete --pos=2 --to=5')
	print(colors '  %{dim}# Insert "text {n}" at start, incrementing in 2\'s, no confirmation')
	print(colors '  deedpoll insert "text %n" -i=2 -y')
	print(colors '  %{dim}# Replace "old" with "new" in current directory except for "ignore.txt"')
	print(colors '  deedpoll replace "old" "new" -d ignore.txt')
	os.exit()
	-- LuaFormatter on
end

--- Print version information and exit.
local function pr_version()
	print('Deedpoll 0.1.0  Copyright (C) 2026 Jamie Drinkell')
	os.exit()
end

--- Prints option information for given mode.
local function pr_options(mode, params, opt)
	-- LuaFormatter off
	local dict = {
		d = 'DELETE',
		s = 'SEARCH',
		i = 'INSERT',
		r = 'REPLACE',
		t = 'TITLE CASE',
		l = 'LOWERCASE',
		u = 'UPPERCASE',
		a = 'REMOVE ACCENTS',
		f = 'FIRST CHARACTER UPPERCASE',
		b = 'basenames.',
		e = 'filename extensions.',
		find = colors '%{yellow}FIND:',
		text = colors '%{yellow}TEXT:',
		pos = colors '%{magenta}POSITION:',
		increment = colors '%{magenta}INCREMENT:',
		start = colors '%{magenta}START NUMBER:',
		sensitivity = colors '%{magenta}CASE SENSITIVITY:',
		pattern = colors '%{magenta}PATTERN:',
		from = colors '%{magenta}DELETE FROM:',
		to = colors '%{magenta}DELETE TO:',
		overwrite = colors '%{magenta}OVERWRITE:'
	}
	-- LuaFormatter on

	print(colors('%{green}MODE:%{reset} ' .. dict[mode]))

	-- Mode details
	-- LuaFormatter off
	if mode == 'd' then
		print(string.format('%s %d %s', dict.from, opt.pos, opt.pos_end and '(from the end)' or '\b'))
		print(string.format('%s %d %s', dict.to, opt.to, opt.to_end and '(from the end)' or '\b'))
	elseif mode == 'r' then
		print(string.format('%s "%s"', dict.find, params.find))
		print(string.format('%s "%s"', dict.text, params.text))
		print(string.format('%s %s, %s %s, %s %d, %s %d',
			dict.pattern, opt.pattern and 'ON' or 'OFF',
			dict.sensitivity, opt.sensitive and 'ON' or 'OFF',
			dict.start, opt.start,
			dict.increment, opt.increment
		))
	elseif mode == 'i' then
		print(string.format('%s "%s"', dict.text, params.text))
		print(string.format('%s %d %s, %s %s, %s %d, %s %d',
			dict.pos, opt.pos, opt.pos_end and '(from the end)' or '\b',
			dict.overwrite, opt.overwrite and 'ON' or 'OFF',
			dict.start, opt.start,
			dict.increment, opt.increment
			))
	end
	-- LuaFormatter on

	-- Info warnings
	if opt.no_files then pr_info('No files/paths specified, using current directory.') end
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

--- Closure to enumerate with given increment.
local function enumerate(start, increment)
	local count = start - increment
	local inc = increment
	return function()
		count = count + inc
		return count
	end
end

--- Find and replace %n patterns.
local function enumerate_pattern(str, opt)
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
-- Caller is expected to have trimmed out the ext or basename depending, and done initial setup.
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
		-- TODO: UTF-8 lengths instead of byte lengths
		local length = name:len()
		local from_index = opt.pos - 1
		if opt.pos_end then
			from_index = math.max(length - from_index, 0)
		else
			from_index = math.min(length, from_index)
		end

		local to_index = opt.to - 1
		if opt.to_end then
			to_index = math.max(length - to_index, 0)
		else
			to_index = math.min(length, to_index)
		end

		return name:sub(1, math.min(from_index, to_index)) ..
			name:sub(math.max(from_index, to_index) + 1)
	end,
	-- Insert Renamer
	i = function(name, params, opt)
		local text = enumerate_pattern(params.text, opt)
		local length = name:len()
		local from_index = opt.pos - 1
		if opt.pos_end then
			from_index = math.max(length - from_index, 0)
		else
			from_index = math.min(length, from_index)
		end
		local overwrite = 0
		if opt.overwrite then
			overwrite = text:len()
			if opt.pos_end then from_index = from_index - 1 end
		end
		return name:sub(1, from_index) .. text .. name:sub(from_index + 1 + overwrite)

	end,
	-- Replace Renamer
	r = function(name, params, opt)
		local text = params.text
		if name:find(params.find) then text = enumerate_pattern(params.text, opt) end
		return name:gsub(params.find, text, 1)
	end
}

--- Handles leading paths and base/ext/full behaviour before running rename action.
local function rename_action(name, action, params, opt)
	local prepath = ''
	if name:find('/') then
		prepath = name:match('.*/')
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
local function rename(mode, params, opt, files)
	local action = renamers[mode]
	-- Source - https://stackoverflow.com/a/11402486
	-- Posted by Bart Kiers, modified by community. See post 'Timeline' for change history
	-- Retrieved 2026-11-19, License - CC BY-SA 3.0
	local function case_insensitive_pattern(pattern)
		-- find an optional '%' (group 1) followed by any character (group 2)
		local p = pattern:gsub("(%%?)(.)", function(percent, letter)
			if percent ~= "" or not letter:match("%a") then
				-- if the '%' matched, or `letter` is not a letter, return "as is"
				return percent .. letter
			else
				-- else, return a case-insensitive character class of the matched letter
				return string.format("[%s%s]", letter:lower(), letter:upper())
			end
		end)
		return p
	end

	local function name_clash(names)
		local seen = {}
		for _, value in pairs(names) do
			if seen[value] then return true end
			seen[value] = true
		end
		return false
	end

	if params.find then
		-- Fix replace string if patterns is not enabled
		if not opt.pattern then
			-- Prefix magic characters
			params.find = params.find:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
			-- Convert wildcards to greedy match pattern
			params.find = params.find:gsub("%%%*", ".*")
			params.find = params.find:gsub("%%%?", ".*")
		end

		-- Make patterns case insenstive if need be.
		if not opt.sensitive then params.find = case_insensitive_pattern(params.find) end
	end

	-- Set up enumerator.
	opt._enumerator = enumerate(opt.start, opt.increment)

	local new_names = {}
	for _, file in ipairs(files) do
		local arrow = '%{reset bright yellow} -> %{reset}'
		local new_name = rename_action(file, action, params, opt)
		table.insert(new_names, new_name)
		if new_name == file then arrow = '%{reset bright cyan} -> %{reset}' end

		-- Highlight dirctories or leading dirs
		if lfs.attributes(file, 'mode') == 'directory' then
			file = '%{bright blue}' .. file
			new_name = '%{bright blue}' .. new_name
		elseif file:find('/') then
			local prepath = colors('%{bright blue}' .. file:match('.*/'))
			file = prepath .. '%{reset}' .. file:match('[^/]+$')
			new_name = prepath .. '%{reset}' .. new_name:match('[^/]+$')
		end
		print(colors(file .. arrow .. new_name))
	end

	if name_clash(new_names) then
		print()
		pr_err('Name clash(es) occured! Can\'t rename.')
	end

	local confirm = 'n'
	if not (opt.mock or opt.yes) then
		io.write(colors'\nContinue with operation? (%{underline}Y/n%{reset}): ')
		confirm = io.read(1)
	end

	-- Reset enumerator
	opt._enumerator = enumerate(opt.start, opt.increment)

	if not opt.mock and (opt.yes or confirm:find('[Yy]')) then
		for _, file in ipairs(files) do
			local renamed = rename_action(file, action, params, opt)
			local success, err = os.rename(file, renamed)
			if not success then pr_err(err) end
		end
		print(colors('\n%{green}Files renamed!'))
	else
		print(colors('\n%{red}Files not renamed.'))
	end
end

-- Source - https://stackoverflow.com/a/49405922
-- Posted by user6889435, modified by community. See post 'Timeline' for change history
-- Retrieved 2026-11-22, License - CC BY-SA 3.0
function dirtree(dir, opt)
	assert(dir and dir ~= "", "Please pass directory parameter")
	if string.sub(dir, -1) == "/" then dir = string.sub(dir, 1, -2) end

	local function yieldtree(dir)
		for entry in lfs.dir(dir) do
			if entry ~= "." and entry ~= ".." then
				if entry:sub(1, 1) ~= '.' or opt.full then
					local entry = dir .. "/" .. entry
					local attr = lfs.attributes(entry)
					if attr.mode == "directory" then
						yieldtree(entry)
					else
						coroutine.yield(entry, attr)
					end
				end
			end
		end
	end
	return coroutine.wrap(function() yieldtree(dir) end)
end

--- Get's list of files from remaining CLI arguments, or failing that the current directory.
local function get_files(index, opt)
	local file_list = {}
	local function get_dir()
		if opt.recurse then
			for file, _ in dirtree('.', opt) do table.insert(file_list, file:sub(3)) end
		else
			for file in lfs.dir(lfs.currentdir()) do
				if not opt.full then
					if file:sub(1, 1) ~= '.' then table.insert(file_list, file) end
				else
					if file ~= '.' and file ~= '..' then
						table.insert(file_list, file)
					end
				end
			end
		end
	end

	-- Presume current directory, or get for disallow mode
	if not index or opt.disallow then get_dir() end

	if index then
		for i = index, #arg do
			-- Check it's not an option
			if arg[i]:sub(1, 1) == '-' then
				pr_err('Please list all options before files!')
			end
			-- Check the file actually exists
			if not lfs.attributes(arg[i]) then
				pr_err('File "' .. arg[i] .. '" does not exist!')
			end

			if opt.disallow then
				-- Remove any trailing / on directories
				local filename = arg[i]:gsub('/$', '')
				-- Search the list and remove it
				for k, v in ipairs(file_list) do
					if v == filename then
						table.remove(file_list, k)
						break
					end
				end
			else
				if opt.recurse and lfs.attributes(arg[i], 'mode') == 'directory' then
					for file, _ in dirtree(arg[i], opt) do
						table.insert(file_list, file)
					end

				else
					-- Remove any trailing / on directories
					local filename = arg[i]:gsub('/$', '')
					-- Add it to the list
					table.insert(file_list, filename)
				end
			end
		end
	else
		opt.no_files = true
	end
	table.sort(file_list, function(a, b) return a:lower() < b:lower() end)
	return file_list
end

-- Parses options and filenames after mode parameters are parsed.
local function parse_opts_files(index)
	-- LuaFormatter off
	--- Options table
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
		['-t'] = 'to',

		-- Hidden internal parameters
		no_files = false,
		_enumerator = false
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

				if opt.pos < 1 or opt.to < 1 then
					pr_err('Positions can\'t be less than 1!')
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
	return opt, get_files(first_file, opt)
end

local function parse_cli()
	local index, params = 2, {}
	local mode = arg[1]:sub(1, 1)
	if not mode:find('[adfilrtu]') then pr_err('Invalid mode specified!') end

	-- Insert mode parser
	if mode == 'i' then
		if not arg[2] or arg[2]:sub(1, 1) == '-' then
			pr_err('Please provide text to insert as second argument!')
		end
		params.text = arg[2]
		index = 3
		-- Replace mode parser
	elseif mode == 'r' then
		if not arg[2] or arg[2]:sub(1, 1) == '-' then
			pr_err('Please provide text to find as second argument!')
		end
		params.find = arg[2]
		if not arg[3] or arg[3]:sub(1, 1) == '-' then
			pr_err('Please provide replace text as third argument!')
		end
		params.text = arg[3]
		index = 4
	end

	local opt, files = parse_opts_files(index)
	return mode, params, opt, files
end

-- Check if any arg is a version or help request.
if not arg[1] then pr_help() end
for k, v in ipairs(arg) do
	if v:find('-h', 1, true) then pr_help() end
	if v:find('-v', 1, true) then pr_version() end
end

local mode, params, opt, files = parse_cli()
pr_options(mode, params, opt)
rename(mode, params, opt, files)
