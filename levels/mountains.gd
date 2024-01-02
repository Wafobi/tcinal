class_name Mountains extends SpawnHandler

func getTileMap() -> TileMap:
	return $TileMap

func getLevelBounds() -> Area2D:
	return $TileMap/LevelBounds

func getLevelGoal() -> Area2D:
	return $TileMap/Goal

func prepare():
	for feather in getFeathers():
		feather.setType(Feather.Type.brown)
	super.prepare()
