extends RigidBody2D

@export var SPEED = 20
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	velocity = Vector2(-SPEED, 0)
	
	move_and_collide(velocity, delta)
