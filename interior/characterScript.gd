class_name Player extends CharacterBody2D

@export var speed = 400
@export var dash_speed: float = 1600
@export var dash_duration: float = 0.2

@onready var points = $points
@onready var number_sprite = $points/NumberSprite
@onready var anim_player = $points/NumberSprite/AnimationPlayer  

@onready var all_interactions = []
@onready var interactLabel = $InteractionComponents/InteractLabel
@onready var dash_timer: Timer = $DashTimer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

signal dropped_item
signal picked_up_item

var dashing: bool = false
#cooldown
var can_dash: bool = true
var dash_cooldown: float = 0.5

const DASH_PARTICLES = preload("res://interior/character/dash_particles.tscn")

func get_input():
	var dir = Input.get_vector("left", "right", "up", "down").normalized()
	if !dashing:
		velocity = dir * speed

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("dash") and !dashing and can_dash:
		_updateSpeed()
	if event.is_action_pressed("interact"):
		_interact()

func _updateSpeed():
	var dir = Input.get_vector("left", "right", "up", "down").normalized()
	if dir == Vector2.ZERO:
		return
	dashing = true
	can_dash = false
	velocity = dir * dash_speed
	
	var particles: CPUParticles2D = DASH_PARTICLES.instantiate()
	particles.position = position + Vector2(0, 70)
	particles.direction = -dir
	particles.emitting = true
	add_sibling(particles)
	
	await get_tree().create_timer(dash_duration).timeout
	dashing = false
	velocity = Vector2.ZERO
	
	await get_tree().create_timer(dash_cooldown).timeout
	can_dash = true
	await particles.finished
	particles.queue_free()

func lerp_speed(value: float) -> void:
	speed = value

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
		elif all_interactions[0].item_type != "none":
			#inside ground item zone
			picked_up_item.emit(all_interactions[0], all_interactions[0].item_type)
		else:
			if all_interactions[0].container_status == "empty":
				#deposit item if correct type
				if all_interactions[0].container_type == Global.held_object:
					print("correct type")
					all_interactions[0].container_status = "full"
					Global.held_object = ""
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
		if Global.held_object:
			dropped_item.emit(Global.held_object, position)
		else:
			print("empty hands empty hands!!")
		
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
	if all_interactions && area.interact_label != "GroundItem":
		if all_interactions[0].get_parent().material:
			all_interactions[0].get_parent().material.set_shader_parameter("width", 0)
	all_interactions.insert(0, area)
	update_interactions()

func _on_interaction_area_area_exited(area: Area2D):
	if area.interact_label != "GroundItem":
		all_interactions[0].get_parent().material.set_shader_parameter("width", 0)
	all_interactions.erase(area)
	update_interactions()
	
func update_interactions():
	if all_interactions:
		interactLabel.text = all_interactions[0].interact_label
		if interactLabel.text != "GroundItem":
			all_interactions[0].get_parent().material.set_shader_parameter("width", 2)
	else:
		interactLabel.text = ""
