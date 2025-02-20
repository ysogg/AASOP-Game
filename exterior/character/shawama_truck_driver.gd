extends CharacterBody2D

# VARIABLES FOR CAR HANDLING
var wheel_base = 90 # length of the sprite basically
@export var SPEED = 700
@export var TURN_ANGLE = 10 

var steer_direction
var state # current 2 state system, Driving and Bouncing
var timer : Timer # timer for how long each bounce will last

# VARIABLES FOR IMPACT FRAME ADJUSTMENT
@export var IMPACT_TIME_SCALE = 0.2 # how slow the hit frame will be
@export var IMPACT_DURATION_TIME = 0.3 # how long the hit frame slow will last for
var original_time_scale

func _ready():
	original_time_scale = Engine.time_scale
	
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
		on_collision(collided)

func get_input() -> void:
	var turn = 0
	if Input.is_action_pressed("right"):
		turn = -1
	if Input.is_action_pressed("left"):
		turn = 1
	if turn == 0:
		steer_direction = -1 * (Vector2(100, 0) + velocity).angle()
	else:
		steer_direction = turn * TURN_ANGLE
	velocity = transform.x * SPEED # adjust velocity here
	
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
	
	
# HERE IS WHERE THE COLLSION WORK IS TO DO DONE 
func on_collision(collided) -> void:
	# state stuff
	if state == "Driving":
		state = "Bouncing"
	timer.start()
	
	# calc the bounce
	velocity = velocity.bounce(collided.get_normal())
	
	# run the spin animation
	#$AnimatedSprite2D.play("spin")
	
	# impact frame
	Engine.time_scale = IMPACT_TIME_SCALE 
	await(get_tree().create_timer(IMPACT_TIME_SCALE * IMPACT_DURATION_TIME).timeout)
	Engine.time_scale = original_time_scale
	
	# ALSO PUT THE CODE HERE THAT WILL SLOSH THE TRUCK AROUND
	
