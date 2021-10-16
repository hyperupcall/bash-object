# shellcheck shell=bash
# TODO: add to basalt.toml
set -o pipefail

eval "$(basalt-package-init)"
basalt.package-init
basalt.package-load
basalt.load 'github.com/hyperupcall/bats-common-utils' 'load.bash'

load './util/test_util.sh'

setup() {
	cd "$BATS_TEST_TMPDIR"
}

teardown() {
	cd "$BATS_SUITE_TMPDIR"
}
