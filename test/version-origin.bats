#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$PUNGI_TEST_DIR"
  cd "$PUNGI_TEST_DIR"
}

@test "reports global file even if it doesn't exist" {
  assert [ ! -e "${PUNGI_ROOT}/version" ]
  run pungi-version-origin
  assert_success "${PUNGI_ROOT}/version"
}

@test "detects global file" {
  mkdir -p "$PUNGI_ROOT"
  touch "${PUNGI_ROOT}/version"
  run pungi-version-origin
  assert_success "${PUNGI_ROOT}/version"
}

@test "detects PUNGI_VERSION" {
  PUNGI_VERSION=1 run pungi-version-origin
  assert_success "PUNGI_VERSION environment variable"
}

@test "detects local file" {
  echo "system" > .python-version
  run pungi-version-origin
  assert_success "${PWD}/.python-version"
}

@test "reports from hook" {
  create_hook version-origin test.bash <<<"PUNGI_VERSION_ORIGIN=plugin"

  PUNGI_VERSION=1 run pungi-version-origin
  assert_success "plugin"
}

@test "carries original IFS within hooks" {
  create_hook version-origin hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
SH

  export PUNGI_VERSION=system
  IFS=$' \t\n' run pungi-version-origin env
  assert_success
  assert_line "HELLO=:hello:ugly:world:again"
}

@test "doesn't inherit PUNGI_VERSION_ORIGIN from environment" {
  PUNGI_VERSION_ORIGIN=ignored run pungi-version-origin
  assert_success "${PUNGI_ROOT}/version"
}
