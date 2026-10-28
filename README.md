# Simple Screencast Keys

Shows the keys and mouse buttons you press on top of the Godot editor. Made it for recording bug videos and tutorials, it's basically the Screencast Keys addon from Blender but for Godot.


<p align="left"><img width="398" height="208" alt="demo" src="https://raw.githubusercontent.com/Megalukes/godot-simple-screencast-keys/master/media/demo.gif" /></p>


- Last keys and clicks as text, with `x3` when you repeat the same one
- A little mouse at the bottom that lights up the button you're holding
- Ctrl/Shift/Alt held right now in a box next to it
- Bottom left of the main screen (the 3D/2D view most of the time)

## Install

Copy `addons/simple_screencast_keys` into your project's `addons` folder and enable it in **Project > Project Settings > Plugins**.

Turn it on and off from **Project > Tools > Toggle Screencast Keys**.

## Settings

No settings screen for now, the constants at the top of `screencast_overlay.gd` are the settings (font size, colors, how long a line stays up, etc). Disable and enable the plugin again after changing them.

Tested on Godot 4.7.x

## Credits

Inspired by [Screencast Keys](https://github.com/nutti/Screencast-Keys) for Blender by nutti (GPL-3.0). The mouse proportions come from its [`draw_mouse_v2`](https://github.com/nutti/Screencast-Keys/blob/6170995c34ed49b2a4a56463b0f68d11f5471bfe/src/screencast_keys/ops.py#L105-L183), I rewrote the drawing for Godot.

MIT License.
