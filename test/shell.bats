#!/usr/bin/env bats

load test_helper

@test "shell integration disabled" {
  run pungi shell
  assert_failure "pungi: shell integration not enabled. Run \`pungi init' for instructions."
}

@test "shell integration enabled" {
  eval "$(pungi init -)"
  run pungi shell
  assert_success "pungi: no shell-specific version configured"
}

@test "no shell version" {
  mkdir -p "${PUNGI_TEST_DIR}/myproject"
  cd "${PUNGI_TEST_DIR}/myproject"
  echo "1.2.3" > .python-version
  PUNGI_VERSION="" run pungi-sh-shell
  assert_failure "pungi: no shell-specific version configured"
}

@test "shell version" {
  PUNGI_SHELL=bash PUNGI_VERSION="1.2.3" run pungi-sh-shell
  assert_success 'echo "$PUNGI_VERSION"'
}

@test "shell version (fish)" {
  PUNGI_SHELL=fish PUNGI_VERSION="1.2.3" run pungi-sh-shell
  assert_success 'echo "$PUNGI_VERSION"'
}

@test "shell revert" {
  PUNGI_SHELL=bash run pungi-sh-shell -
  assert_success
  assert_line 0 'if [ -n "${PUNGI_VERSION_OLD+x}" ]; then'
}

@test "shell revert (fish)" {
  PUNGI_SHELL=fish run pungi-sh-shell -
  assert_success
  assert_line 0 'if set -q PUNGI_VERSION_OLD'
}

@test "shell unset" {
  PUNGI_SHELL=bash run pungi-sh-shell --unset
  assert_success
  assert_output <<OUT
PUNGI_VERSION_OLD="\${PUNGI_VERSION-}"
unset PUNGI_VERSION
OUT
}

@test "shell unset (fish)" {
  PUNGI_SHELL=fish run pungi-sh-shell --unset
  assert_success
  assert_output <<OUT
set -gu PUNGI_VERSION_OLD "\$PUNGI_VERSION"
set -e PUNGI_VERSION
OUT
}

@test "shell change invalid version" {
  run pungi-sh-shell 1.2.3
  assert_failure
  assert_output <<SH
pungi: version \`1.2.3' not installed
false
SH
}

@test "shell change version" {
  mkdir -p "${PUNGI_ROOT}/versions/1.2.3"
  PUNGI_SHELL=bash run pungi-sh-shell 1.2.3
  assert_success
  assert_output <<OUT
PUNGI_VERSION_OLD="\${PUNGI_VERSION-}"
export PUNGI_VERSION="1.2.3"
OUT
}

@test "shell change version (fish)" {
  mkdir -p "${PUNGI_ROOT}/versions/1.2.3"
  PUNGI_SHELL=fish run pungi-sh-shell 1.2.3
  assert_success
  assert_output <<OUT
set -gu PUNGI_VERSION_OLD "\$PUNGI_VERSION"
set -gx PUNGI_VERSION "1.2.3"
OUT
}
