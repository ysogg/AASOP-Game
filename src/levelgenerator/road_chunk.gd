extends TileMapLayer

signal load_new_road_chunk
signal unload_old_road_chunk

func _on_area_2d_body_entered(body: Node2D) -> void:
	load_new_road_chunk.emit()

func _on_area_2d_body_exited(body: Node2D) -> void:
	unload_old_road_chunk.emit()
