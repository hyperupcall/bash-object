#!/usr/bin/env bats

load './util/init.sh'

# get
@test "get errors on missing flags" {
	run bobject get-string

	assert_failure
	assert_line -p 'ERROR_ARGUMENTS_INVALID'
	assert_line -p "Must pass either the '--ref' or '--value' flag"
}

@test "get errors on combining mutually exclusive flags" {
	run bobject get-string --value --ref

	assert_failure
	assert_line -p 'ERROR_ARGUMENTS_INVALID'
	assert_line -p "Flags '--ref' and '--value' are mutually exclusive"
}

# set
@test "set errors on missing flags" {
	run bobject set-string

	assert_failure
	assert_line -p 'ERROR_ARGUMENTS_INVALID'
	assert_line -p "Must pass either the '--ref' or '--value' flag"
}

@test "set errors on combining mutually exclusive flags" {
	run bobject set-string --value --ref

	assert_failure
	assert_line -p 'ERROR_ARGUMENTS_INVALID'
	assert_line -p "Flags '--ref' and '--value' are mutually exclusive"
}
