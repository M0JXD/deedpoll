--- Test suites for Deedpoll

--- Deedpoll's tests are tables with these entries
-- @field name Name of the test
-- @field cmd The command to run
-- @field input Array of starting names for files
-- @field expected Array of expected names for files after rename
-- @table deedpoll_test

--- Array of tests
-- @module tests
local M = {}

--[[ TEST TEMPLATE

M[new()] = {
	name = '',
	cmd = 'deedpoll ',
	input = {
		''
	},
	expected = {
		''
	}
}

]]

--- Create and return a new test number entry.
local function new_test_number()
	local count = 0
	return function ()
		count = count + 1
		return count
	end
end

--- Create counter
local new = new_test_number()

-- LuaFormatter off

-- CASE MODE TESTS

M[new()] = {
	name = 'Title case.',
	cmd = 'deedpoll case title',
	input = {
		'title mode test.txt'
	},
	expected = {
		'Title Mode Test.txt'
	}
}

M[new()] = {
	name = 'Lower case on full filenames.',
	cmd = 'deedpoll case lower --name=full',
	input = {
		'TEST.TXT'
	},
	expected = {
		'test.txt'
	}
}

M[new()] = {
	name = 'Upper case on full filenames.',
	cmd = 'deedpoll case upper --name=full',
	input = {
		'test.txt'
	},
	expected = {
		'TEST.TXT'
	}
}

M[new()] = {
	name = 'Remove accents.',
	cmd = 'deedpoll case accent',
	input = {
		'újjáválaszthatóságáról'
	},
	expected = {
		'ujjavalaszthatosagarol'
	}
}

M[new()] = {
	name = 'First character case.',
	cmd = 'deedpoll case first',
	input = {
		'A really Long test Name with No meaningful Case Pattern.txt'
	},
	expected = {
		'A really long test name with no meaningful case pattern.txt'
	}
}

-- DELETE MODE TESTS

-- INSERT MODE TESTS

-- REPLACE MODE TESTS

-- SEARCH MODE TESTS
-- TODD: Search mode is inherently different as it searches within files

-- LuaFormatter on

return M
