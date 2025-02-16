class_name Player extends CharacterBody2D

@export var speed = 400
@export var max_speed = 800

@onready var all_interactions = []
@onready var interactLabel = $InteractionComponents/InteractLabel
@onready var dash_timer: Timer = $DashTimer

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
	pass

func _on_dash_timer_timeout() -> void:
	speed -= 400


func _physics_process(delta):
	get_input()
	move_and_slide()



func _on_interaction_area_area_entered(area):
	all_interactions.insert(0, area)
	update_interactions()

func _on_interaction_area_area_exited(area: Area2D):
	all_interactions.erase(area)
	update_interactions()
	
func update_interactions():
	if all_interactions:
		interactLabel.text = all_interactions[0].interact_label
	else:
		interactLabel.text = ""
