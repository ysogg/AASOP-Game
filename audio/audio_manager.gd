extends Node

@onready var main_menu: AudioStreamPlayer2D = $Music/MainMenu

@export var mute: bool = false

func play_main_menu() -> void:
	if not mute:
		main_menu.play()
