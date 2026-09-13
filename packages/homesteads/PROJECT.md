# Lost City Sylvia — homestead pack

Plot 1 stays `0_8_8_16_16`.
20 plots of 20x20. 6-tile cobble streets (`u48 o10`). Stride 26.
5 columns x 4 rows. Plane 0 only. No hN height — ground matches the mainland.
House stamp is inset +2,+2 so the copy sits inside the fence.
Vacant and cheap (1-3, miner) use fencing. Falador+ use brickwall.

loc_add(coord, loc, rotation, shape, ticks)
wall_straight: 1 south, 0 east, 2 west, 3 north
centrepiece_straight for signs, torches, tables.
queue(homestead_login, 1, 0)
BUILD_VERIFY=false from boot.sh
p_finduid(uid) before player vars in debugprocs.
no stats=, no mod(), no walldecor.

Edit both custom/homesteads and packages/homesteads.
git add / commit / push from lostcity-custom-loader.
install.sh + docker restart lostcity + docker logs --tail.
