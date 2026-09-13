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

## Homestead island

- Maps: m8_8.jm2 .. m10_10.jm2. Mine: m11_8.jm2.
- Plot 1 stays 0_8_8_16_16.
- 8x8 lots of 16 with 4-tile o22 streets (stride 20). Origin 16, grid end 176.
- Ocean/hill on tiles 176-191.
- Signs on the east curb of all 64 lots, not on the SW wall.
- West strip x 0-11 is preview grass. West avenue is x 12-15 only.
- Preview copies are compact cottages so they do not overlap plot 1.
