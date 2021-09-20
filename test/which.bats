#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin
  if [[ $1 == */* ]]; then bin="$1"
  else bin="${PUNGI_ROOT}/versions/${1}/bin"
  fi
  mkdir -p "$bin"
  touch "${bin}/$2"
  chmod +x "${bin}/$2"
}

@test "outputs path to executable" {
  create_executable "2.7" "python"
  create_executable "3.4" "py.test"

  PUNGI_VERSION=2.7 run pungi-which python
  assert_success "${PUNGI_ROOT}/versions/2.7/bin/python"

  PUNGI_VERSION=3.4 run pungi-which py.test
  assert_success "${PUNGI_ROOT}/versions/3.4/bin/py.test"

  PUNGI_VERSION=3.4:2.7 run pungi-which py.test
  assert_success "${PUNGI_ROOT}/versions/3.4/bin/py.test"
}

@test "searches PATH for system version" {
  create_executable "${PUNGI_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${PUNGI_ROOT}/shims" "kill-all-humans"

  PUNGI_VERSION=system run pungi-which kill-all-humans
  assert_success "${PUNGI_TEST_DIR}/bin/kill-all-humans"
}

@test "searches PATH for system version (shims prepended)" {
  create_executable "${PUNGI_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${PUNGI_ROOT}/shims" "kill-all-humans"

  PATH="${PUNGI_ROOT}/shims:$PATH" PUNGI_VERSION=system run pungi-which kill-all-humans
  assert_success "${PUNGI_TEST_DIR}/bin/kill-all-humans"
}

@test "searches PATH for system version (shims appended)" {
  create_executable "${PUNGI_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${PUNGI_ROOT}/shims" "kill-all-humans"

  PATH="$PATH:${PUNGI_ROOT}/shims" PUNGI_VERSION=system run pungi-which kill-all-humans
  assert_success "${PUNGI_TEST_DIR}/bin/kill-all-humans"
}

@test "searches PATH for system version (shims spread)" {
  create_executable "${PUNGI_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${PUNGI_ROOT}/shims" "kill-all-humans"

  PATH="${PUNGI_ROOT}/shims:${PUNGI_ROOT}/shims:/tmp/non-existent:$PATH:${PUNGI_ROOT}/shims" \
    PUNGI_VERSION=system run pungi-which kill-all-humans
  assert_success "${PUNGI_TEST_DIR}/bin/kill-all-humans"
}

@test "doesn't include current directory in PATH search" {
  mkdir -p "$PUNGI_TEST_DIR"
  cd "$PUNGI_TEST_DIR"
  touch kill-all-humans
  chmod +x kill-all-humans
  PATH="$(path_without "kill-all-humans")" PUNGI_VERSION=system run pungi-which kill-all-humans
  assert_failure "pungi: kill-all-humans: command not found"
}

@test "version not installed" {
  create_executable "3.4" "py.test"
  PUNGI_VERSION=3.3 run pungi-which py.test
  assert_failure "pungi: version \`3.3' is not installed (set by PUNGI_VERSION environment variable)"
}

@test "versions not installed" {
  create_executable "3.4" "py.test"
  PUNGI_VERSION=2.7:3.3 run pungi-which py.test
  assert_failure <<OUT
pungi: version \`2.7' is not installed (set by PUNGI_VERSION environment variable)
pungi: version \`3.3' is not installed (set by PUNGI_VERSION environment variable)
OUT
}

@test "no executable found" {
  create_executable "2.7" "py.test"
  PUNGI_VERSION=2.7 run pungi-which fab
  assert_failure "pungi: fab: command not found"
}

@test "no executable found for system version" {
  PATH="$(path_without "rake")" PUNGI_VERSION=system run pungi-which rake
  assert_failure "pungi: rake: command not found"
}

@test "executable found in other versions" {
  create_executable "2.7" "python"
  create_executable "3.3" "py.test"
  create_executable "3.4" "py.test"

  PUNGI_VERSION=2.7 run pungi-which py.test
  assert_failure
  assert_output <<OUT
pungi: py.test: command not found

The \`py.test' command exists in these Python versions:
  3.3
  3.4

Note: See 'pungi help global' for tips on allowing both
      python2 and python3 to be found.
OUT
}

@test "carries original IFS within hooks" {
  create_hook which hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
exit
SH

  IFS=$' \t\n' PUNGI_VERSION=system run pungi-which anything
  assert_success
  assert_output "HELLO=:hello:ugly:world:again"
}

@test "discovers version from pungi-version-name" {
  mkdir -p "$PUNGI_ROOT"
  cat > "${PUNGI_ROOT}/version" <<<"3.4"
  create_executable "3.4" "python"

  mkdir -p "$PUNGI_TEST_DIR"
  cd "$PUNGI_TEST_DIR"

  PUNGI_VERSION= run pungi-which python
  assert_success "${PUNGI_ROOT}/versions/3.4/bin/python"
}
