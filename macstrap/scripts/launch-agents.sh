#!/usr/bin/env bash
# Symlinks launch agent plists into the LaunchAgents folder and (re)loads them.
source "$(dirname "$0")/../lib/common.sh"

: "${LAUNCH_AGENTS_SOURCE:?}" "${LAUNCH_AGENTS_DESTINATION:?}"

get_label() {
  local label
  label="$(plutil -extract Label raw -expect string -o - "$1" 2>/dev/null)" || label=""
  if [[ -z "$label" || "$label" == */* ]]; then
    fail "Launch agent '$1' must contain a non-empty string Label without '/'."
  fi
  printf '%s\n' "$label"
}

bootout_if_loaded() {
  local service_target="$1/$2"
  if launchctl print "$service_target" >/dev/null 2>&1; then
    launchctl bootout "$service_target"
  fi
}

lowercase() { printf '%s' "${1%/}" | tr '[:upper:]' '[:lower:]'; }

setup() {
  workflow_skip_step "Apply Launch Agents" && return 0
  header "🚀 Apply Launch Agents"

  if [[ ! -d "$LAUNCH_AGENTS_SOURCE" ]]; then
    warn "Skipping launch agents: directory not found at $LAUNCH_AGENTS_SOURCE"
    return 0
  fi

  local user_id domain
  user_id="$(id -u)"
  [[ "$user_id" != "0" ]] || fail "Launch agents must be installed as the logged-in user, not root."
  domain="gui/$user_id"
  launchctl print "$domain" >/dev/null 2>&1 || fail "The logged-in user's launchctl domain '$domain' is unavailable."

  if [[ "$(lowercase "$LAUNCH_AGENTS_SOURCE")" == "$(lowercase "$LAUNCH_AGENTS_DESTINATION")" ]]; then
    fail "Launch agent source and destination directories must be different."
  fi

  local sources=() labels=() source_file label seen
  for source_file in "$LAUNCH_AGENTS_SOURCE"/*.plist; do
    [[ -e "$source_file" ]] || continue
    plutil -lint "$source_file" >/dev/null
    label="$(get_label "$source_file")"
    for seen in ${labels[@]+"${labels[@]}"}; do
      [[ "$seen" != "$label" ]] || fail "Duplicate launch agent label '$label' in '$LAUNCH_AGENTS_SOURCE'."
    done
    sources+=("$source_file")
    labels+=("$label")
  done

  mkdir -p "$LAUNCH_AGENTS_DESTINATION"

  local i destination
  for ((i = 0; i < ${#sources[@]}; i++)); do
    source_file="${sources[$i]}"
    label="${labels[$i]}"
    destination="$LAUNCH_AGENTS_DESTINATION/$(basename "$source_file")"

    if [[ -e "$destination" || -L "$destination" ]]; then
      if ! confirm "Replace existing launch agent '$destination'?"; then
        info "Skipping launch agent $label"
        continue
      fi

      if [[ -L "$destination" && ! -e "$destination" ]]; then
        warn "Replacing broken launch agent symlink $destination pointing to $(readlink "$destination")"
      else
        local existing_label
        existing_label="$(get_label "$destination")"
        [[ "$existing_label" == "$label" ]] || bootout_if_loaded "$domain" "$existing_label"
      fi
    fi

    bootout_if_loaded "$domain" "$label"
    rm -f "$destination"
    ln -s "$source_file" "$destination"
    launchctl bootstrap "$domain" "$destination"
    info "Linked and loaded launch agent $label"
  done
}

case "${1:-}" in
  setup) setup ;;
  *) usage setup ;;
esac
