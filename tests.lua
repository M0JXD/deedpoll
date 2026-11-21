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
-- Deedpoll's tests are defined with tables.
-- @param test Table of test details.
-- @param test.name Name of the test.
-- @param test.cmd The command to run.
-- @param test.files[OPT] Filenames that should be appended to the command.
-- @param test.input Array of starting names for files.
-- @param test.expected Array of expected names for files after rename.
local function test(test)
	M[test_counter()] = test
end

--- Tests
-- @section tests

-- LuaFormatter off

-- CASE MODE TESTS

test{
	name = 'Remove accents.',
	cmd = 'deedpoll accent',
	input = {
		'újjáválaszthatóságáról'
	},
	expected = {
		'ujjavalaszthatosagarol'
	}
}

test{
	name = 'First character case.',
	cmd = 'deedpoll first',
	input = {
		'the FIRST character tEST.txt'
	},
	expected = {
		'The first character test.txt'
	}
}

test{
	name = 'Lower case on full filenames.',
	cmd = 'deedpoll lower --name=full',
	input = {
		'TEST.TXT'
	},
	expected = {
		'test.txt'
	}
}

test{
	name = 'Title case.',
	cmd = 'deedpoll title',
	input = {
		'title mode test.txt'
	},
	expected = {
		'Title Mode Test.txt'
	}
}

test{
	name = 'Upper case on full filenames.',
	cmd = 'deedpoll upper --name=full',
	input = {
		'test.txt'
	},
	expected = {
		'TEST.TXT'
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
	name = 'Insert with overwrite.',
	cmd = 'deedpoll insert "TEXT" --overwrite',
	input = {
		'testing_file.txt'
	},
	expected = {
		'TEXTing_file.txt'
	}
}

test{
	name = 'Insert with overwrite from end.',
	cmd = 'deedpoll insert "TEXT" --overwrite --pos=4e',
	input = {
		'testing_file.txt'
	},
	expected = {
		'testing_TEXT.txt'
	}
}

test{
	name = 'Insert enumerated values.',
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

test{
	name = 'Insert reverse enumerated with leading zeros and large increment.',
	cmd = 'deedpoll insert "%00n - " --start=100 --increment=-20',
	input = {
		'a.txt',
		'b.txt',
		'c.txt',
		'd.txt',
		'e.txt',
		'f.txt'
	},
	expected = {
		'100 - a.txt',
		'080 - b.txt',
		'060 - c.txt',
		'040 - d.txt',
		'020 - e.txt',
		'000 - f.txt'
	}
}

-- REPLACE MODE TESTS

test{
	name = 'Replace using Lua pattern.',
	cmd = 'deedpoll replace "%a%d%s%u%l" "ABC" --exp',
	input = {
		'a1 Ul'
	},
	expected = {
		'ABC'
	}
}

-- MISC

test{
	name = 'Extension only.',
	cmd = 'deedpoll lower --name=ext',
	input = {
		'TEST.TXT'
	},
	expected = {
		'TEST.txt'
	}
}

test{
	name = 'Hidden files.',
	cmd = 'deedpoll upper --hidden',
	input = {
		'.testname'
	},
	expected = {
		'.TESTNAME'
	}
}

test{
	name = 'Specified hidden files without --hidden.',
	cmd = 'deedpoll upper',
	files = {
		'.testname'
	},
	input = {
		'.testname'
	},
	expected = {
		'.TESTNAME'
	}
}

test{
	name = 'Disallow mode.',
	cmd = 'deedpoll upper --disallow',
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
	name = 'Mock mode.',
	cmd = 'deedpoll upper --mock',
	input = {
		'lowercase.txt'
	},
	expected = {
		'lowercase.txt'
	}
}

-- LuaFormatter on

return M
