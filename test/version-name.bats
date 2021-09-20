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
  run pungi-version-name
  assert_success "system"
}

@test "system version is not checked for existence" {
  PUNGI_VERSION=system run pungi-version-name
  assert_success "system"
}

@test "PUNGI_VERSION can be overridden by hook" {
  create_version "2.7.11"
  create_version "3.5.1"
  create_hook version-name test.bash <<<"PUNGI_VERSION=3.5.1"

  PUNGI_VERSION=2.7.11 run pungi-version-name
  assert_success "3.5.1"
}

@test "carries original IFS within hooks" {
  create_hook version-name hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
SH

  export PUNGI_VERSION=system
  IFS=$' \t\n' run pungi-version-name env
  assert_success
  assert_line "HELLO=:hello:ugly:world:again"
}

@test "PUNGI_VERSION has precedence over local" {
  create_version "2.7.11"
  create_version "3.5.1"

  cat > ".python-version" <<<"2.7.11"
  run pungi-version-name
  assert_success "2.7.11"

  PUNGI_VERSION=3.5.1 run pungi-version-name
  assert_success "3.5.1"
}

@test "local file has precedence over global" {
  create_version "2.7.11"
  create_version "3.5.1"

  cat > "${PUNGI_ROOT}/version" <<<"2.7.11"
  run pungi-version-name
  assert_success "2.7.11"

  cat > ".python-version" <<<"3.5.1"
  run pungi-version-name
  assert_success "3.5.1"
}

@test "missing version" {
  PUNGI_VERSION=1.2 run pungi-version-name
  assert_failure "pungi: version \`1.2' is not installed (set by PUNGI_VERSION environment variable)"
}

@test "one missing version (second missing)" {
  create_version "3.5.1"
  PUNGI_VERSION="3.5.1:1.2" run pungi-version-name
  assert_failure
  assert_output <<OUT
pungi: version \`1.2' is not installed (set by PUNGI_VERSION environment variable)
3.5.1
OUT
}

@test "one missing version (first missing)" {
  create_version "3.5.1"
  PUNGI_VERSION="1.2:3.5.1" run pungi-version-name
  assert_failure
  assert_output <<OUT
pungi: version \`1.2' is not installed (set by PUNGI_VERSION environment variable)
3.5.1
OUT
}

pungi-version-name-without-stderr() {
  pungi-version-name 2>/dev/null
}

@test "one missing version (without stderr)" {
  create_version "3.5.1"
  PUNGI_VERSION="1.2:3.5.1" run pungi-version-name-without-stderr
  assert_failure
  assert_output <<OUT
3.5.1
OUT
}

@test "version with prefix in name" {
  create_version "2.7.11"
  cat > ".python-version" <<<"python-2.7.11"
  run pungi-version-name
  assert_success
  assert_output "2.7.11"
}
