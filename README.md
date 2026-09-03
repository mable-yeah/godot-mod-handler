# How to use
code wise the most important functions are:

```AssetManager.init_mod_list()```
to read the mod folders

```AssetManager.verify_asset(path,false)``` 
to load an asset (path can be any theoretically valid path not just res://)

after that each asset is stored within a container so loading it into its proper place is as simple as 
```
if container.asset == null || !(container.asset is Texture): return
%sprite2D.texture = container.asset
```
## on the user's end/testing
create a folder next to the game's exe file `corresponding with the name chosen for the mod folder in asset_manager.gd`

and then every folder contained within that folder will be identified as a new mod

additionally every mod in the mods folder should have a mod_meta.json containing 
``` 
{
	"name":"",
	"id":"",
	"description":""
}
``` 
in order to be initialized properly

after that how mods are handled is up to you

it is also worth noting that mod folders can be tested in the editor by putting a mods folder near your godot editor's exe file, though this behavior is unintentional and may change
