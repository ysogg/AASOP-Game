extends Node

@onready var main_menu: AudioStreamPlayer = $Music/MainMenu
@onready var gameplay: AudioStreamPlayer = $Music/Gameplay

@export var mute_all: bool = false
@export var mute_music: bool = false

func play_main_menu() -> void:
	if not mute_all and not mute_music:
		main_menu.play()

func play_gameplay() -> void:
	if not mute_all and not mute_music:
		main_menu.stop()
		gameplay.play()
