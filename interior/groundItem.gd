extends Node2D

func _on_character_body_2d_dropped_item(type, pos) -> void:
	print("Dropped item: " + type)
	
	var item_scene = load("res://interior/FloorItem.tscn")
	var instance = item_scene.instantiate()
	add_child(instance)
	instance.position = pos
