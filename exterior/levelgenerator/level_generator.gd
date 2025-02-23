extends Node2D
class_name LevelGenerator

@export var player: CharacterBody2D

# DEFAULT NO HAZARD ROAD DEFINTION
const STRAIGHT_ROAD_SCENE: PackedScene = preload("res://exterior/levelgenerator/roadChunks/straight_road_chunk.tscn")
const END_ROAD_SCENE: PackedScene = preload("res://exterior/levelgenerator/roadChunks/end_road_chunk.tscn")

# HAZARD ROAD DEFS
const NUMBER_OF_HAZARDS = 3
const PEDESTRIAN_ROAD_SCENE: PackedScene = preload("res://exterior/levelgenerator/roadChunks/hazardChunks/pedestrian_road_chunk.tscn")
const TRAFFIC_ROAD_SCENE: PackedScene = preload("res://exterior/levelgenerator/roadChunks/hazardChunks/traffic_road_chunk.tscn")
const CAR_CRASH_ROAD_SCENE: PackedScene = preload("res://exterior/levelgenerator/roadChunks/hazardChunks/car_crash_road_chunk.tscn")


#DENSE SECTION DEFS
const NUMBER_OF_BUSY = 1
const BUSY_ROAD_SCENE: PackedScene = preload("res://exterior/levelgenerator/roadChunks/busyChunk/busy_road_chunk.tscn")

const TILE_SIZE: int = 32
var loaded_chunks: Array[TileMapLayer] = []
var chunk_height: int = 100 #in tiles
var chunk_width: int = 34 # in tiles
var chunk_size: int = chunk_height * TILE_SIZE

#how many chunks are loaded
var road_length: int = 6
@export var course_length = 40 # level length in chunks
var chunk_count = 6

var hazard_timer: Timer
var busy_timer: Timer
var rng: RandomNumberGenerator

@onready var warning_1 = get_node("../../Control/SubViewportContainer/WarningIcons/Warning1")
@onready var warning_2 = get_node("../../Control/SubViewportContainer/WarningIcons/Warning2")
@onready var warning_3 = get_node("../../Control/SubViewportContainer/WarningIcons/Warning3")
var hazard_warning_timer : Timer

func _ready() -> void:
	rng = RandomNumberGenerator.new()
	
	hazard_warning_timer = Timer.new()
	hazard_warning_timer.set_wait_time(3)
	hazard_warning_timer.set_one_shot(true)
	add_child(hazard_warning_timer)
	hazard_warning_timer.timeout.connect(_hide_hazard_waring)
	
	hazard_timer = Timer.new()
	hazard_timer.set_wait_time(rng.randf_range(17,24))
	hazard_timer.set_one_shot(true)
	add_child(hazard_timer)
	hazard_timer.start()
	
	busy_timer = Timer.new()
	busy_timer.set_wait_time(rng.randf_range(120,160))
	busy_timer.set_one_shot(true)
	add_child(busy_timer)
	busy_timer.start()
	
	#load initial 3 chunks
	for i in range(road_length):
		load_chunk()
		

func load_chunk() -> void:
	# random gen of new tile goes here
	var chunk 
	# end condition
	chunk_count += 1
	if (chunk_count == course_length):
		chunk = END_ROAD_SCENE.instantiate()
	elif (chunk_count > course_length):
		return
	# busy section condition
	elif (busy_timer.is_stopped()):
		var busy_selection = rng.randi_range(1, NUMBER_OF_BUSY)
		if(busy_selection == 1):
			chunk = BUSY_ROAD_SCENE.instantiate()
			if Global.warning1:
				Global.warning1.visible = true
			if Global.warning2:
				Global.warning2.visible = true
			if Global.warning3:
				Global.warning3.visible = true
		#busy_timer.set_wait_time(rng.randf_range(120,160))
		busy_timer.start()
		
	# hazard condition
	elif hazard_timer.is_stopped():
		# TODO: signal to the player that a hazard is coming
		
		# do another random select of one of the hazards
		var hazard_selection = rng.randi_range(1, NUMBER_OF_HAZARDS)
		if(hazard_selection == 1):
			if Global.warning3:
				Global.warning3.visible = true
			hazard_warning_timer.start()
			chunk = PEDESTRIAN_ROAD_SCENE.instantiate()
		elif(hazard_selection == 2):
			if Global.warning2:
				Global.warning2.visible = true
			hazard_warning_timer.start()
			chunk = CAR_CRASH_ROAD_SCENE.instantiate()
		elif(hazard_selection == 3):
			if Global.warning1:
				Global.warning1.visible = true
			if Global.warning2:
				Global.warning2.visible = true
			if Global.warning3:
				Global.warning3.visible = true
			hazard_warning_timer.start()
			chunk = TRAFFIC_ROAD_SCENE.instantiate()
		
		# restart the Hazard timer, could also randomize the timer length again here
		# hazard_timer.set_wait_time(rng.randf_range(17,24))
		hazard_timer.start()
	else:
		chunk = STRAIGHT_ROAD_SCENE.instantiate()
		
	#load first chunk one chunk_size behind the player
	if loaded_chunks.is_empty():
		chunk.global_position = Vector2(-ceil(road_length/2) * chunk_size, 0)
	else:
		var last_chunk = loaded_chunks[-1]
		chunk.global_position = last_chunk.global_position + Vector2(chunk_size, 0)
	loaded_chunks.append(chunk)
	call_deferred("add_child", chunk)
	# Ensure the chunk emits signals
	chunk.load_new_road_chunk.connect(load_new_road_chunk)
	chunk.unload_old_road_chunk.connect(unload_old_road_chunk)
	
	chunk_count += 1
	
	if (chunk_count > course_length):
		# get the fuck out	
		# load a final chunk
		return

func _hide_hazard_waring():
	if Global.warning1:
		Global.warning1.visible = false
	if Global.warning2:
		Global.warning2.visible = false
	if Global.warning3:
		Global.warning3.visible = false

func load_new_road_chunk() -> void:
	load_chunk()
	#print("Loading new chunk.")

func unload_old_road_chunk() -> void:
	if loaded_chunks.size() <= road_length:
		return
	var chunk_to_unload = loaded_chunks.pop_front()
	chunk_to_unload.queue_free()
	#print("Unloading old chunk.")
