extends Node2D

func _ready():
	if get_tree().get_first_node_in_group("Player"):
		var player = get_tree().get_first_node_in_group("Player")
		player.dropped_item.connect(_on_dropped_item)
		player.picked_up_item.connect(_on_picked_up_item)
	else:
		print("shit's fucked")

func _on_dropped_item(type, pos) -> void:
	print("Dropped item: " + type)
	
	var item_scene = load("res://interior/FloorItem.tscn")
	var instance = item_scene.instantiate()
	instance.position = pos
	add_child(instance)

	instance.get_node("Sprite2D/Item").item_type = Global.held_object
	Global.held_object = ""

func _on_picked_up_item(area, type) -> void:
	print("Picked up item: " + type)
	
	area.get_parent().queue_free()
	
	Global.held_object = type
