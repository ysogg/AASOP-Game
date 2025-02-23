extends Node

@onready var main_menu: AudioStreamPlayer = $Music/MainMenu
@onready var gameplay: AudioStreamPlayer = $Music/Gameplay
@onready var bump: AudioStreamPlayer = $sfx/bump
@onready var ding: AudioStreamPlayer = $sfx/ding
@onready var err_sound: AudioStreamPlayer = $sfx/err_sound

@export var mute_all: bool = false
@export var mute_music: bool = false

func play_main_menu() -> void:
	if not mute_all and not mute_music:
		main_menu.play()

func play_gameplay() -> void:
	if not mute_all and not mute_music:
		main_menu.stop()
		gameplay.play()
		
func play_bump() -> void:
	if not mute_all and not mute_music:
		bump.play()
	
func play_err() -> void:
	if not mute_all and not mute_music:
		err_sound.play()

func play_ding() -> void:
	if not mute_all and not mute_music:
		ding.play()
	
