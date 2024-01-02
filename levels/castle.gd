class_name Castle extends SpawnHandler

func getTileMap() -> TileMap:
	return $TileMap

func getLevelBounds() -> Area2D:
	return $TileMap/LevelBounds

func prepare():
	for feather in getFeathers():
		feather.setType(Feather.Type.white)
	super.prepare()
