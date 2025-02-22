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
	Global.pause_menu_enabled = false
	Global.game_controller.change_gui_scene("res://ui/gameplay_ui.tscn")
