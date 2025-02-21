extends Node2D

func _ready():
	if get_tree().get_first_node_in_group("Player"):
		var player = get_tree().get_first_node_in_group("Player")
		player.placed_item.connect(_on_placed_item)
		player.removed_placed_item.connect(_on_removed_placed_item)
	else:
		print("shit's fucked")

func _on_placed_item(area, type, pos) -> void:
	print("Placed item: " + type)
	
	area.container_status = "full"
	area.item_type = type
	var item_scene = load("res://interior/PlacedItem.tscn")
	var instance = item_scene.instantiate()
	instance.get_node("Sprite2D").texture = load("res://interior/assets/" + type + ".png")
	instance.position = pos + Vector2(0, -17)
	add_child(instance)
#
	instance.get_node("Sprite2D/Item").item_type = Global.held_object
	Global.held_object = ""

func _on_removed_placed_item(areas) -> void:
	var type = ""
	var table
	
	
	for area in areas:
		if area.interact_label == "PlacedItem":
			area.get_parent().queue_free()
		else:
			table = area
			type = table.item_type

	table.container_status = "empty"
	
	Global.held_object = type
	print("Picked up placed item: " + type)
