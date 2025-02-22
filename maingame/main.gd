extends Node2D

@onready var inside_scene: Node2D = $Inside
@onready var outside_scene: Node2D = $Control/SubViewportContainer/SubViewport/Exterior
@onready var sub_viewport: SubViewport = $Control/SubViewportContainer/SubViewport

signal transition_to_inside
signal transition_to_outside

var is_inside: bool = true

func _input(event: InputEvent) -> void:
	#this is the temporary scene swapping. change to actual logic when interactions are fixed
	if event.is_action_pressed("transition_fuck"):
		transition_scene(is_inside)
		is_inside = !is_inside
	if event.is_action_pressed("escape"):
		print("pressed escape")
		#get_tree().paused = true
		#show()
		Global.game_controller.change_gui_scene("res://ui/popup_menu.tscn")

func transition_scene(inside: bool) -> void:
	if inside:
		inside_scene.visible = false
		outside_scene.reparent(self)
		move_child(outside_scene, 1)
		transition_to_outside.emit()
	else:
		outside_scene.reparent(sub_viewport)
		inside_scene.reparent(self)
		inside_scene.visible = true
		move_child(inside_scene, 0)
		transition_to_inside.emit()
