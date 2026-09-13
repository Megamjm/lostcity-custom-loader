#!/bin/bash
# Check Content pack files for homestead (and any other custom) symbols.
# If an ID is missing, append the next free id=name.
set -uo pipefail

CONTENT="${CONTENT:-/opt/lost-city-rs/content}"
if [[ ! -d "$CONTENT/pack" ]]; then
  echo "[pack-ids] ERROR: $CONTENT/pack not found"
  exit 1
fi
P="$CONTENT/pack"

next_id() {
  awk -F= 'BEGIN{m=-1} /^[0-9]+=/{ if ($1+0>m) m=$1+0 } END{ print m+1 }' "$1"
}

has_symbol() {
  grep -qE "^[0-9]+=${2}$" "$1"
}

ensure() {
  local file="$1" symbol="$2"
  [[ -f "$file" && -n "$symbol" ]] || return 0
  if has_symbol "$file" "$symbol"; then
    return 0
  fi
  if [[ ! -w "$file" ]]; then
    echo "[pack-ids] ERROR: cannot write $file as uid $(id -u)"
    ls -ld "$file"
    return 1
  fi
  local id
  id="$(next_id "$file")"
  printf '%s=%s\n' "$id" "$symbol" >> "$file"
  echo "[pack-ids] + $(basename "$file") ${id}=${symbol}"
}

pull_from_configs() {
  local ext="$1" packfile="$2"
  [[ -f "$packfile" && -d "$CONTENT/scripts" ]] || return 0
  find "$CONTENT/scripts" -name "*.${ext}" -print0 2>/dev/null \
    | while IFS= read -r -d '' f; do
        awk '/^\[[a-zA-Z0-9_]+\]/{ gsub(/\[|\]/,""); print }' "$f"
      done \
    | sort -u \
    | while read -r sym; do
        [[ -n "$sym" ]] || continue
        ensure "$packfile" "$sym" || true
      done
}

echo "[pack-ids] checking $P (uid=$(id -u))"

pull_from_configs loc  "$P/loc.pack"
pull_from_configs npc  "$P/npc.pack"
pull_from_configs obj  "$P/obj.pack"
pull_from_configs varp "$P/varp.pack"
pull_from_configs inv  "$P/inv.pack"

for s in homestead_portal homestead_exit_portal homestead_chest homestead_bank_closet \
         homestead_mine_hole homestead_mine_rope homestead_for_sale homestead_sold_sign; do
  ensure "$P/loc.pack" "$s" || true
done
for s in estate_agent homestead_caretaker homestead_clerk homestead_mine_rat homestead_mine_scorpion \
         clerk_lumbridge clerk_draynor clerk_rimmington clerk_falador clerk_varrock \
         clerk_taverley clerk_catherby clerk_seers clerk_ardougne clerk_edgeville; do
  ensure "$P/npc.pack" "$s" || true
done
for s in land_deed land_deed_blank land_deed_small land_deed_medium land_deed_large land_deed_crafter land_deed_miner; do
  ensure "$P/obj.pack" "$s" || true
done
for s in homestead_house homestead_plot homestead_approached homestead_flags; do
  ensure "$P/varp.pack" "$s" || true
done
ensure "$P/inv.pack" homestead_chest_inv || true

if [[ -f "$P/map.pack" && -d "$CONTENT/maps" ]]; then
  for jm2 in "$CONTENT/maps"/m*_*.jm2; do
    [[ -f "$jm2" ]] || continue
    base="$(basename "$jm2" .jm2)"
    xy="${base#m}"
    ensure "$P/map.pack" "m${xy}" || true
    ensure "$P/map.pack" "l${xy}" || true
  done
fi

missing=0
for s in homestead_portal homestead_exit_portal homestead_chest homestead_bank_closet \
         homestead_mine_hole homestead_mine_rope homestead_for_sale homestead_sold_sign; do
  if ! has_symbol "$P/loc.pack" "$s"; then
    echo "[pack-ids] STILL MISSING loc $s"
    missing=1
  fi
done

if [[ "$missing" -ne 0 ]]; then
  echo "[pack-ids] loc.pack was not updated. World will not start."
  tail -8 "$P/loc.pack" || true
  exit 1
fi

echo "[pack-ids] loc IDs present — ok to pack"
exit 0

# Category symbols used by custom packs. Missing ones parse as Invalid property value.
if [[ -f "$P/category.pack" ]]; then
  for s in homestead_portal homestead_storage homestead_bank homestead_mine homestead_sign \
           homestead_clerk homestead_npc homestead_fish homestead_stairs social_ui guild_npc; do
    ensure "$P/category.pack" "$s" || true
  done
fi
