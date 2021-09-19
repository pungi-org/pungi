#!/usr/bin/env bats

load test_helper

@test "without args shows summary of common commands" {
  run pungi-help
  assert_success
  assert_line "Usage: pungi <command> [<args>]"
  assert_line "Some useful pungi commands are:"
}

@test "invalid command" {
  run pungi-help hello
  assert_failure "pungi: no such command \`hello'"
}

@test "shows help for a specific command" {
  mkdir -p "${PUNGI_TEST_DIR}/bin"
  cat > "${PUNGI_TEST_DIR}/bin/pungi-hello" <<SH
#!shebang
# Usage: pungi hello <world>
# Summary: Says "hello" to you, from pungi
# This command is useful for saying hello.
echo hello
SH

  run pungi-help hello
  assert_success
  assert_output <<SH
Usage: pungi hello <world>

This command is useful for saying hello.
SH
}

@test "replaces missing extended help with summary text" {
  mkdir -p "${PUNGI_TEST_DIR}/bin"
  cat > "${PUNGI_TEST_DIR}/bin/pungi-hello" <<SH
#!shebang
# Usage: pungi hello <world>
# Summary: Says "hello" to you, from pungi
echo hello
SH

  run pungi-help hello
  assert_success
  assert_output <<SH
Usage: pungi hello <world>

Says "hello" to you, from pungi
SH
}

@test "extracts only usage" {
  mkdir -p "${PUNGI_TEST_DIR}/bin"
  cat > "${PUNGI_TEST_DIR}/bin/pungi-hello" <<SH
#!shebang
# Usage: pungi hello <world>
# Summary: Says "hello" to you, from pungi
# This extended help won't be shown.
echo hello
SH

  run pungi-help --usage hello
  assert_success "Usage: pungi hello <world>"
}

@test "multiline usage section" {
  mkdir -p "${PUNGI_TEST_DIR}/bin"
  cat > "${PUNGI_TEST_DIR}/bin/pungi-hello" <<SH
#!shebang
# Usage: pungi hello <world>
#        pungi hi [everybody]
#        pungi hola --translate
# Summary: Says "hello" to you, from pungi
# Help text.
echo hello
SH

  run pungi-help hello
  assert_success
  assert_output <<SH
Usage: pungi hello <world>
       pungi hi [everybody]
       pungi hola --translate

Help text.
SH
}

@test "multiline extended help section" {
  mkdir -p "${PUNGI_TEST_DIR}/bin"
  cat > "${PUNGI_TEST_DIR}/bin/pungi-hello" <<SH
#!shebang
# Usage: pungi hello <world>
# Summary: Says "hello" to you, from pungi
# This is extended help text.
# It can contain multiple lines.
#
# And paragraphs.

echo hello
SH

  run pungi-help hello
  assert_success
  assert_output <<SH
Usage: pungi hello <world>

This is extended help text.
It can contain multiple lines.

And paragraphs.
SH
}
