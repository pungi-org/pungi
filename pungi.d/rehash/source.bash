PROTOTYPE_SOURCE_SHIM_PATH="${SHIM_PATH}/.pungi-source-shim"

shims=()
shopt -s nullglob
for shim in $(cat "${BASH_SOURCE%/*}/source.d/"*".list" | sort | uniq | sed -e 's/#.*$//' | sed -e '/^[[:space:]]*$/d'); do
  if [ -n "${shim##*/}" ]; then
    shims[${#shims[*]}]="${shim})return 0;;"
  fi
done
shopt -u nullglob
eval "source_shim(){ case \"\${1##*/}\" in ${shims[@]} *)return 1;;esac;}"

cat > "${PROTOTYPE_SOURCE_SHIM_PATH}" <<SH
[ -n "\$PUNGI_DEBUG" ] && set -x
export PUNGI_ROOT="${PUNGI_ROOT}"
program="\$("$(command -v pungi)" which "\${BASH_SOURCE##*/}")"
if [ -e "\${program}" ]; then
  . "\${program}" "\$@"
fi
SH
chmod +x "${PROTOTYPE_SOURCE_SHIM_PATH}"

shopt -s nullglob
for shim in "${SHIM_PATH}/"*; do
  if source_shim "${shim}"; then
    cp "${PROTOTYPE_SOURCE_SHIM_PATH}" "${shim}"
  fi
done
shopt -u nullglob

rm -f "${PROTOTYPE_SOURCE_SHIM_PATH}"
