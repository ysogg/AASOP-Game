extends CharacterBody2D

const SPEED:float  = 150.0

const acceleration_speed: float = 1000.0
func _physics_process(delta: float) -> void:


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity.y = direction.y * SPEED
	velocity.x = -acceleration_speed
	
	move_and_slide()
