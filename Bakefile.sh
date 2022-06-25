# shellcheck shell=bash

task.test() {
	bats tests
}

task.gen() {
	for name in ci site; do
		cue export "./.github/workflows/$name.cue" | python -c 'import sys, yaml, json; yaml.safe_dump(json.load(sys.stdin), sys.stdout, default_flow_style=False)' > "./.github/workflows/$name.yaml"
	done
}
