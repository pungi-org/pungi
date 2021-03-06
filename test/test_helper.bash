unset PUNGI_VERSION
unset PUNGI_DIR

# guard against executing this block twice due to bats internals
if [ -z "$PUNGI_TEST_DIR" ]; then
  PUNGI_TEST_DIR="${BATS_TMPDIR}/pungi"
  export PUNGI_TEST_DIR="$(mktemp -d "${PUNGI_TEST_DIR}.XXX" 2>/dev/null || echo "$PUNGI_TEST_DIR")"

  if enable -f "${BATS_TEST_DIRNAME}"/../libexec/pungi-realpath.dylib realpath 2>/dev/null; then
    export PUNGI_TEST_DIR="$(realpath "$PUNGI_TEST_DIR")"
  else
    if [ -n "$PUNGI_NATIVE_EXT" ]; then
      echo "pungi: failed to load \`realpath' builtin" >&2
      exit 1
    fi
  fi

  export PUNGI_ROOT="${PUNGI_TEST_DIR}/root"
  export HOME="${PUNGI_TEST_DIR}/home"
  export PUNGI_HOOK_PATH="${PUNGI_ROOT}/pungi.d"

  PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin
  PATH="${PUNGI_TEST_DIR}/bin:$PATH"
  PATH="${BATS_TEST_DIRNAME}/../libexec:$PATH"
  PATH="${BATS_TEST_DIRNAME}/libexec:$PATH"
  PATH="${PUNGI_ROOT}/shims:$PATH"
  export PATH

  for xdg_var in `env 2>/dev/null | grep ^XDG_ | cut -d= -f1`; do unset "$xdg_var"; done
  unset xdg_var
fi

teardown() {
  rm -rf "$PUNGI_TEST_DIR"
}

flunk() {
  { if [ "$#" -eq 0 ]; then cat -
    else echo "$@"
    fi
  } | sed "s:${PUNGI_TEST_DIR}:TEST_DIR:g" >&2
  return 1
}

assert_success() {
  if [ "$status" -ne 0 ]; then
    flunk "command failed with exit status $status" $'\n'\
    "output: $output"
  elif [ "$#" -gt 0 ]; then
    assert_output "$1"
  fi
}

assert_failure() {
  if [ "$status" -eq 0 ]; then
    flunk "expected failed exit status" $'\n'\
    "output: $output"
  elif [ "$#" -gt 0 ]; then
    assert_output "$1"
  fi
}

assert_equal() {
  if [ "$1" != "$2" ]; then
    { echo "expected: $1"
      echo "actual:   $2"
    } | flunk
  fi
}

assert_output() {
  local expected
  if [ $# -eq 0 ]; then expected="$(cat -)"
  else expected="$1"
  fi
  assert_equal "$expected" "$output"
}

assert_line() {
  if [ "$1" -ge 0 ] 2>/dev/null; then
    assert_equal "$2" "${lines[$1]}"
  else
    local line
    for line in "${lines[@]}"; do
      if [ "$line" = "$1" ]; then return 0; fi
    done
    flunk "expected line \`$1'"
  fi
}

refute_line() {
  if [ "$1" -ge 0 ] 2>/dev/null; then
    local num_lines="${#lines[@]}"
    if [ "$1" -lt "$num_lines" ]; then
      flunk "output has $num_lines lines"
    fi
  else
    local line
    for line in "${lines[@]}"; do
      if [ "$line" = "$1" ]; then
        flunk "expected to not find line \`$line'"
      fi
    done
  fi
}

assert() {
  if ! "$@"; then
    flunk "failed: $@"
  fi
}

# Output a modified PATH that ensures that the given executable is not present,
# but in which system utils necessary for pungi operation are still available.
path_without() {
  local path=":${PATH}:"
  for exe; do 
    local found alt util
    for found in $(PATH="$path" type -aP "$exe"); do
      found="${found%/*}"
      if [ "$found" != "${PUNGI_ROOT}/shims" ]; then
        alt="${PUNGI_TEST_DIR}/$(echo "${found#/}" | tr '/' '-')"
        mkdir -p "$alt"
        for util in bash head cut readlink greadlink; do
          if [ -x "${found}/$util" ]; then
            ln -s "${found}/$util" "${alt}/$util"
          fi
        done
        path="${path/:${found}:/:${alt}:}"
      fi
    done
  done
  path="${path#:}"
  path="${path%:}"
  echo "$path"
}

create_hook() {
  mkdir -p "${PUNGI_HOOK_PATH}/$1"
  touch "${PUNGI_HOOK_PATH}/$1/$2"
  if [ ! -t 0 ]; then
    cat > "${PUNGI_HOOK_PATH}/$1/$2"
  fi
}
