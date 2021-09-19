#!/usr/bin/env bats

load test_helper

create_version() {
  mkdir -p "${PUNGI_ROOT}/versions/$1"
}

setup() {
  mkdir -p "$PUNGI_TEST_DIR"
  cd "$PUNGI_TEST_DIR"
}

@test "no version selected" {
  assert [ ! -d "${PUNGI_ROOT}/versions" ]
  run pungi-version
  assert_success "system (set by ${PUNGI_ROOT}/version)"
}

@test "set by PUNGI_VERSION" {
  create_version "3.3.3"
  PUNGI_VERSION=3.3.3 run pungi-version
  assert_success "3.3.3 (set by PUNGI_VERSION environment variable)"
}

@test "set by local file" {
  create_version "3.3.3"
  cat > ".python-version" <<<"3.3.3"
  run pungi-version
  assert_success "3.3.3 (set by ${PWD}/.python-version)"
}

@test "set by global file" {
  create_version "3.3.3"
  cat > "${PUNGI_ROOT}/version" <<<"3.3.3"
  run pungi-version
  assert_success "3.3.3 (set by ${PUNGI_ROOT}/version)"
}

@test "set by PUNGI_VERSION, one missing" {
  create_version "3.3.3"
  PUNGI_VERSION=3.3.3:1.2 run pungi-version
  assert_failure
  assert_output <<OUT
pungi: version \`1.2' is not installed (set by PUNGI_VERSION environment variable)
3.3.3 (set by PUNGI_VERSION environment variable)
OUT
}

@test "set by PUNGI_VERSION, two missing" {
  create_version "3.3.3"
  PUNGI_VERSION=3.4.2:3.3.3:1.2 run pungi-version
  assert_failure
  assert_output <<OUT
pungi: version \`3.4.2' is not installed (set by PUNGI_VERSION environment variable)
pungi: version \`1.2' is not installed (set by PUNGI_VERSION environment variable)
3.3.3 (set by PUNGI_VERSION environment variable)
OUT
}

pungi-version-without-stderr() {
  pungi-version 2>/dev/null
}

@test "set by PUNGI_VERSION, one missing (stderr filtered)" {
  create_version "3.3.3"
  PUNGI_VERSION=3.4.2:3.3.3 run pungi-version-without-stderr
  assert_failure
  assert_output <<OUT
3.3.3 (set by PUNGI_VERSION environment variable)
OUT
}
