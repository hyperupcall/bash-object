# shellcheck shell=bash

# TODO: Error handling
# TODO: print column and 'mode' in error

# @description Convert a user string into an array representing successive
# object / array access
# @exitcode 1 Miscellaneous error
# @exitcode 2 Parsing error
bash_object.filter_parse() {
	local flag_parser_type=

	for arg; do
		case "$arg" in
			-s|--simple)
				flag_parser_type='simple'
				shift
				;;
			-a|--advanced)
				flag_parser_type='advanced'
				shift
				;;
		esac
	done

	local filter="$1"

	declare -ga REPLIES=()

	if [ "$flag_parser_type" = 'simple' ]; then
		if [ "${filter::1}" != . ]; then
			printf '%s\n' "Error: bash-object: Filter must begin with a dot"
			return 2
		fi

		local old_ifs="$IFS"; IFS=.
		for key in $filter; do
			if [ -z "$key" ]; then
				continue
			fi

			REPLIES+=("$key")
		done
		IFS="$old_ifs"
	elif [ "$flag_parser_type" = 'advanced' ]; then
		declare char=
		declare mode='MODE_DEFAULT'
		declare -i PARSER_COLUMN_NUMBER=0

		filter="${filter}."

		# Reply represents an accessor (e.g. 'sub_key')
		local reply=

		while IFS= read -rN1 char; do
			PARSER_COLUMN_NUMBER+=1

			# echo "-- $mode > '$char'" >&3

			case "$mode" in
			MODE_DEFAULT)
				if [ "$char" = . ]; then
					mode='MODE_EXPECTING_BRACKET'
				else
					printf '%s\n' "Error: bash-object: Filter must begin with a dot"
					return 2
				fi
				;;
			MODE_BEFORE_DOT)
				if [ "$char" = . ]; then
					mode='MODE_EXPECTING_BRACKET'
				else
					printf '%s\n' "Error: bash-object: Each part in a filter must be deliminated by a dot"
					return 2
				fi
				;;
			MODE_EXPECTING_BRACKET)
				if [ "$char" = \[ ]; then
					mode='MODE_EXPECTING_OPENING_STRING_OR_NUMBER'
				elif [ "$char" = $'\n' ]; then
					# The newline here is appended by this while loop's here string
					return
				else
					printf '%s\n' "Error: bash-object: A dot MUST be followed by an opening bracket in this mode"
					return 2
				fi
				;;
			MODE_EXPECTING_OPENING_STRING_OR_NUMBER)
				reply=

				if [ "$char" = \" ]; then
					mode='MODE_EXPECTING_STRING'
				else
					case "$char" in
					0|1|2|3|4|5|6|7|8|9)
						reply=$'\x1C'"$char"
						mode='MODE_EXPECTING_READ_NUMBER'
						;;
					*)
						printf '%s\n' "Error: bash-object: A number or opening quote must follow an open bracket"
						return 2
						;;
					esac
				fi
				;;
			MODE_EXPECTING_STRING)
				if [ "$char" = \\ ]; then
					mode='MODE_STRING_ESCAPE_SEQUENCE'
				elif [ "$char" = \" ]; then
					REPLIES+=("$reply")
					mode='MODE_EXPECTING_CLOSING_BRACKET'
				else
					reply+="$char"
				fi
				;;
			MODE_STRING_ESCAPE_SEQUENCE)
				case "$char" in
					\\) reply+=\\ ;;
					\") reply+=\" ;;
					']') reply+=']' ;;
					*)
						printf '%s\n' "Error: bash-object: Escape sequence of '$char' not valid"
						return 2
						;;
				esac
				mode='MODE_EXPECTING_STRING'
				;;
			MODE_EXPECTING_READ_NUMBER)
				if [ "$char" = ']' ]; then
					REPLIES+=("$reply")
					mode='MODE_BEFORE_DOT'
				else
					case "$char" in
					0|1|2|3|4|5|6|7|8|9)
						reply+="$char"
						;;
					*)
						printf '%s\n' "Error: bash-object: Expecting number, found '$char'"
						return 2
						;;
					esac
				fi
				;;
			MODE_EXPECTING_CLOSING_BRACKET)
				if [ "$char" = ']' ]; then
					mode='MODE_BEFORE_DOT'
				else
					printf '%s\n' "Error: bash-object: Expected a closing bracket after the closing quotation mark"
					return 2
				fi
				;;
			esac
		done <<< "$filter"
	else
		printf '%s\n' "bash-object: Must choose simple or advanced; no current default established"
		return 2
	fi
}
