extends Control

signal play_game_pressed

func _ready() -> void:
	AudioManager.play_main_menu()

func _on_play_game_pressed() -> void:
	play_game_pressed.emit()
	Global.game_controller.change_2d_scene("res://maingame/main.tscn")
	Global.game_controller.change_gui_scene("res://ui/gameplay_ui.tscn")
	print("Play game pressed")


func _on_settings_pressed() -> void:
	print("Display settings")


func _on_credits_pressed() -> void:
	print("Display credits")


func _on_quit_pressed() -> void:
	get_tree().quit()
