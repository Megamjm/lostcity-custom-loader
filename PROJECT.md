# Lost City Sylvia — homestead pack

Plot 1 stays `0_8_8_16_16`.
Lots are 8x8 with a 4-tile cobble street (Falador `u48 o10`). Stride 12.
Even columns face east. Odd columns face west.
Vacant and cheap houses (1-3, miner) use `fencing`.
Falador and up use `brickwall`.

`loc_add(coord, loc, rotation, shape, ticks)`
wall_straight rotations that block:
- 1 south, 0 east, 2 west, 3 north
centrepiece_straight for signs, torches, tables.
No stats=, no mod(), no walldecor.
queue(homestead_login, 1, 0)
BUILD_VERIFY=false from boot.sh
p_finduid(uid) before player vars in debugprocs.

Office is 10x8 at `0_8_8_16_2` on the south plaza.
Gate opens for owner, deed, friend or guest, then teleports inside.

Edit both custom/homesteads and packages/homesteads.
git add / commit / push from lostcity-custom-loader.
install.sh + docker restart lostcity + docker logs --tail.
