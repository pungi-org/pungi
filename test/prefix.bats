#!/usr/bin/env bats

load test_helper

@test "prefix" {
  mkdir -p "${PUNGI_TEST_DIR}/myproject"
  cd "${PUNGI_TEST_DIR}/myproject"
  echo "1.2.3" > .python-version
  mkdir -p "${PUNGI_ROOT}/versions/1.2.3"
  run pungi-prefix
  assert_success "${PUNGI_ROOT}/versions/1.2.3"
}

@test "prefix for invalid version" {
  PUNGI_VERSION="1.2.3" run pungi-prefix
  assert_failure "pungi: version \`1.2.3' not installed"
}

@test "prefix for system" {
  mkdir -p "${PUNGI_TEST_DIR}/bin"
  touch "${PUNGI_TEST_DIR}/bin/python"
  chmod +x "${PUNGI_TEST_DIR}/bin/python"
  PUNGI_VERSION="system" run pungi-prefix
  assert_success "$PUNGI_TEST_DIR"
}

@test "prefix for system in /" {
  mkdir -p "${BATS_TEST_DIRNAME}/libexec"
  cat >"${BATS_TEST_DIRNAME}/libexec/pungi-which" <<OUT
#!/bin/sh
echo /bin/python
OUT
  chmod +x "${BATS_TEST_DIRNAME}/libexec/pungi-which"
  PUNGI_VERSION="system" run pungi-prefix
  assert_success "/"
  rm -f "${BATS_TEST_DIRNAME}/libexec/pungi-which"
}

@test "prefix for invalid system" {
  PATH="$(path_without python)" run pungi-prefix system
  assert_failure "pungi: system version not found in PATH"
}
