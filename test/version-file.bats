#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$PUNGI_TEST_DIR"
  cd "$PUNGI_TEST_DIR"
}

create_file() {
  mkdir -p "$(dirname "$1")"
  echo "system" > "$1"
}

@test "detects global 'version' file" {
  create_file "${PUNGI_ROOT}/version"
  run pungi-version-file
  assert_success "${PUNGI_ROOT}/version"
}

@test "prints global file if no version files exist" {
  assert [ ! -e "${PUNGI_ROOT}/version" ]
  assert [ ! -e ".python-version" ]
  run pungi-version-file
  assert_success "${PUNGI_ROOT}/version"
}

@test "in current directory" {
  create_file ".python-version"
  run pungi-version-file
  assert_success "${PUNGI_TEST_DIR}/.python-version"
}

@test "in parent directory" {
  create_file ".python-version"
  mkdir -p project
  cd project
  run pungi-version-file
  assert_success "${PUNGI_TEST_DIR}/.python-version"
}

@test "topmost file has precedence" {
  create_file ".python-version"
  create_file "project/.python-version"
  cd project
  run pungi-version-file
  assert_success "${PUNGI_TEST_DIR}/project/.python-version"
}

@test "PUNGI_DIR has precedence over PWD" {
  create_file "widget/.python-version"
  create_file "project/.python-version"
  cd project
  PUNGI_DIR="${PUNGI_TEST_DIR}/widget" run pungi-version-file
  assert_success "${PUNGI_TEST_DIR}/widget/.python-version"
}

@test "PWD is searched if PUNGI_DIR yields no results" {
  mkdir -p "widget/blank"
  create_file "project/.python-version"
  cd project
  PUNGI_DIR="${PUNGI_TEST_DIR}/widget/blank" run pungi-version-file
  assert_success "${PUNGI_TEST_DIR}/project/.python-version"
}

@test "finds version file in target directory" {
  create_file "project/.python-version"
  run pungi-version-file "${PWD}/project"
  assert_success "${PUNGI_TEST_DIR}/project/.python-version"
}

@test "fails when no version file in target directory" {
  run pungi-version-file "$PWD"
  assert_failure ""
}
