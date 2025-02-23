class_name Player extends CharacterBody2D

@export var speed = 600
@export var dash_speed: float = 1600
@export var dash_duration: float = 0.2

@onready var points = $points
@onready var number_sprite = $points/NumberSprite
@onready var anim_player = $points/NumberSprite/AnimationPlayer  

@onready var all_interactions = []
@onready var interactLabel = $InteractionComponents/InteractLabel
@onready var dash_timer: Timer = $DashTimer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var loading_bar: Sprite2D = $LoadingBar

#@onready var chicken_receiver = get_node("../Node2D/Receivers Folder/ItemReceiver Chicken/Interact")
@onready var receiver_list = [
	get_node("../Node2D/Receivers Folder/ItemReceiver Plates/Interact"),
	get_node("../Node2D/Receivers Folder/ItemReceiver Wraps/Interact"),
	get_node("../Node2D/Receivers Folder/ItemReceiver Fries/Interact"),
	get_node("../Node2D/Receivers Folder/ItemReceiver Lettuce/Interact"),
	get_node("../Node2D/Receivers Folder/ItemReceiver Tomato/Interact"),
	get_node("../Node2D/Receivers Folder/ItemReceiver Onion/Interact"),
]

signal dropped_item
signal picked_up_item
signal placed_item
signal removed_placed_item
signal escape_menu
signal door_pressed

var task_duration = 5.0
var elapsed_time = 0.0
var is_task_active = false
var interact_count = 0
var required_count = 11
var dashing: bool = false
#cooldown
var can_dash: bool = true
var dash_cooldown: float = 0.5

const DASH_PARTICLES = preload("res://interior/character/dash_particles.tscn")

func _ready():
	if get_tree().get_first_node_in_group("Truck"):
		var truck = get_tree().get_first_node_in_group("Truck")
		truck.truck_hit.connect(_on_truck_hit)
	
	#print(receiver_list)

func _on_truck_hit():
	var rand = RandomNumberGenerator.new()
	for rec in receiver_list:
		if rec.container_status == "full":
			var num = rand.randf_range(0, 100)
			if num > 60:
				rec.container_status = "empty"
				#spawn item on ground
				dropped_item.emit(rec.container_type, rec.global_position + Vector2(0,-125))
				

func get_input():
	if is_task_active:
		velocity = Vector2.ZERO
		return
	
	if !Global.movement_lock:
		var dir = Input.get_vector("left", "right", "up", "down").normalized()
		var ray : Dictionary = {
								Vector2(-1,0):90, 
								Vector2(1,0):270, 
								Vector2(0,-1):180, 
								Vector2(0,1):0, 
								Vector2(-0.71,0.71):45, 
								Vector2(-0.71,-0.71):135, 
								Vector2(0.71,-0.71):225, 
								Vector2(0.71,0.71):315
							}
						
		var rounded_dir = (round(dir*pow(10,2))/pow(10,2))
		if rounded_dir != Vector2(0,0):
			get_node("InteractionComponents/RayCast2D").set_rotation(deg_to_rad(ray[rounded_dir]))

		if !dashing:
			velocity = dir * speed

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("dash") and !dashing and can_dash:
		_updateSpeed()
	if event.is_action_pressed("interact"):
		_interact()

		#happens on spacebar, attempts to start mash minigame
func _mash():
	pass

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

