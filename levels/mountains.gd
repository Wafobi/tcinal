class_name Mountains extends SpawnHandler

func getTileMap() -> TileMap:
	return $TileMap

func getLevelBounds() -> Area2D:
	return $TileMap/LevelBounds

func getLevelGoal() -> Area2D:
	return $TileMap/Goal

func prepare():
	setFeatherType(Feather.Type.brown)
	super.prepare()
