extends Node2D

@onready var inside_scene: Node2D = $Inside
@onready var outside_scene: Node2D = $Control/SubViewportContainer/SubViewport/Exterior
@onready var sub_viewport: SubViewport = $Control/SubViewportContainer/SubViewport
@onready var end_screen: Node2D = $EndScreen
@onready var end_timer = $"End Timer"

signal transition_to_inside
signal transition_to_outside

var is_inside: bool = true

func _init() -> void:
	AudioManager.play_gameplay()

func _ready() -> void:
	end_timer.start()
	if get_tree().get_first_node_in_group("Player"):
		var player = get_tree().get_first_node_in_group("Player")
		player.door_pressed.connect(_on_door_pressed)
	if get_tree().get_first_node_in_group("End"):
		var end = get_tree().get_first_node_in_group("End")
		end.generate_end_signal.connect(_on_end_condition)

func _input(event: InputEvent) -> void:
	#use for debug
	#if event.is_action_pressed("transition_fuck"):
		#transition_scene(is_inside)
		#is_inside = !is_inside
	if event.is_action_pressed("escape") && Global.pause_menu_enabled:
		Global.pause_menu_enabled = false
		Global.game_controller.change_gui_scene("res://ui/gameplay_ui.tscn")
	elif event.is_action_pressed("escape"):
		#get_tree().paused = true
		#show()
		Global.pause_menu_enabled = true
		Global.game_controller.change_gui_scene("res://ui/popup_menu.tscn")

func _on_door_pressed() -> void:
	transition_scene(is_inside)
	is_inside = !is_inside
	
func _on_end_condition() -> void:
	end_screen.visible = true
	#end_screen.reparent(self)

func transition_scene(inside: bool) -> void:
	if inside:
		Global.movement_lock = true
		inside_scene.visible = false
		if Global.warning1:
			Global.warning1.visible = false
		if Global.warning2:
			Global.warning2.visible = false
		if Global.warning3:
			Global.warning3.visible = false
		outside_scene.reparent(self)
		move_child(outside_scene, 1)
		transition_to_outside.emit()
		AudioManager.play_driving()
	else:
		Global.movement_lock = false
		outside_scene.reparent(sub_viewport)
		inside_scene.reparent(self)
		inside_scene.visible = true
		move_child(inside_scene, 0)
		AudioManager.driving.stop()
		transition_to_inside.emit()


func _on_end_timer_timeout() -> void:
	end_screen.visible = true
	inside_scene.visible = false
	outside_scene.visible = false
