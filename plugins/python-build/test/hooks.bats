#!/usr/bin/env bats

load test_helper

setup() {
  export PUNGI_ROOT="${TMP}/pungi"
  export HOOK_PATH="${TMP}/i has hooks"
  mkdir -p "$HOOK_PATH"
}

@test "pungi-install hooks" {
  cat > "${HOOK_PATH}/install.bash" <<OUT
before_install 'echo before: \$PREFIX'
after_install 'echo after: \$STATUS'
OUT
  stub pungi-hooks "install : echo '$HOOK_PATH'/install.bash"
  stub pungi-rehash "echo rehashed"

  definition="${TMP}/3.6.2"
  cat > "$definition" <<<"echo python-build"
  run pungi-install "$definition"

  assert_success
  assert_output <<-OUT
before: ${PUNGI_ROOT}/versions/3.6.2
python-build
after: 0
rehashed
OUT
}

@test "pungi-uninstall hooks" {
  cat > "${HOOK_PATH}/uninstall.bash" <<OUT
before_uninstall 'echo before: \$PREFIX'
after_uninstall 'echo after.'
rm() {
  echo "rm \$@"
  command rm "\$@"
}
OUT
  stub pungi-hooks "uninstall : echo '$HOOK_PATH'/uninstall.bash"
  stub pungi-rehash "echo rehashed"

  mkdir -p "${PUNGI_ROOT}/versions/3.6.2"
  run pungi-uninstall -f 3.6.2

  assert_success
  assert_output <<-OUT
before: ${PUNGI_ROOT}/versions/3.6.2
rm -rf ${PUNGI_ROOT}/versions/3.6.2
rehashed
pungi: 3.6.2 uninstalled
after.
OUT

  refute [ -d "${PUNGI_ROOT}/versions/3.6.2" ]
}
