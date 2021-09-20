#!/usr/bin/env bats

load test_helper
export PUNGI_ROOT="${TMP}/pungi"

setup() {
  stub pungi-hooks 'install : true'
  stub pungi-rehash 'true'
}

stub_python_build() {
  stub python-build "--lib : $BATS_TEST_DIRNAME/../bin/python-build --lib" "$@"
}

@test "install proper" {
  stub_python_build 'echo python-build "$@"'

  run pungi-install 3.4.2
  assert_success "python-build 3.4.2 ${PUNGI_ROOT}/versions/3.4.2"

  unstub python-build
  unstub pungi-hooks
  unstub pungi-rehash
}

@test "install pungi local version by default" {
  stub_python_build 'echo python-build "$1"'
  stub pungi-local 'echo 3.4.2'

  run pungi-install
  assert_success "python-build 3.4.2"

  unstub python-build
  unstub pungi-local
}

@test "list available versions" {
  stub_python_build \
    "--definitions : echo 2.6.9 2.7.9-rc1 2.7.9-rc2 3.4.2 | tr ' ' $'\\n'"

  run pungi-install --list
  assert_success
  assert_output <<OUT
Available versions:
  2.6.9
  2.7.9-rc1
  2.7.9-rc2
  3.4.2
OUT

  unstub python-build
}

@test "nonexistent version" {
  stub brew false
  stub_python_build 'echo ERROR >&2 && exit 2' \
    "--definitions : echo 2.6.9 2.7.9-rc1 2.7.9-rc2 3.4.2 | tr ' ' $'\\n'"

  run pungi-install 2.7.9
  assert_failure
  assert_output <<OUT
ERROR

The following versions contain \`2.7.9' in the name:
  2.7.9-rc1
  2.7.9-rc2

See all available versions with \`pungi install --list'.

If the version you need is missing, try upgrading pungi:

  cd ${BATS_TEST_DIRNAME}/../../.. && git pull && cd -
OUT

  unstub python-build
}

@test "Homebrew upgrade instructions" {
  stub brew "--prefix : echo '${BATS_TEST_DIRNAME%/*}'"
  stub_python_build 'echo ERROR >&2 && exit 2' \
    "--definitions : true"

  run pungi-install 1.9.3
  assert_failure
  assert_output <<OUT
ERROR

See all available versions with \`pungi install --list'.

If the version you need is missing, try upgrading pungi:

  brew update && brew upgrade pungi
OUT

  unstub brew
  unstub python-build
}

@test "no build definitions from plugins" {
  assert [ ! -e "${PUNGI_ROOT}/plugins" ]
  stub_python_build 'echo $PYTHON_BUILD_DEFINITIONS'

  run pungi-install 3.4.2
  assert_success ""
}

@test "some build definitions from plugins" {
  mkdir -p "${PUNGI_ROOT}/plugins/foo/share/python-build"
  mkdir -p "${PUNGI_ROOT}/plugins/bar/share/python-build"
  stub_python_build "echo \$PYTHON_BUILD_DEFINITIONS | tr ':' $'\\n'"

  run pungi-install 3.4.2
  assert_success
  assert_output <<OUT

${PUNGI_ROOT}/plugins/bar/share/python-build
${PUNGI_ROOT}/plugins/foo/share/python-build
OUT
}

@test "list build definitions from plugins" {
  mkdir -p "${PUNGI_ROOT}/plugins/foo/share/python-build"
  mkdir -p "${PUNGI_ROOT}/plugins/bar/share/python-build"
  stub_python_build "--definitions : echo \$PYTHON_BUILD_DEFINITIONS | tr ':' $'\\n'"

  run pungi-install --list
  assert_success
  assert_output <<OUT
Available versions:
  
  ${PUNGI_ROOT}/plugins/bar/share/python-build
  ${PUNGI_ROOT}/plugins/foo/share/python-build
OUT
}

@test "completion results include build definitions from plugins" {
  mkdir -p "${PUNGI_ROOT}/plugins/foo/share/python-build"
  mkdir -p "${PUNGI_ROOT}/plugins/bar/share/python-build"
  stub python-build "--definitions : echo \$PYTHON_BUILD_DEFINITIONS | tr ':' $'\\n'"

  run pungi-install --complete
  assert_success
  assert_output <<OUT
--list
--force
--skip-existing
--keep
--patch
--verbose
--version
--debug

${PUNGI_ROOT}/plugins/bar/share/python-build
${PUNGI_ROOT}/plugins/foo/share/python-build
OUT
}

@test "not enough arguments for pungi-install" {
  stub_python_build
  stub pungi-help 'install : true'

  run pungi-install
  assert_failure
  unstub pungi-help
}

@test "too many arguments for pungi-install" {
  stub_python_build
  stub pungi-help 'install : true'

  run pungi-install 3.4.1 3.4.2
  assert_failure
  unstub pungi-help
}

@test "show help for pungi-install" {
  stub_python_build
  stub pungi-help 'install : true'

  run pungi-install -h
  assert_success
  unstub pungi-help
}

@test "pungi-install has usage help preface" {
  run head "$(which pungi-install)"
  assert_output_contains 'Usage: pungi install'
}

@test "not enough arguments pungi-uninstall" {
  stub pungi-help 'uninstall : true'

  run pungi-uninstall
  assert_failure
  unstub pungi-help
}

@test "too many arguments for pungi-uninstall" {
  stub pungi-help 'uninstall : true'

  run pungi-uninstall 3.4.1 3.4.2
  assert_failure
  unstub pungi-help
}

@test "show help for pungi-uninstall" {
  stub pungi-help 'uninstall : true'

  run pungi-uninstall -h
  assert_success
  unstub pungi-help
}

@test "pungi-uninstall has usage help preface" {
  run head "$(which pungi-uninstall)"
  assert_output_contains 'Usage: pungi uninstall'
}
