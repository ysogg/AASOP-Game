extends Node

var current_scene = null

var current_score: int

var held_object: String

func _ready():
	var root = get_tree().root
	# Using a negative index counts from the end, so this gets the last child node of `root`.
	current_scene = root.get_child(-1)
