
# gd-ecs

This repository is my first attempt at creating an [ECS (Entity Component System)](https://en.wikipedia.org/wiki/Entity_component_system) to work alongside the Godot Game Engine. I've been researching it quite a bit recently and am very interested in its philosophy. It is by no means perfect, but I'm enjoying the workflow so far, so it could be worth sharing. If anything, it's an interesting paradigm shift that others might be interested in.

**Important Note:**
This ECS attempt is not going to and not meant to magically make your Godot Game run faster. I also understand that there is plenty of disagreement about what "ECS" actually means. When I was doing my initial research into the topic, it seems that there are some sticklers for a very specific definition of ECS that believe that ECS ONLY refers to the original use-case for cache optimizations and having data loaded contiguously in memory in order to speed up processing of related components. However, after doing plenty of research, I will respectfully disagree. 

Just a select few articles that support my case that ECS has expanded beyond its original scope and can be utilized even if it's not for its intended original purpose of cache optimization.
 - [Tobias Stein](https://www.gamasutra.com/blogs/TobiasStein/20171122/310172/The_EntityComponentSystem__An_awesome_gamedesign_pattern_in_C_Part_1.php)
	 - "memory efficiency" is only ONE of the listed benefits. Even if we don't get the memory efficiency benefit, we stil get the rest of them by following an ECS-like architecture.
 - [Richard Lord](https://www.richardlord.net/blog/ecs/what-is-an-entity-framework.html)'s post on the topic.
 - [Erik Hazzard](http://vasir.net/blog/game-development/how-to-build-entity-component-system-in-javascript)



# Getting Started

For now, clone the repository (which is just a sample project). I may refactor the distribution method later to turn it into more of an "addon" if this repository picks up any traction.


# Documentation

## Overview

gd-ecs, like every other ECS, consists of Entities, Components, and Systems. My core philosophy behind creating this system was to integrate well with Godot's pre-existing concepts and to sort-of allow for the "best of both worlds" of Godot's built-in Object-oriented Inheritance model and the benefits of writing code in ECS fashion.

## SystemManager
By default, your game should have at least one SystemManager Node. A SystemManager manages all of your Systems and glues all of gd-ecs together. It is worth noting that it is not necessary for Entities to be children (or sub-children) of the SystemManager. Internally the SystemManager has a QueryManager that will listen for all changes and update its internal cache of Entity/Component requirements even at runtime. You just use `add_child()` and `remove_child()` as you would normally, but if you happen to be adding/removing an Entity or a Component, gd-ecs will know about it automatically. (no need to call special methods like `add_component()` or something)


## Components
Components in gd-ecs are pretty traditional. They are data-only and represent state. 

gd-ecs uses duck-typing to determine whether a Node is a Component. It simply checks that the `component_name` property exists and is not empty.

Here is an example of the `C_KinematicMotion2D` Component. It simply contains a few exported variables and state variables. Very traditional.
```
class_name C_KinematicMotion2D
extends Node

const component_name := "C_KinematicMotion2D"

export var acceleration_default := Vector2(5000.0, 0.0)
export var max_speed_default := Vector2(400.0, 1200.0)

var acceleration: Vector2
var on_floor: bool
var on_wall: bool
var velocity: Vector2
var max_speed: Vector2


func _ready() -> void:
	acceleration = acceleration_default
	max_speed = max_speed_default
```

That being said, any pre-existing Node can be a Component, even if it has more than just data and is self-contained in functionality. Want to attach a Sprite to your Entity but don't want to build out a System that handles loading the textures and actually rendering it? Create a Sprite Component! It might not immediately be obvious why you would create a Sprite Component rather than just attaching a normal Sprite (which would work too). You probably want to create a component like this because even if you don't have a System to specifically act upon and provide functionality for the Component since it is self-contained, creating a Component like this will allow for querying from Systems (More on this later)
```
class_name C_Sprite
extends Sprite

const component_name := "C_Sprite"
```
You don't need to worry about the rendering or the transform of the Sprite Component or anything in your Systems -- Godot will handle it all for you. (Note that if you want to add something like a Sprite Component, it still needs to follow Godot's built-in hierarchy, so your Entity's type should also be a derivative of `Node2D`. If you try to add the above `C_Sprite` Component to an Entity that is just a normal Node, it won't work out of the box because children Node2Ds of a regular Node don't inherit their parent Node's transform properties. (and probably other things)


## Entities
In gd-ecs, all Entities are not strictly "just an id referencing a container of components". Any Node can be an Entity. All you need to do is attach the `Entity.gd` script to a Node to turn it into an Entity.

Before you flip out about my not following ECS to the letter, hear me out -- I am effectively treating ALL Godot-provided Nodes as built-in types. Similarly to how you wouldn't re-implement the standard library in C++ even if you were building a more traditional ECS, I'm going to treat Godot-provided Nodes as a standard library that is available anywhere in the project. This means that even if TECHNICALLY, the code I'm executing lives inside of one of my entities rather than in a System, I'm going to be calling the code from inside of a System. The ECS part of gd-ecs does NOT apply to the Engine, but only for the game-logic in the project itself. Rendering, Sound, etc are all abstracted away to the Engine and I don't worry about it.

Since you declare an Entity by creating a base Node, attaching the `Entity.gd` script, and then adding just a bunch of children Components, it is perfect for saving in a PackedScene `.tscn` file. See the repo-included `Player.tscn` file for an example.


### Entity API
When processing an entity, you usually want to be able to access its Components. The easiest ways to do this are with `get_component(component_name: String) -> Node` and `get_component(component_name: String) -> Array`. They're pretty self-explanatory. `get_component()` returns the first matching Component, and `get_components()` returns all matching Components. There is a little bit of additional complexity here since an Entity can have duplicates of the same Component type, but I'll worry about this problem in the future :)


## Systems
Systems are managed by a SystemManager Node. They too, are determined by duck-typing and gd-ecs checks for the existence of a `system_name` property. There is a built-in `System.gd` Node that can be extended for most use-cases, but a completely custom System node can be built since gd-ecs relies strictly on duck-typing to determine whether a System is valid or not.

However, at runtime, there are a few additional check for a few more things:

 1. Systems must have a `_system_init()` method that returns `true`. The SystemManager will call `_system_init()` on all of its children and "register" only the ones that return `true` here. It will pass a reference to itself as a parameter. Here is an example of the default `_system_init()`.
 ```
var system_manager: SystemManager

func _system_init(_system_manager: SystemManager) -> bool:
	system_manager = _system_manager
	return true
 ```
 2. Systems must have a non-empty Array `requirements` that is an Array of Strings containing Component requirements for the System. These requirements define which entities a System will process. Here is an example of a system that requires the Components `C_Input` and `C_Player`.
 ```
class_name S_PlayerInput
extends System

func _init() -> void:
	system_name = "S_PlayerInput"
	requirements = ["C_Input", "C_Player"]
 ```
 You can additionally negate requirements with a `!`. In the below example, the System would register itself to only process Entities that have the `C_Input` Component, but do NOT have the `C_Player` Component.
 ```
func _init() -> void:
	system_name = "S_OtherInput"
	requirements = ["C_Input", "!C_Player"]
```

### Virtual Methods for Systems 
Systems have 3 virtual methods that get called automatically by the SystemManager.

1. `_system_ready() -> void`  is called after the SystemManager completes the validation of all of its children Systems and has registered all their requirements.
2. `_system_process(entities: Array, delta: float) -> void` is called every `_process()` loop of the SystemManager. `entities` will contain an Array of only the Entities that match the System's requirements. 
	- Bonus Note: If the System has a `tps` property, you can define the "ticks per second" that the `_system_process` loop is executed. For example, if I want to poll for player input 30 times per second, I could do
	```
	func _init() -> void:
		system_name = "S_PlayerInput"
		requirements = ["C_Input", "C_Player"]
		tps = 30
	```
	and `_system_process` will only be called 30 times per second.
3. `_system_physics_process(entities: Array, delta: float) -> void:` does exactly what you might guess. It is called on every physics frame and passes along an Array of Entities that meet the System's requirements.

Since Systems are just Nodes, you can still use Godot's built-in virtual methods of `_process` and`_physics_process`, but the difference is that the `_system_*` ones are only going to be called on "active" systems that passed the initial validation mentioned previously.


## Contributing

Please open a Github Issue! I'd love to get Tests set up on all of this but have been too lazy... I'd love it if someone were to contribute some... particularly for the QueryManager since it's pretty important for it to pick up changes properly (when adding/removing entities/components)


## Authors

* **Jonathan  Chun**


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details


