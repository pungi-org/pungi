#!/usr/bin/env bats

load test_helper

@test "prints usage help given no argument" {
  run pungi-hooks
  assert_failure "Usage: pungi hooks <command>"
}

@test "prints list of hooks" {
  path1="${PUNGI_TEST_DIR}/pungi.d"
  path2="${PUNGI_TEST_DIR}/etc/pungi_hooks"
  PUNGI_HOOK_PATH="$path1"
  create_hook exec "hello.bash"
  create_hook exec "ahoy.bash"
  create_hook exec "invalid.sh"
  create_hook which "boom.bash"
  PUNGI_HOOK_PATH="$path2"
  create_hook exec "bueno.bash"

  PUNGI_HOOK_PATH="$path1:$path2" run pungi-hooks exec
  assert_success
  assert_output <<OUT
${PUNGI_TEST_DIR}/pungi.d/exec/ahoy.bash
${PUNGI_TEST_DIR}/pungi.d/exec/hello.bash
${PUNGI_TEST_DIR}/etc/pungi_hooks/exec/bueno.bash
OUT
}

@test "supports hook paths with spaces" {
  path1="${PUNGI_TEST_DIR}/my hooks/pungi.d"
  path2="${PUNGI_TEST_DIR}/etc/pungi hooks"
  PUNGI_HOOK_PATH="$path1"
  create_hook exec "hello.bash"
  PUNGI_HOOK_PATH="$path2"
  create_hook exec "ahoy.bash"

  PUNGI_HOOK_PATH="$path1:$path2" run pungi-hooks exec
  assert_success
  assert_output <<OUT
${PUNGI_TEST_DIR}/my hooks/pungi.d/exec/hello.bash
${PUNGI_TEST_DIR}/etc/pungi hooks/exec/ahoy.bash
OUT
}

@test "resolves relative paths" {
  PUNGI_HOOK_PATH="${PUNGI_TEST_DIR}/pungi.d"
  create_hook exec "hello.bash"
  mkdir -p "$HOME"

  PUNGI_HOOK_PATH="${HOME}/../pungi.d" run pungi-hooks exec
  assert_success "${PUNGI_TEST_DIR}/pungi.d/exec/hello.bash"
}

@test "resolves symlinks" {
  path="${PUNGI_TEST_DIR}/pungi.d"
  mkdir -p "${path}/exec"
  mkdir -p "$HOME"
  touch "${HOME}/hola.bash"
  ln -s "../../home/hola.bash" "${path}/exec/hello.bash"
  touch "${path}/exec/bright.sh"
  ln -s "bright.sh" "${path}/exec/world.bash"

  PUNGI_HOOK_PATH="$path" run pungi-hooks exec
  assert_success
  assert_output <<OUT
${HOME}/hola.bash
${PUNGI_TEST_DIR}/pungi.d/exec/bright.sh
OUT
}
