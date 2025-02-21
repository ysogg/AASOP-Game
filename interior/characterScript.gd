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

signal dropped_item
signal picked_up_item
signal placed_item
signal removed_placed_item

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
		
		#happens on spacebar, attempts to start mash minigame
func _mash():
	pass
	
func _interact():
	var in_provider = false
	var in_receiver = false
	var in_prep = false
	var container_full = false
	var table_placed_item = false
	var ground_item = false
	
	if all_interactions:
		for zone in all_interactions:
			if zone.item_provider: in_provider = true
			if zone.item_receiver: in_receiver = true
			if zone.container_status != "empty": container_full = true
			if in_receiver && in_provider: in_prep = true
			if zone.interact_label == "PlacedItem": table_placed_item = true
			if zone.interact_label == "GroundItem": ground_item = true

		if in_prep && table_placed_item && !Global.held_object:
			removed_placed_item.emit(all_interactions)
		elif in_prep:
			if Global.held_object && container_full:
				print("Container full")
			elif Global.held_object && (all_interactions[0].container_type == Global.held_object || all_interactions[0].container_type ==  "any"):
				placed_item.emit(all_interactions[0], Global.held_object, all_interactions[0].global_position)
		elif in_provider && !Global.held_object:
				print("Picked up: " + all_interactions[0].container_type)
				Global.held_object = all_interactions[0].container_type
		elif in_receiver && Global.held_object:
			if all_interactions[0].container_type == Global.held_object:
				print("Deposited: " + Global.held_object)
				all_interactions[0].container_status = "full"
				Global.held_object = ""
				Global.current_score += 500

				# Set number position and make it visible
				points.global_position = global_position + Vector2(700, 200)  # Adjust position
				points.visible = true  
				number_sprite.visible = true
				# Play animation to float up and disappear
				anim_player.play("float")
				
		elif all_interactions[0].interact_label == "GroundItem" && !Global.held_object:
			picked_up_item.emit(all_interactions[0], all_interactions[0].item_type)
		else:
			print("nuh uh")
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
	if area.interact_label == "PlacedItem":
		pass
	elif all_interactions && area.interact_label != "GroundItem":
		if all_interactions[0].get_parent().material:
			all_interactions[0].get_parent().material.set_shader_parameter("width", 0)
	all_interactions.insert(0, area)
	update_interactions()

func _on_interaction_area_area_exited(area: Area2D):
	if area.interact_label != "GroundItem":
		for test in all_interactions:
			if test.get_parent().material:
			#if all_interactions[0].get_parent().material:
				#all_interactions[0].get_parent().material.set_shader_parameter("width", 0)
				test.get_parent().material.set_shader_parameter("width", 0)
	all_interactions.erase(area)
	update_interactions()
	
func update_interactions():
	if all_interactions:
		interactLabel.text = all_interactions[0].interact_label
		if interactLabel.text != "GroundItem":
			if all_interactions[0].get_parent().material:
				all_interactions[0].get_parent().material.set_shader_parameter("width", 2)
	else:
		interactLabel.text = ""
