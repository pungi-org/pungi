PUNGI_PIP_REHASH_ROOT="${BASH_SOURCE[0]%/*}/pip-rehash"
PUNGI_REHASH_COMMAND="${PUNGI_COMMAND##*/}"

# Remove any version information, from e.g. "pip2" or "pip3.4".
if [[ $PUNGI_REHASH_COMMAND =~ ^(pip|easy_install)[23](\.\d)?$ ]]; then
  PUNGI_REHASH_COMMAND="${BASH_REMATCH[1]}"
fi

if [ -x "${PUNGI_PIP_REHASH_ROOT}/${PUNGI_REHASH_COMMAND}" ]; then
  PUNGI_COMMAND_PATH="${PUNGI_PIP_REHASH_ROOT}/${PUNGI_REHASH_COMMAND##*/}"
  PUNGI_BIN_PATH="${PUNGI_PIP_REHASH_ROOT}"
  export PUNGI_REHASH_REAL_COMMAND="${PUNGI_COMMAND##*/}"
fi
