#!/usr/bin/env bats

load './util/init.sh'

@test "error on more than correct 'get' arguments" {
	local subcmds=(get-string get-array get-object)

	for subcmd in "${subcmds[@]}"; do
		declare -A OBJ=()

		run bobject "$subcmd" 'OBJ' '.zulu.yankee' 'invalid'

		assert_failure
		assert_line -p "Incorrect arguments for subcommand '$subcmd'"
	done
}

@test "error on less than correct 'get' arguments" {
	local subcmds=(get-string get-array get-object)

	for subcmd in "${subcmds[@]}"; do
		declare -A OBJ=()

		run bobject "$subcmd" 'invalid'

		assert_failure
		assert_line -p "Incorrect arguments for subcommand '$subcmd'"
	done
}

@test "error on more than correct 'set' arguments" {
	local subcmds=(set-string set-array set-object)

	for subcmd in "${subcmds[@]}"; do
		declare -A OBJ=()

		run bobject "$subcmd" 'OBJ' '.zulu.yankee' 'xray' 'invalid'

		assert_failure
		assert_line -p "Incorrect arguments for subcommand '$subcmd'"
	done
}

@test "error on less than correct 'set' arguments" {
	local subcmds=(set-string set-array set-object)

	for subcmd in "${subcmds[@]}"; do
		declare -A OBJ=()

		run bobject "$subcmd" 'OBJ' '.zulu'

		assert_failure
		assert_line -p "Incorrect arguments for subcommand '$subcmd'"
	done
}

@test "get-string simple parser" {
	declare -A OBJ=()

	bobject set-string 'OBJ' '.zulu.yankee' 'MEOW'
	bobject get-string 'OBJ' '.zulu.yankee'

	assert [ "$REPLY" = 'MEOW' ]
}

@test "get-string advanced parser" {
	declare -A OBJ=()

	bobject set-string 'OBJ' '.["zulu"].["yankee"]' 'MEOW'
	bobject get-string 'OBJ' '.["zulu"].["yankee"]'

	assert [ "$REPLY" = 'MEOW' ]
}

@test "readme code works" {
	declare -A root_object=()
	declare -A zulu_object=([yankee]=)
	declare -A yankee_object=([xray]=)
	declare -A xray_object=([whiskey]=victor [foxtrot]=)
	declare -a foxtrot_array=(omicron pi rho sigma)

	bobject set-object root_object '.zulu' zulu_object
	bobject set-object root_object '.zulu.yankee' yankee_object
	bobject set-object root_object '.zulu.yankee.xray' xray_object
	bobject set-array root_object '.zulu.yankee.xray.foxtrot' foxtrot_array

	bobject get-object root_object '.zulu.yankee.xray'
	assert [ "${REPLY[whiskey]}" = victor ]

	bobject get-string root_object '.zulu.yankee.xray.whiskey'
	assert [ "$REPLY" = victor ]

	bobject get-array root_object '.zulu.yankee.xray.victor'
	assert [ ${#REPLY} -eq 4 ]

	bobject get-string root_object '.["zulu"].["yankee"].["xray"].["victor"].[2]'
	assert [ "$REPLY" = rho ]
}
