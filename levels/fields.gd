class_name Fields extends SpawnHandler

func getTileMap() -> TileMap:
	return $TileMap

func _on_goal_body_entered(body):
	if body is Player:
		levelDone.emit(name)
