extends CharacterBody2D

# CONSTS for car phsyics
var wheel_base = 90 # length of the sprite basically
var turn_angle = 10 
var steer_direction
var state # current 2 state system, Driving and Bouncing
var timer : Timer # timer for how long each bounce will last

func _ready():
	timer = Timer.new()
	timer.set_wait_time(0.3) # change this to adjust bounce time
	timer.set_one_shot(true)

	add_child(timer)

func _physics_process(delta: float) -> void:
	
	if(timer.is_stopped()):
		state  = "Driving"
	
	if(state == "Driving"):
		get_input()
		calculate_steering(delta)
	
	var collided = move_and_collide(velocity * delta)
	
	if collided:
		if state == "Driving":
			state = "Bouncing"
		timer.start()
		velocity = velocity.bounce(collided.get_normal())

func get_input() -> void:
	var turn = 0
	if Input.is_action_pressed("move_right"):
		turn = -1
	if Input.is_action_pressed("move_left"):
		turn = 1
	if turn == 0:
		steer_direction = -1 * (Vector2(100, 0) + velocity).angle()
	else:
		steer_direction = turn * turn_angle
	velocity = transform.x * 700 # adjust velocity here
	
func calculate_steering(delta) -> void:
	var rear_wheel = position - transform.x * wheel_base/2.0
	var front_wheel = position + transform.x * wheel_base/2.0
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	var new_heading = (front_wheel - rear_wheel).normalized()
	if(new_heading.x < 0):
		new_heading.x = 0
	velocity = new_heading * velocity.length()
	rotation = new_heading.angle()
