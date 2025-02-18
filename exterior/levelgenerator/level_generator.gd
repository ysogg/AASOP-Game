extends Node2D
class_name LevelGenerator

@export var player: CharacterBody2D

const ROAD_SCENE: PackedScene = preload("res://exterior/levelgenerator/road_chunk.tscn")
const TILE_SIZE: int = 32

var loaded_chunks: Array[TileMapLayer] = []
var chunk_height: int = 20 #in tiles
var chunk_width: int = 10 # in tiles
var chunk_size: int = chunk_height * TILE_SIZE

#how many chunks are loaded
var road_length: int = 7

func _ready() -> void:
	#load initial 3 chunks
	for i in range(road_length):
		load_chunk()

func load_chunk() -> void:
	var chunk = ROAD_SCENE.instantiate()
	#load first chunk one chunk_size behind the player
	if loaded_chunks.is_empty():
		chunk.global_position = Vector2(2 * chunk_size, 0)
	else:
		var last_chunk = loaded_chunks[-1]
		chunk.global_position = last_chunk.global_position - Vector2(chunk_size, 0)
	loaded_chunks.append(chunk)
	call_deferred("add_child", chunk)
	# Ensure the chunk emits signals
	chunk.load_new_road_chunk.connect(load_new_road_chunk)
	chunk.unload_old_road_chunk.connect(unload_old_road_chunk)

func load_new_road_chunk() -> void:
	load_chunk()
	print("Loading new chunk.")

func unload_old_road_chunk() -> void:
	if loaded_chunks.size() <= road_length:
		return
	var chunk_to_unload = loaded_chunks.pop_front()
	chunk_to_unload.queue_free()
	print("Unloading old chunk.")