func _interact():
	if all_interactions:
		if all_interactions[0].interact_label == "Door":
			door_pressed.emit()
		
	var in_provider = false
	var in_receiver = false
	var in_prep = false
	var container_full = false
	var table_placed_item = false
	var ground_item = false
	var mashable = false
	if is_task_active:
		interact_count += 1
		update_loading_bar()
		if interact_count >= required_count:
			task_completed()
		return
	if all_interactions:
		for zone in all_interactions:
			if zone.item_provider: in_provider = true
			if zone.item_receiver: in_receiver = true
			if zone.container_status != "empty": container_full = true
			if in_receiver && in_provider: in_prep = true
			if zone.interact_label == "PlacedItem": table_placed_item = true
			if zone.interact_label == "GroundItem": ground_item = true
			if zone.mashable: mashable = true

		if in_prep && table_placed_item && !Global.held_object:
			if mashable:
				for zone in all_interactions:
					if zone.interact_label == "PlacedItem":
						if !zone.mashed:
							start_task()
						else:
							removed_placed_item.emit(all_interactions)
							for zone2 in all_interactions:
								zone2.container_status = "empty"
							
			else: 
				removed_placed_item.emit(all_interactions)
				for zone2 in all_interactions:
					zone2.container_status = "empty"
		elif in_prep:
			if Global.held_object && container_full:
				print("Container full")
			elif Global.held_object && (all_interactions[0].container_type == Global.held_object || all_interactions[0].container_type ==  "any"):
				placed_item.emit(all_interactions[0], Global.held_object, all_interactions[0].global_position)
		elif in_provider && !Global.held_object:
				print("Picked up: " + all_interactions[0].container_type)
				Global.held_object = all_interactions[0].container_type
		elif in_receiver && Global.held_object:
			if all_interactions[0].container_type == Global.held_object && !container_full:
				print("Deposited: " + Global.held_object)
				all_interactions[0].container_status = "full"
				Global.held_object = ""
				Global.current_score += 500

				# Set number position and make it visible
				points.global_position = global_position # Adjust position
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

func start_task():
	loading_bar.global_position = global_position + Vector2(-100, -200)
	is_task_active = true
	interact_count = 1
	loading_bar.visible = true
	loading_bar.region_enabled = true 
	update_loading_bar()
	
func update_loading_bar():
	var width = loading_bar.texture.get_width()
	var reveal = int((interact_count / float(required_count)) * width)
	loading_bar.region_rect = Rect2(0, 0, reveal, loading_bar.texture.get_height())
	
func _on_interaction_area_area_entered(area):
	if area.interact_label != "PlacedItem":
		for zone in all_interactions:
			zone.focused = false
			if zone.get_parent().material:
				zone.get_parent().material.set_shader_parameter("width", 0)
				
		area.focused = true;
	all_interactions.insert(0,area)
	focus_zones()

func _on_interaction_area_area_exited(area: Area2D):
	if area.interact_label != "PlacedItem":
		for zone in all_interactions:
			zone.focused = false
		focus_zones()
		all_interactions.erase(area)
		
		for zone in all_interactions:
			zone.focused = true
		focus_zones()
	else:
		all_interactions.erase(area)

func focus_zones():
	for zone in all_interactions:
		if zone.focused:
			if zone.get_parent().material:
				zone.get_parent().material.set_shader_parameter("width", 2)
				interactLabel.text = zone.interact_label
		else:
			if zone.get_parent().material:
				zone.get_parent().material.set_shader_parameter("width", 0)
			

func task_completed():
	is_task_active = false
	loading_bar.visible = false
	for zone in all_interactions:
		if zone.interact_label == "PlacedItem":
			zone.mashed = true
			if zone.item_type == "dirty_plate": zone.item_type = "plates"
			elif zone.item_type == "bagged_wraps": zone.item_type = "wraps"
			elif zone.item_type == "raw_potatoes": zone.item_type = "raw_fries"
			elif zone.item_type == "raw_fries": zone.item_type = "fries"
			elif zone.item_type == "raw_chicken": zone.item_type = "chicken"
			elif zone.item_type == "uncut_lettuce": zone.item_type = "lettuce"
			elif zone.item_type == "uncut_tomato": zone.item_type = "tomato"
			elif zone.item_type == "raw_onion": zone.item_type = "cut_onion"
			elif zone.item_type == "cut_onion": zone.item_type = "onion"
			print("TRUED")
			zone.get_parent().texture = load("res://interior/assets/" + zone.item_type + ".png")
	print("Task Done!")
