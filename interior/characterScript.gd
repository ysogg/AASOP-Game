class_name Player extends CharacterBody2D

@export var speed = 400
@export var max_speed = 800

@onready var points = $points
@onready var number_sprite = $points/NumberSprite
@onready var anim_player = $points/NumberSprite/AnimationPlayer  

@onready var all_interactions = []
@onready var interactLabel = $InteractionComponents/InteractLabel
@onready var dash_timer: Timer = $DashTimer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func get_input():
		var dir = Input.get_vector("left", "right", "up", "down")
		velocity = dir * speed
			

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("dash"):
		_updateSpeed()
	if event.is_action_pressed("interact"):
		_interact()

func _updateSpeed():
	if (speed != 800):
		speed += 400
		dash_timer.start(0.5)
		
func _interact():
	if all_interactions:
		if all_interactions[0].item_provider:
			if Global.held_object:
				#already holding something, either swap or drop
				pass
			#get item
			else:
				Global.held_object = all_interactions[0].container_type
				print("Picked up: " + Global.held_object)

		else:
			if all_interactions[0].container_status == "empty":
				#deposit item if correct type
				if all_interactions[0].container_type == Global.held_object:
					print("correct type")
					all_interactions[0].container_status = "full"
					Global.current_score += 500

					# Set number position and make it visible
					points.global_position = global_position + Vector2(700, 200)  # Adjust position
					points.visible = true  
					number_sprite.visible = true
					# Play animation to float up and disappear
					anim_player.play("float")
			else:
				print("container full")
	else:
#		drop item?
		print("Dropped item: " + Global.held_object)
		Global.held_object = ""
		
func _on_dash_timer_timeout() -> void:
	speed -= 400


func _physics_process(delta):
	get_input()
	if animated_sprite == null:
		print("ERROR: animated_sprite is null!")  # Debugging
	if velocity.length() > 0:
		animated_sprite.play("run")
		if velocity.x != 0:
			animated_sprite.flip_h = velocity.x < 0
	else:
		animated_sprite.play("stand")
	
	move_and_slide()


func _on_interaction_area_area_entered(area):
	all_interactions.insert(0, area)
	update_interactions()

func _on_interaction_area_area_exited(area: Area2D):
	all_interactions[0].get_parent().material.set_shader_parameter("width", 0)
	all_interactions.erase(area)
	update_interactions()
	
func update_interactions():
	if all_interactions:
		interactLabel.text = all_interactions[0].interact_label
		all_interactions[0].get_parent().material.set_shader_parameter("width", 2)
	else:
		interactLabel.text = ""
