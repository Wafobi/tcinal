class_name Castle extends SpawnHandler

func getTileMap() -> TileMap:
	return $TileMap

func getLevelBounds() -> Area2D:
	return $TileMap/LevelBounds

func prepare():
	setFeatherType(Feather.Type.white)
	super.prepare()
