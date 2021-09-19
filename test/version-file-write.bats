#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$PUNGI_TEST_DIR"
  cd "$PUNGI_TEST_DIR"
}

@test "invocation without 2 arguments prints usage" {
  run pungi-version-file-write
  assert_failure "Usage: pungi version-file-write <file> <version>"
  run pungi-version-file-write "one" ""
  assert_failure
}

@test "setting nonexistent version fails" {
  assert [ ! -e ".python-version" ]
  run pungi-version-file-write ".python-version" "2.7.6"
  assert_failure "pungi: version \`2.7.6' not installed"
  assert [ ! -e ".python-version" ]
}

@test "writes value to arbitrary file" {
  mkdir -p "${PUNGI_ROOT}/versions/2.7.6"
  assert [ ! -e "my-version" ]
  run pungi-version-file-write "${PWD}/my-version" "2.7.6"
  assert_success ""
  assert [ "$(cat my-version)" = "2.7.6" ]
}
