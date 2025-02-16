extends CharacterBody2D

@export var speed = 400

func get_input():
		var dir = Input.get_vector("left", "right", "up", "down")
		velocity = dir * speed

func _physics_process(delta):
	get_input()
	move_and_slide()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
