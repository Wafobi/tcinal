class_name Castle extends SpawnHandler

func getTileMap() -> TileMap:
	return $TileMap

func getLevelBounds() -> Area2D:
	return $TileMap/LevelBounds

func getLevelGoal() -> Area2D:
	var chicken : Chicken = $TileMap/chicken
	return chicken.getHitBox()

func prepare():
	var chicken : Chicken = $TileMap/chicken
	setFeatherType(Feather.Type.white)
	chicken.setType(Feather.Type.white)
	super.prepare()
