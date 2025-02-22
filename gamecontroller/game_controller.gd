extends Node
class_name GameController

@export var world_2d: Node2D
@export var gui: Control
@export var transition_controller: SceneTransitionController

var current_2d_scene
var current_gui_scene

func _init() -> void:
	Global.game_controller = self

func _ready() -> void:
	current_gui_scene = $GUI/SplashScreenManager

func change_gui_scene(new_scene: String, delete: bool = true, keep_running: bool = false, transition: bool = true, transition_in: String = "fade_in", transition_out: String = "fade_out", seconds: float = 1.0) -> void:
	if current_gui_scene != null:
		if delete:
			current_gui_scene.queue_free()
		elif keep_running:
			current_gui_scene.visible = false
		else:
			gui.remove_child(current_gui_scene)
	var new = load(new_scene).instantiate()
	gui.add_child(new)
	current_gui_scene = new

func change_2d_scene(new_scene: String, delete: bool = true, keep_running: bool = false, transition: bool = true, transition_in: String = "fade_in", transition_out: String = "fade_out", seconds: float = 1.0) -> void:
	if current_2d_scene != null:
		if delete:
			current_2d_scene.queue_free()
		elif keep_running:
			current_2d_scene.visible = false
		else:
			world_2d.remove_child(current_2d_scene)
	var new = load(new_scene).instantiate()
	world_2d.add_child(new)
	current_2d_scene = new
