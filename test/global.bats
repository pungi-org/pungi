#!/usr/bin/env bats

load test_helper

@test "default" {
  run pungi-global
  assert_success
  assert_output "system"
}

@test "read PUNGI_ROOT/version" {
  mkdir -p "$PUNGI_ROOT"
  echo "1.2.3" > "$PUNGI_ROOT/version"
  run pungi-global
  assert_success
  assert_output "1.2.3"
}

@test "set PUNGI_ROOT/version" {
  mkdir -p "$PUNGI_ROOT/versions/1.2.3"
  run pungi-global "1.2.3"
  assert_success
  run pungi-global
  assert_success "1.2.3"
}

@test "fail setting invalid PUNGI_ROOT/version" {
  mkdir -p "$PUNGI_ROOT"
  run pungi-global "1.2.3"
  assert_failure "pungi: version \`1.2.3' not installed"
}
