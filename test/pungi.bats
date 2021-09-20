#!/usr/bin/env bats

load test_helper

@test "blank invocation" {
  run pungi
  assert_failure
  assert_line 0 "$(pungi---version)"
}

@test "invalid command" {
  run pungi does-not-exist
  assert_failure
  assert_output "pungi: no such command \`does-not-exist'"
}

@test "default PUNGI_ROOT" {
  PUNGI_ROOT="" HOME=/home/mislav run pungi root
  assert_success
  assert_output "/home/mislav/.pungi"
}

@test "inherited PUNGI_ROOT" {
  PUNGI_ROOT=/opt/pungi run pungi root
  assert_success
  assert_output "/opt/pungi"
}

@test "default PUNGI_DIR" {
  run pungi echo PUNGI_DIR
  assert_output "$(pwd)"
}

@test "inherited PUNGI_DIR" {
  dir="${BATS_TMPDIR}/myproject"
  mkdir -p "$dir"
  PUNGI_DIR="$dir" run pungi echo PUNGI_DIR
  assert_output "$dir"
}

@test "invalid PUNGI_DIR" {
  dir="${BATS_TMPDIR}/does-not-exist"
  assert [ ! -d "$dir" ]
  PUNGI_DIR="$dir" run pungi echo PUNGI_DIR
  assert_failure
  assert_output "pungi: cannot change working directory to \`$dir'"
}

@test "adds its own libexec to PATH" {
  run pungi echo "PATH"
  assert_success "${BATS_TEST_DIRNAME%/*}/libexec:${BATS_TEST_DIRNAME%/*}/plugins/python-build/bin:$PATH"
}

@test "adds plugin bin dirs to PATH" {
  mkdir -p "$PUNGI_ROOT"/plugins/python-build/bin
  mkdir -p "$PUNGI_ROOT"/plugins/pungi-each/bin
  run pungi echo -F: "PATH"
  assert_success
  assert_line 0 "${BATS_TEST_DIRNAME%/*}/libexec"
  assert_line 1 "${PUNGI_ROOT}/plugins/python-build/bin"
  assert_line 2 "${PUNGI_ROOT}/plugins/pungi-each/bin"
  assert_line 3 "${BATS_TEST_DIRNAME%/*}/plugins/python-build/bin"
}

@test "PUNGI_HOOK_PATH preserves value from environment" {
  PUNGI_HOOK_PATH=/my/hook/path:/other/hooks run pungi echo -F: "PUNGI_HOOK_PATH"
  assert_success
  assert_line 0 "/my/hook/path"
  assert_line 1 "/other/hooks"
  assert_line 2 "${PUNGI_ROOT}/pungi.d"
}

@test "PUNGI_HOOK_PATH includes pungi built-in plugins" {
  unset PUNGI_HOOK_PATH
  run pungi echo "PUNGI_HOOK_PATH"
  assert_success "${PUNGI_ROOT}/pungi.d:${BATS_TEST_DIRNAME%/*}/pungi.d:/usr/local/etc/pungi.d:/etc/pungi.d:/usr/lib/pungi/hooks"
}
