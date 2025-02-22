extends Node2D

@onready var camera_2d: Camera2D = $Camera2D
@onready var main: Node2D = $".."


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main.transition_to_outside.connect(_on_transition_to_outside)
	main.transition_to_inside.connect(_on_transition_to_inside)
	camera_2d.make_current()

func _on_transition_to_outside() -> void:
	print("t -> o")

func _on_transition_to_inside() -> void:
	print("t -> i")
	camera_2d.make_current()
