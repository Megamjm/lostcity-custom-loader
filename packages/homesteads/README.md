# Homesteads package

Land deeds, island plots, house stamps, estate agent, clerks, miner hole.

On Unraid this already lives at:

`/mnt/user/Data/runescape_custom/custom/homesteads`

Commit that tree into this folder so `git pull` updates the pack:

```bash
cd /mnt/user/Data/runescape_custom/lostcity-custom-loader
rm -rf packages/homesteads/content
cp -a /mnt/user/Data/runescape_custom/custom/homesteads/. packages/homesteads/
git add packages/homesteads
git commit -m "Sync homesteads pack from array"
git push
```

`install.sh` copies `packages/homesteads` back onto `/custom/homesteads`.
