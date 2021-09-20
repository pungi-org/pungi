#!/usr/bin/env bats

load test_helper

create_executable() {
  name="${1?}"
  shift 1
  bin="${PUNGI_ROOT}/versions/${PUNGI_VERSION}/bin"
  mkdir -p "$bin"
  { if [ $# -eq 0 ]; then cat -
    else echo "$@"
    fi
  } | sed -Ee '1s/^ +//' > "${bin}/$name"
  chmod +x "${bin}/$name"
}

@test "fails with invalid version" {
  export PUNGI_VERSION="3.4"
  run pungi-exec python -V
  assert_failure "pungi: version \`3.4' is not installed (set by PUNGI_VERSION environment variable)"
}

@test "fails with invalid version set from file" {
  mkdir -p "$PUNGI_TEST_DIR"
  cd "$PUNGI_TEST_DIR"
  echo 2.7 > .python-version
  run pungi-exec rspec
  assert_failure "pungi: version \`2.7' is not installed (set by $PWD/.python-version)"
}

@test "completes with names of executables" {
  export PUNGI_VERSION="3.4"
  create_executable "fab" "#!/bin/sh"
  create_executable "python" "#!/bin/sh"

  pungi-rehash
  run pungi-completions exec
  assert_success
  assert_output <<OUT
--help
fab
python
OUT
}

@test "carries original IFS within hooks" {
  create_hook exec hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
SH

  export PUNGI_VERSION=system
  IFS=$' \t\n' run pungi-exec env
  assert_success
  assert_line "HELLO=:hello:ugly:world:again"
}

@test "forwards all arguments" {
  export PUNGI_VERSION="3.4"
  create_executable "python" <<SH
#!$BASH
echo \$0
for arg; do
  # hack to avoid bash builtin echo which can't output '-e'
  printf "  %s\\n" "\$arg"
done
SH

  run pungi-exec python -w "/path to/python script.rb" -- extra args
  assert_success
  assert_output <<OUT
${PUNGI_ROOT}/versions/3.4/bin/python
  -w
  /path to/python script.rb
  --
  extra
  args
OUT
}

@test "sys.executable with system version (#98)" {
  system_python=$(which python3)

  PUNGI_VERSION="custom"
  create_executable "python3" ""
  unset PUNGI_VERSION

  pungi-rehash
  run pungi-exec python3 -c 'import sys; print(sys.executable)'
  assert_success "${system_python}"
}

@test 'PATH is not modified with system Python' {
  # Create a wrapper executable that verifies PATH.
  PUNGI_VERSION="custom"
  create_executable "python3" '[[ "$PATH" == "${PUNGI_TEST_DIR}/root/versions/custom/bin:"* ]] || { echo "unexpected:$PATH"; exit 2;}'
  unset PUNGI_VERSION
  pungi-rehash

  # Path is not modified with system Python.
  run pungi-exec python3 -c 'import os; print(os.getenv("PATH"))'
  assert_success "$PATH"

  # Path is modified with custom Python.
  PUNGI_VERSION=custom run pungi-exec python3
  assert_success

  # Path is modified with custom:system Python.
  PUNGI_VERSION=custom:system run pungi-exec python3
  assert_success

  # Path is not modified with system:custom Python.
  PUNGI_VERSION=system:custom run pungi-exec python3 -c 'import os; print(os.getenv("PATH"))'
  assert_success "$PATH"
}
