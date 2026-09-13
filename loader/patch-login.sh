#!/bin/bash
LOGIN=/opt/lost-city-rs/content/scripts/login_logout/login.rs2
[ -f "$LOGIN" ] || exit 0
# fix any 2-arg leftover from older boots
sed -i 's/queue(homestead_login, 1);/queue(homestead_login, 1, 0);/g' "$LOGIN"
if ! grep -q homestead_login "$LOGIN"; then
  sed -i 's/^\[login,_\]/[login,_]\nqueue(homestead_login, 1, 0);/' "$LOGIN"
fi
echo "[custom-loader] login hook -> $(grep homestead_login "$LOGIN" | head -1)"
