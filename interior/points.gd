extends Node2D
@onready var animation_player: AnimationPlayer = $NumberSprite/AnimationPlayer
@onready var points = $NumberSprite
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	points.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
