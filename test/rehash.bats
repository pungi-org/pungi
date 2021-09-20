#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin="${PUNGI_ROOT}/versions/${1}/bin"
  mkdir -p "$bin"
  touch "${bin}/$2"
  chmod +x "${bin}/$2"
}

@test "empty rehash" {
  assert [ ! -d "${PUNGI_ROOT}/shims" ]
  run pungi-rehash
  assert_success ""
  assert [ -d "${PUNGI_ROOT}/shims" ]
  rmdir "${PUNGI_ROOT}/shims"
}

@test "non-writable shims directory" {
  mkdir -p "${PUNGI_ROOT}/shims"
  chmod -w "${PUNGI_ROOT}/shims"
  run pungi-rehash
  assert_failure "pungi: cannot rehash: ${PUNGI_ROOT}/shims isn't writable"
}

@test "rehash in progress" {
  export PUNGI_REHASH_TIMEOUT=1
  mkdir -p "${PUNGI_ROOT}/shims"
  touch "${PUNGI_ROOT}/shims/.pungi-shim"
  run pungi-rehash
  assert_failure "pungi: cannot rehash: ${PUNGI_ROOT}/shims/.pungi-shim exists"
}

@test "wait until lock acquisition" {
  export PUNGI_REHASH_TIMEOUT=5
  mkdir -p "${PUNGI_ROOT}/shims"
  touch "${PUNGI_ROOT}/shims/.pungi-shim"
  bash -c "sleep 1 && rm -f ${PUNGI_ROOT}/shims/.pungi-shim" &
  run pungi-rehash
  assert_success
}

@test "creates shims" {
  create_executable "2.7" "python"
  create_executable "2.7" "fab"
  create_executable "3.4" "python"
  create_executable "3.4" "py.test"

  assert [ ! -e "${PUNGI_ROOT}/shims/fab" ]
  assert [ ! -e "${PUNGI_ROOT}/shims/python" ]
  assert [ ! -e "${PUNGI_ROOT}/shims/py.test" ]

  run pungi-rehash
  assert_success ""

  run ls "${PUNGI_ROOT}/shims"
  assert_success
  assert_output <<OUT
fab
py.test
python
OUT
}

@test "removes stale shims" {
  mkdir -p "${PUNGI_ROOT}/shims"
  touch "${PUNGI_ROOT}/shims/oldshim1"
  chmod +x "${PUNGI_ROOT}/shims/oldshim1"

  create_executable "3.4" "fab"
  create_executable "3.4" "python"

  run pungi-rehash
  assert_success ""

  assert [ ! -e "${PUNGI_ROOT}/shims/oldshim1" ]
}

@test "binary install locations containing spaces" {
  create_executable "dirname1 p247" "python"
  create_executable "dirname2 preview1" "py.test"

  assert [ ! -e "${PUNGI_ROOT}/shims/python" ]
  assert [ ! -e "${PUNGI_ROOT}/shims/py.test" ]

  run pungi-rehash
  assert_success ""

  run ls "${PUNGI_ROOT}/shims"
  assert_success
  assert_output <<OUT
py.test
python
OUT
}

@test "carries original IFS within hooks" {
  create_hook rehash hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
exit
SH

  IFS=$' \t\n' run pungi-rehash
  assert_success
  assert_output "HELLO=:hello:ugly:world:again"
}

@test "sh-rehash in bash" {
  create_executable "3.4" "python"
  PUNGI_SHELL=bash run pungi-sh-rehash
  assert_success "hash -r 2>/dev/null || true"
  assert [ -x "${PUNGI_ROOT}/shims/python" ]
}

@test "sh-rehash in fish" {
  create_executable "3.4" "python"
  PUNGI_SHELL=fish run pungi-sh-rehash
  assert_success ""
  assert [ -x "${PUNGI_ROOT}/shims/python" ]
}
