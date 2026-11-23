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
-- The test implemetation can only create one directory/file at a time, you will need to list nested objects.
-- @param test Table of test details.
-- @param test.name Name of the test.
-- @param test.cmd The command to run.
-- @param test.files[OPT] Filenames or directories that should be appended to the command. Append '/' to signify a directory.
-- @param test.input Array of starting names for files or directories. Append '/' to signify a directory.
-- @param test.expected Array of expected names for files or directories after rename.  Append '/' to signify a directory.
local function test(test)
	M[test_counter()] = test
end

--- Tests
-- @section tests

-- LuaFormatter off

-- CASE CHANGE TESTS

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

test{
	name = 'Delete letters where start is specified from the end.',
	cmd = 'deedpoll delete --pos=5e --to=1 --name=full',
	input= {
		'test_dir/',
		'test_file_1.png',
		'test_file_2',
		'test_file_3'
	},
	expected = {
		'_dir/',
		'.png',
		'le_2',
		'le_3'
	}
}

test{
	name = 'Delete letters where to is specified from the end.',
	cmd = 'deedpoll delete --pos=1 --to=5e --name=full',
	input= {
		'test_dir/',
		'test_file_1.png',
		'test_file_2',
		'test_file_3'
	},
	expected = {
		'_dir/',
		'.png',
		'le_2',
		'le_3'
	}
}

test{
	name = 'Delete letters where both positions are specified from the end.',
	cmd = 'deedpoll delete --pos=3e --to=5e --name=full',
	input= {
		'test_dir/',
		'test_file_1.png',
		'test_file_2',
		'test_file_3'
	},
	expected = {
		'testir/',
		'test_file_1ng',
		'test_fi_2',
		'test_fi_3'
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
	cmd = 'deedpoll insert "TEXT" --pos=1e',
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
	name = 'Replace a basic string.',
	cmd = 'deedpoll replace "ABC" "123"',
	input = {
		'IGNORE ABC IGNORE.txt'
	},
	expected = {
		'IGNORE 123 IGNORE.txt'
	}
}

test{
	name = 'Replace with wildcard.',
	cmd = 'deedpoll replace "*ABC" "123"',
	input = {
		'REPLACE ABC IGNORE.txt'
	},
	expected = {
		'123 IGNORE.txt'
	}
}

test{
	name = 'Replace with case sensitivity (expected fail on Windows).',
	cmd = 'deedpoll replace "*ABC" "123" --case',
	input = {
		'REPLACE ABC IGNORE.txt',
		'REPLACE abc IGNORE.txt'
	},
	expected = {
		'123 IGNORE.txt',
		'REPLACE abc IGNORE.txt'
	}
}

test{
	name = 'Replace with enumeration.',
	cmd = 'deedpoll replace "ignore*ignore" "IGNORE %0n IGNORE" --start=0 --inc=5',
	input = {
		'IGNORE A IGNORE.txt',
		'IGNORE B IGNORE.txt',
		'IGNORE C IGNORE.txt',
		'IGNORE D IGNORE.txt',
		'IGNORE E IGNORE.txt'
	},
	expected = {
		'IGNORE 00 IGNORE.txt',
		'IGNORE 05 IGNORE.txt',
		'IGNORE 10 IGNORE.txt',
		'IGNORE 15 IGNORE.txt',
		'IGNORE 20 IGNORE.txt'
	}
}

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
	name = 'Use full listing with hidden files.',
	cmd = 'deedpoll upper --full --name=full',
	input = {
		'testfile',
		'.testname'
	},
	expected = {
		'TESTFILE',
		'.TESTNAME'
	}
}

test{
	name = 'Act on listed hidden files without `--full`.',
	cmd = 'deedpoll upper --name=full',
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

test{
	name = 'Recurse mode.',
	cmd = 'deedpoll upper --recurse',
	input = {
		'file.txt',
		'file2.txt',
		'top1/',
		'top1/level1/',
		'top1/level1/level2/',
		'top1/level1/level2/file.txt',
		'top1/level1/level2/file2.txt',
		'top2/',
		'top2/file.txt',
		'top2/file2.txt',
		'.hidden/',
		'.hidden/file.txt'
	},
	expected = {
		'FILE.txt',
		'FILE2.txt',
		'top1/level1/level2/FILE.txt',
		'top1/level1/level2/FILE2.txt',
		'top2/FILE.txt',
		'top2/FILE2.txt',
		'.hidden/file.txt'
	}
}

test{
	name = 'Recurse mode with `--full`.',
	cmd = 'deedpoll upper --recurse --full',
	input = {
		'file.txt',
		'file2.txt',
		'top1/',
		'top1/level1/',
		'top1/level1/level2/',
		'top1/level1/level2/file.txt',
		'top1/level1/level2/file2.txt',
		'top2/',
		'top2/file.txt',
		'top2/file2.txt',
		'.hidden/',
		'.hidden/file.txt'
	},
	expected = {
		'FILE.txt',
		'FILE2.txt',
		'top1/level1/level2/FILE.txt',
		'top1/level1/level2/FILE2.txt',
		'top2/FILE.txt',
		'top2/FILE2.txt',
		'.hidden/FILE.txt'
	}
}

test{
	name = 'Recurse mode with provided path.',
	cmd = 'deedpoll upper --recurse',
	files = {
		'top1/'
	},
	input = {
		'file.txt',
		'file2.txt',
		'top1/',
		'top1/level1/',
		'top1/level1/level2/',
		'top1/level1/level2/file.txt',
		'top1/level1/level2/file2.txt',
		'top2/',
		'top2/file.txt',
		'top2/file2.txt'
	},
	expected = {
		'file.txt',
		'file2.txt',
		'top1/level1/level2/FILE.txt',
		'top1/level1/level2/FILE2.txt',
		'top2/file.txt',
		'top2/file2.txt'
	}
}

test{
	name = 'Recurse mode with disallowed path.',
	cmd = 'deedpoll upper --recurse --disallow',
	files = {
		'top1/'
	},
	input = {
		'file.txt',
		'file2.txt',
		'top1/',
		'top1/level1/',
		'top1/level1/level2/',
		'top1/level1/level2/file.txt',
		'top1/level1/level2/file2.txt',
		'top2/',
		'top2/file.txt',
		'top2/file2.txt'
	},
	expected = {
		'FILE.txt',
		'FILE2.txt',
		'top1/level1/level2/file.txt',
		'top1/level1/level2/file2.txt',
		'top2/FILE.txt',
		'top2/FILE2.txt',
	}
}

test{
	name = 'Don\'t rename on name clash.',
	cmd = 'deedpoll replace "*" ""',
	input = {
		'will clash.txt',
		'would also clash.txt',
		'new file to clash',
		'would clash with previous file'
	},
	expected = {
		'will clash.txt',
		'would also clash.txt',
		'new file to clash',
		'would clash with previous file'
	}
}

-- LuaFormatter on

return M
