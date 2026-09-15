Always emit an Unraid script that:

Edits both custom/homesteads and packages/homesteads (and both _loader / loader)
git add / commit / push from lostcity-custom-loader
install.sh + docker restart lostcity + docker logs --tail
Uses bash/sed/cat only (no python3 on Tower)

Keep:

queue(homestead_login, 1, 0) — three args
BUILD_VERIFY=false written by boot.sh, never image start
p_finduid(uid) before player vars in debugprocs
centrepiece_straight for loc_add shapes
no stats=, no mod(), no walldecor shape

Packs: custom/homesteads, custom/guild, custom/social
