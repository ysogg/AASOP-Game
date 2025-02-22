extends Node2D

@export var zoom_out: float = 0.25
@export var zoom_in: float = 0.75
@onready var main: Node2D = $"../../../.."

@onready var camera_2d: Camera2D = $ShawamaTruckDriver/Camera2D

var is_inside: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main.transition_to_inside.connect(_on_transition_to_inside)
	main.transition_to_outside.connect(_on_transition_to_outside)
	camera_2d.zoom = Vector2(zoom_out, zoom_out)

func check_inside() -> bool:
	return is_inside

func _on_transition_to_inside() -> void:
	is_inside = true
	camera_2d.zoom = Vector2(zoom_out, zoom_out)

func _on_transition_to_outside() -> void:
	camera_2d.make_current()
	is_inside = false
	camera_2d.zoom = Vector2(zoom_in, zoom_in)
