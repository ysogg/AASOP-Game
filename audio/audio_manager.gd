extends Node

@onready var main_menu: AudioStreamPlayer = $Music/MainMenu
@onready var gameplay: AudioStreamPlayer = $Music/Gameplay

@onready var bump: AudioStreamPlayer = $sfx/bump
@onready var ding: AudioStreamPlayer = $sfx/ding
@onready var err_sound: AudioStreamPlayer = $sfx/err_sound
@onready var chop: AudioStreamPlayer = $sfx/Chop
@onready var plastic: AudioStreamPlayer = $sfx/Plastic
@onready var driving: AudioStreamPlayer = $sfx/Driving

@onready var warning: AudioStreamPlayer = $sfx/Warning
@onready var warning_2: AudioStreamPlayer = $sfx/Warning2
@onready var warning_3: AudioStreamPlayer = $sfx/Warning3

@onready var door: AudioStreamPlayer = $sfx/Door
@onready var dash: AudioStreamPlayer = $sfx/Dash
@onready var fry: AudioStreamPlayer = $sfx/Fry
@onready var water: AudioStreamPlayer = $sfx/Water
@onready var pick_up: AudioStreamPlayer = $sfx/PickUp
@onready var dropped: AudioStreamPlayer = $sfx/Dropped


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
	if not mute_all:
		bump.play()
	
func play_err() -> void:
	if not mute_all:
		err_sound.play()

func play_ding() -> void:
	if not mute_all:
		ding.play()

func play_chop() -> void:
	if not mute_all:
		chop.play()

func play_plastic() -> void:
	if not mute_all:
		plastic.play()

func play_driving() -> void:
	if not mute_all:
		driving.play()

func play_warning() -> void:
	if not mute_all:
		warning.play()

func play_warning2() -> void:
	if not mute_all:
		warning_2.play()

func play_warning3() -> void:
	if not mute_all:
		warning_3.play()

func play_door() -> void:
	if not mute_all:
		door.play()

func play_dash() -> void:
	if not mute_all:
		dash.play()

func play_fry() -> void:
	if not mute_all:
		fry.play()

func play_water() -> void:
	if not mute_all:
		water.play()

func play_pick_up() -> void:
	if not mute_all:
		pick_up.play()

func play_dropped_item() -> void:
	if not mute_all:
		dropped.play()
