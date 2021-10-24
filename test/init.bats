#!/usr/bin/env bats

load test_helper

@test "creates shims and versions directories" {
  assert [ ! -d "${PUNGI_ROOT}/shims" ]
  assert [ ! -d "${PUNGI_ROOT}/versions" ]
  run pungi-init -
  assert_success
  assert [ -d "${PUNGI_ROOT}/shims" ]
  assert [ -d "${PUNGI_ROOT}/versions" ]
}

@test "auto rehash" {
  run pungi-init -
  assert_success
  assert_line "command pungi rehash 2>/dev/null"
}

@test "setup shell completions" {
  root="$(cd $BATS_TEST_DIRNAME/.. && pwd)"
  run pungi-init - bash
  assert_success
  assert_line "source '${root}/test/../libexec/../completions/pungi.bash'"
}

@test "detect parent shell" {
  SHELL=/bin/false run pungi-init -
  assert_success
  assert_line "export PUNGI_SHELL=bash"
}

@test "detect parent shell from script" {
  mkdir -p "$PUNGI_TEST_DIR"
  cd "$PUNGI_TEST_DIR"
  cat > myscript.sh <<OUT
#!/bin/sh
eval "\$(pungi-init -)"
echo \$PUNGI_SHELL
OUT
  chmod +x myscript.sh
  run ./myscript.sh
  assert_success "sh"
}

@test "setup shell completions (fish)" {
  root="$(cd $BATS_TEST_DIRNAME/.. && pwd)"
  run pungi-init - fish
  assert_success
  assert_line "source '${root}/test/../libexec/../completions/pungi.fish'"
}

@test "fish instructions" {
  run pungi-init fish
  assert [ "$status" -eq 1 ]
  assert_line '# See the README for instructions on how to set up'
}

@test "option to skip rehash" {
  run pungi-init - --no-rehash
  assert_success
  refute_line "pungi rehash 2>/dev/null"
}

@test "adds shims to PATH" {
  export PATH="${BATS_TEST_DIRNAME}/../libexec:/usr/bin:/bin:/usr/local/bin"
  run pungi-init --path bash
  assert_success
  assert_line 0 'export PATH="'${PUNGI_ROOT}'/shims:${PATH}"'
}

@test "adds shims to PATH (fish)" {
  export PATH="${BATS_TEST_DIRNAME}/../libexec:/usr/bin:/bin:/usr/local/bin"
  run pungi-init --path fish
  assert_success
  assert_line 0 "set -gx PATH '${PUNGI_ROOT}/shims' \$PATH"
}

@test "can add shims to PATH more than once" {
  export PATH="${PUNGI_ROOT}/shims:$PATH"
  run pungi-init --path bash
  assert_success
  assert_line 0 'export PATH="'${PUNGI_ROOT}'/shims:${PATH}"'
}

@test "can add shims to PATH more than once (fish)" {
  export PATH="${PUNGI_ROOT}/shims:$PATH"
  run pungi-init --path fish
  assert_success
  assert_line 0 "set -gx PATH '${PUNGI_ROOT}/shims' \$PATH"
}

@test "outputs sh-compatible syntax" {
  run pungi-init - bash
  assert_success
  assert_line '  case "$command" in'

  run pungi-init - zsh
  assert_success
  assert_line '  case "$command" in'
}

@test "outputs fish-specific syntax (fish)" {
  run pungi-init - fish
  assert_success
  assert_line '  switch "$command"'
  refute_line '  case "$command" in'
}
