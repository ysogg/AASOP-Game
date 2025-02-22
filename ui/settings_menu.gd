extends Control

func _ready() -> void:
	pass

var fullscreen_toggle = false

func _on_fullscreen_pressed() -> void:
	if fullscreen_toggle:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		fullscreen_toggle = false
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		fullscreen_toggle = true
	
	
func _on_return_pressed() -> void:
	Global.game_controller.change_gui_scene("res://ui/main_menu.tscn")
