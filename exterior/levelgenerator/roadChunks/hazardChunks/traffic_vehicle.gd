extends StaticBody2D

@export var SPEED = 20
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position.x = position.x + (-1 * SPEED)
