extends TileMapLayer

@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

signal load_new_road_chunk
signal unload_old_road_chunk
signal generate_end_signal

func _on_area_2d_body_entered(body: Node2D) -> void:
	generate_end_signal.emit()

func _on_area_2d_body_exited(body: Node2D) -> void:
	unload_old_road_chunk.emit()
	call_deferred("disable_collision")

func disable_collision() -> void:
	if collision_shape_2d:
		collision_shape_2d.disabled = true
