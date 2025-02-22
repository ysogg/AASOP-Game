extends Node
class_name AnimationComponent

signal entered

@export_group("Options")
@export var from_centre: bool = true
@export var enter_animation: bool = false
@export var parallel_animations: bool = true
@export var properties: Array = [
	"scale",
	"position",
	"rotation",
	"size",
	"self_modulate"
]
@export_group("Hover Settings")
@export var hover_time: float = 0.1
@export var hover_transition: Tween.TransitionType
@export var hover_easing: Tween.EaseType
@export var hover_position: Vector2
@export var hover_scale: Vector2 = Vector2(1,1)
@export var hover_rotation: float
@export var hover_size: Vector2
@export var hover_modulate: Color = Color.WHITE

@export_group("Enter Settings")
@export var wait_for: AnimationComponent
@export var enter_time: float = 0.1
@export var enter_transition: Tween.TransitionType
@export var enter_easing: Tween.EaseType
@export var enter_position: Vector2
@export var enter_scale: Vector2 = Vector2(1,1)
@export var enter_rotation: float
@export var enter_size: Vector2
@export var enter_modulate: Color = Color.WHITE

var parent 
var default_scale: Vector2
var hover_values: Dictionary
var default_values: Dictionary
var enter_values: Dictionary

const IMMEDIATE_TRANSITION = Tween.TRANS_LINEAR

func _ready() -> void:
	parent = get_parent()
	#research more about this function
	call_deferred("init")

func init() -> void:
	if from_centre:
		parent.pivot_offset = parent.size * 0.5
	default_scale = parent.scale
	default_values = {
		"scale" : parent.scale,
		"position" : parent.position,
		"rotation" : parent.rotation,
		"size" : parent.size,
		"self_modulate" : parent.modulate
	}
	hover_values = {
		"scale" : hover_scale,
		"position" : parent.position + hover_position,
		"rotation" : parent.rotation + deg_to_rad(hover_rotation),
		"size" : parent.size + hover_size,
		"self_modulate" : hover_modulate,
	}
	enter_values = {
		"scale" : enter_scale,
		"position" : parent.position + enter_position,
		"rotation" : parent.rotation + deg_to_rad(enter_rotation),
		"size" : parent.size + enter_size,
		"self_modulate": enter_modulate
	}
	
	connect_signals()
	if enter_animation:
		on_enter()
	else:
		entered.emit()

func on_enter() -> void:
	add_tween(enter_values, true, 0.0, IMMEDIATE_TRANSITION, hover_easing, false)
	
	if wait_for:
		wait_for.entered.connect(add_tween.bind(
			default_values,
			parallel_animations,
			enter_time,
			enter_transition,
			enter_easing,
			true,
		))
	else:
		add_tween(default_values, parallel_animations, enter_time, enter_transition, enter_easing, true)

func connect_signals() -> void:
	parent.mouse_entered.connect(add_tween.bind(
		hover_values, 
		parallel_animations,
		hover_time,
		hover_transition,
		hover_easing,
		false
	))
	parent.mouse_exited.connect(add_tween.bind(
		default_values,
		parallel_animations,
		hover_time,
		hover_transition,
		hover_easing,
		false
	))

func add_tween(values: Dictionary, parallel: bool, seconds: float, 
	transition: Tween.TransitionType, easing: Tween.EaseType, entering: bool) -> void:
	if not get_tree():
		return
	var tween = get_tree().create_tween()
	tween.set_parallel(parallel)
	for property in properties:
		tween.tween_property(parent, str(property), values[property], seconds).set_trans(transition).set_ease(easing)
	
	if entering:
		await tween.finished
		entered.emit()
