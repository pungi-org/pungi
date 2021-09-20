if [[ ! -o interactive ]]; then
    return
fi

compctl -K _pungi pungi

_pungi() {
  local words completions
  read -cA words

  if [ "${#words}" -eq 2 ]; then
    completions="$(pungi commands)"
  else
    completions="$(pungi completions ${words[2,-2]})"
  fi

  reply=(${(ps:\n:)completions})
}
