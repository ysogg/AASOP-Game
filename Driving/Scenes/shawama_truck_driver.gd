extends CharacterBody2D

var wheel_base = 90
var turn_angle = 10
var steer_direction
var state
var timer : Timer

func _ready():
	timer = Timer.new()
	timer.set_wait_time(0.3)
	timer.set_one_shot(true)

	add_child(timer)

func _physics_process(delta: float) -> void:
	
	print(state)
	if(timer.is_stopped()):
		state  = "Driving"
	
	if(state == "Driving"):
		get_input()
		calculate_steering(delta)
	
	var collided = move_and_collide(velocity * delta)
	
	if collided:
		if state == "Driving":
			state = "Colliding"
		timer.start()
		velocity = velocity.bounce(collided.get_normal())
		#rotation = collided.get_angle() * -1
	
	
func get_input() -> void:
	var turn = 0
	if Input.is_action_pressed("steer_left"):
		turn = 1
	if Input.is_action_pressed("steer_right"):
		turn = -1
	steer_direction = turn * turn_angle
	velocity = transform.x * -500
	
func calculate_steering(delta) -> void:
	var rear_wheel = position - transform.x * wheel_base/2.0
	var front_wheel = position + transform.x * wheel_base/2.0
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	var new_heading = (front_wheel - rear_wheel).normalized()
	if(new_heading.x >= 0):
		new_heading.x = 0
	velocity = new_heading * velocity.length()
	rotation = new_heading.angle()
	
func _on_timer_timeout() -> void:
	state = "Driving"
