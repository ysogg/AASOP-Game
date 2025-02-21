extends AnimatableBody2D

var direction = 1
@export var SPEED = 10
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if (position.y > 500 or position.y < -500):
		direction = direction * -1
		
	position.y = position.y + (SPEED * direction)
	
