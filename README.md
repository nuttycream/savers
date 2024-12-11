# savers

## Installation

- Enable the addon
- Ceate an empty config.json in the `addons/savers/` folder
- Dock the window anywhere

## Usage

- Refresh list to scan for savable variables
- To mark your variable as savable, expose them to the game editor using the `@export` keyword

For example:
```gdscript
@export var skill_deception: int = 0
var skill_control: int = 1
# only `skill_deception: int` will be saved
```
- Then to save any point of your game scripts, use the singleton `Savers`
```gdscript
# to save
Savers.save()

#to load
Savers.load()
```
