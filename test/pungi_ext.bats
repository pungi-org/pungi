#!/usr/bin/env bats

load test_helper

@test "prefixes" {
  mkdir -p "${PUNGI_TEST_DIR}/bin"
  touch "${PUNGI_TEST_DIR}/bin/python"
  chmod +x "${PUNGI_TEST_DIR}/bin/python"
  mkdir -p "${PUNGI_ROOT}/versions/2.7.10"
  PUNGI_VERSION="system:2.7.10" run pungi-prefix
  assert_success "${PUNGI_TEST_DIR}:${PUNGI_ROOT}/versions/2.7.10"
  PUNGI_VERSION="2.7.10:system" run pungi-prefix
  assert_success "${PUNGI_ROOT}/versions/2.7.10:${PUNGI_TEST_DIR}"
}
