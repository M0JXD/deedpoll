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

M[1] = {
	name = 'Lower case on full filenames.',
	cmd = 'deedpoll case lower --name=full',
	input = {
		'TEST.TXT'
	},
	expected = {
		'test.txt'
	}


}

M[2] = {
	name = 'Remove accents.',
	cmd = 'deedpoll case accent',
	input = {
		'újjáválaszthatóságáról'
	},
	expected = {
		'ujjavalaszthatosagarol'
	}

}

M[3] = {
	name = 'First character case.',
	cmd = 'deedpoll case first',
	input = {
		'A really Long test Name with No meaningful Case Pattern.txt'
	},
	expected = {
		'A really long test name with no meaningful case pattern.txt'
	}
}

return M
