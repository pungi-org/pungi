#!/usr/bin/env bats

load test_helper

@test "no shims" {
  run pungi-shims
  assert_success
  assert [ -z "$output" ]
}

@test "shims" {
  mkdir -p "${PUNGI_ROOT}/shims"
  touch "${PUNGI_ROOT}/shims/python"
  touch "${PUNGI_ROOT}/shims/irb"
  run pungi-shims
  assert_success
  assert_line "${PUNGI_ROOT}/shims/python"
  assert_line "${PUNGI_ROOT}/shims/irb"
}

@test "shims --short" {
  mkdir -p "${PUNGI_ROOT}/shims"
  touch "${PUNGI_ROOT}/shims/python"
  touch "${PUNGI_ROOT}/shims/irb"
  run pungi-shims --short
  assert_success
  assert_line "irb"
  assert_line "python"
}
