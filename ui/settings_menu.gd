extends Control

func _ready() -> void:
	pass

func _on_fullscreen_pressed() -> void:
	if Global.is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		Global.is_fullscreen = false
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		Global.is_fullscreen = true
	
	
func _on_return_pressed() -> void:
	Global.game_controller.change_gui_scene("res://ui/main_menu.tscn")
