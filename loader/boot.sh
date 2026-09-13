#!/bin/bash
# ghcr.io/mserajnik/lost-city-rs:274 (Node + tsx). Do not call /usr/local/bin/start:
# that script overwrites .env and omits BUILD_VERIFY.
set -uo pipefail
CUSTOM=/custom
CONTENT=/opt/lost-city-rs/content
echo "[custom-loader] uid=$(id -u)"

for pack in "$CUSTOM"/*; do
  [ -d "$pack" ] || continue
  [ "$(basename "$pack")" = "_loader" ] && continue
  echo "[custom-loader] pack $(basename "$pack")"
  if [ -d "$pack/content/scripts" ]; then
    find "$pack/content/scripts" -mindepth 1 -maxdepth 1 -type d | while read -r dir; do
      rm -rf "$CONTENT/scripts/$(basename "$dir")"
      cp -a "$dir" "$CONTENT/scripts/$(basename "$dir")"
    done
    echo "  scripts"
  fi
  if [ -d "$pack/content/maps" ]; then
    cp -a "$pack/content/maps/"*.jm2 "$CONTENT/maps/" 2>/dev/null || true
    echo "  maps"
  fi
done

if [ -f /custom/_loader/register-pack-ids.sh ]; then
  CONTENT="$CONTENT" bash /custom/_loader/register-pack-ids.sh || exit 1
fi

if command -v fixuid >/dev/null 2>&1; then
  eval "$(fixuid -q)" || true
fi

cd /opt/lost-city-rs/engine
rm -f data/config/world.json

cat > .env << EOF
EASY_STARTUP=${EASY_STARTUP:-true}
WEBSITE_REGISTRATION=${WEBSITE_REGISTRATION:-false}
WEB_PORT=${WEB_PORT:-8888}
WEB_MANAGEMENT_PORT=${WEB_MANAGEMENT_PORT:-8898}
NODE_MEMBERS=${NODE_MEMBERS:-true}
NODE_XPRATE=${NODE_XPRATE:-1}
NODE_PRODUCTION=${NODE_PRODUCTION:-false}
NODE_DEBUG=${NODE_DEBUG:-true}
NODE_STAFF=${NODE_STAFF:-caelum}
NODE_DEBUGPROC_CHAR=${NODE_DEBUGPROC_CHAR:-~}
LOGIN_SERVER=${LOGIN_SERVER:-true}
LOGIN_HOST=${LOGIN_HOST:-localhost}
LOGIN_PORT=${LOGIN_PORT:-43500}
FRIEND_SERVER=${FRIEND_SERVER:-true}
FRIEND_HOST=${FRIEND_HOST:-localhost}
FRIEND_PORT=${FRIEND_PORT:-45099}
LOGGER_SERVER=${LOGGER_SERVER:-true}
LOGGER_HOST=${LOGGER_HOST:-localhost}
LOGGER_PORT=${LOGGER_PORT:-43501}
DB_BACKEND=${DB_BACKEND:-sqlite}
BUILD_VERIFY=false
EOF
export BUILD_VERIFY=false
echo "[custom-loader] wrote engine .env with BUILD_VERIFY=false"

echo "[custom-loader] migrate + start (tsx)"
npm run sqlite:migrate || true
exec node_modules/.bin/tsx src/app.ts

# --- homestead login hook (274 queue needs 3 args) ---
LOGIN=/opt/lost-city-rs/content/scripts/login_logout/login.rs2
if [ -f "$LOGIN" ]; then
  sed -i 's/queue(homestead_login, 1);/queue(homestead_login, 1, 0);/g' "$LOGIN"
  if ! grep -q homestead_login "$LOGIN"; then
    sed -i 's/^\[login,_\]/[login,_]\nqueue(homestead_login, 1, 0);/' "$LOGIN"
  fi
  echo "[custom-loader] login hook -> $LOGIN"
fi
