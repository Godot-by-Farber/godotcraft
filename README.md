# godotcraft

A blocky open world game in Godot

![screenshot](https://github.com/afarber/godotcraft/blob/main/screenshot.gif?raw=true)

Initially based on [Godot Beginner Minecraft Tutorial](https://youtube.com/playlist?list=PLQZiuyZoMHcgQDKSv8L9IJ1y6VcVgFI7D) by LegionGames and [Loot Drop VFX](https://youtu.be/_ty0ClqAurc) by Le Lu

Using MIT-licensed [FirstPersonController](https://github.com/LegionGames/FirstPersonController/tree/main) by LegionGames

Using CC0-licensed [Cube World Kit](https://quaternius.com/packs/cubeworldkit.html) by Quaternius

Using MIT-licensed [Stylized Sky](https://github.com/gdquest-demos/godot-4-stylized-sky) by GDQuest

TODO:

Use MIT-licensed [Pocket Godot](https://github.com/lukky-nl/Pocket-Godot) by Lukky

Add [Godot 3D VFX & Effects collection](https://bukkbeek.itch.io/effectblocks) by Bukkbeek

Add a skeleton model, then add LookAtModifier3D below its Skeleton3D



## Development and tests

Use Godot 4.7.2. After cloning, run `git lfs install` and `git lfs pull` to download source assets. Open `project.godot` in the editor and press F5, or run `godot --path .`.

Import assets and run the same standalone tests as the push workflow:

```bash
godot --headless --editor --path . --import
for test_file in tests/*_test.gd; do
  godot --headless --path . --script "$test_file" || exit 1
done
```

The test and Windows export workflows both use Godot 4.7.2.

## Controls

| Action | Keyboard / mouse | PS5 controller |
| --- | --- | --- |
| Move | WASD or arrow keys | Left stick |
| Look | Mouse | Right stick |
| Jump | Space | Cross |
| Sprint | Shift | L3 |
| Destroy block | Left click | R2 |
| Creation effect | Right click | L2 |
| Next / previous block | Tab / Shift+Tab | D-pad right / left |
| Inventory | Q | Triangle |
| Return to menu | Escape | Circle |
| Menu navigation / confirm | Arrows / Enter | D-pad / Cross |

Right-stick sensitivity is adjustable on the Player node. Block placement remains unfinished; the creation input currently requests its existing visual effect.
