-- Copyright 2026 Jamie Drinkell
--- Suite of tests for Deedpoll.
-- @module tests
local M = {}

--- Utilities
-- @section utilities

--- Test number generating closure.
local function test_number_generator()
	local count = 0
	return function()
		count = count + 1
		return count
	end
end
local test_counter = test_number_generator()

--- Add a new test.
-- Deedpoll's tests are defined with tables
-- @param test Table of test details
-- @param test.name Name of the test
-- @param test.cmd The command to run.
-- @param test.files[OPT] Filenames that should be appended to the command
-- @param test.input Array of starting names for files
-- @param test.expected Array of expected names for files after rename
local function test(test)
	M[test_counter()] = test
end

--- Tests
-- @section tests

-- LuaFormatter off

-- CASE MODE TESTS

test{
	name = 'Title case.',
	cmd = 'deedpoll case title',
	input = {
		'title mode test.txt'
	},
	expected = {
		'Title Mode Test.txt'
	}
}

test{
	name = 'Lower case on full filenames.',
	cmd = 'deedpoll case lower --name=full',
	input = {
		'TEST.TXT'
	},
	expected = {
		'test.txt'
	}
}

test{
	name = 'Upper case on full filenames.',
	cmd = 'deedpoll case upper --name=full',
	input = {
		'test.txt'
	},
	expected = {
		'TEST.TXT'
	}
}

test{
	name = 'Remove accents.',
	cmd = 'deedpoll case accent',
	input = {
		'újjáválaszthatóságáról'
	},
	expected = {
		'ujjavalaszthatosagarol'
	}
}

test{
	name = 'First character case.',
	cmd = 'deedpoll case first',
	input = {
		'the FIRST character tEST.txt'
	},
	expected = {
		'The first character test.txt'
	}
}

-- DELETE MODE TESTS

test{
	name = 'Delete first two letters.',
	cmd = 'deedpoll delete --pos=1 --to=3',
	input= {
		'test.txt'
	},
	expected = {
		'st.txt'
	}
}

-- INSERT MODE TESTS

test{
	name = 'Insert text at start.',
	cmd = 'deedpoll insert "TEXT"',
	input = {
		'test.txt'
	},
	expected = {
		'TEXTtest.txt'
	}
}

test{
	name = 'Insert text at end.',
	cmd = 'deedpoll insert --pos=1e "TEXT"',
	input = {
		'test.txt'
	},
	expected = {
		'testTEXT.txt'
	}
}

test{
	name = 'Enumerate values',
	cmd = 'deedpoll insert "%n - "',
	input = {
		'a.txt',
		'b.txt',
		'c.txt'
	},
	expected = {
		'1 - a.txt',
		'2 - b.txt',
		'3 - c.txt'
	}
}

-- REPLACE MODE TESTS

-- BASE/EXT/FULL TESTS

-- MISC

test{
	name = 'Disallow mode.',
	cmd = 'deedpoll case upper --disallow',
	files = {
		'not me.txt'
	},
	input = {
		'make me upper.txt',
		'not me.txt'
	},
	expected = {
		'MAKE ME UPPER.txt',
		'not me.txt'
	}
}

test{
	name = 'Lua pattern replace.',
	cmd = 'deedpoll replace "%d" "ABC" --exp',
	input = {
		'123'
	},
	expected = {
		'ABC'
	}
}

test{
	name = 'Mock mode.',
	cmd = 'deedpoll case upper --mock',
	input = {
		'lowercase.txt'
	},
	expected = {
		'lowercase.txt'
	}
}

-- LuaFormatter on

return M
