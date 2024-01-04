class_name Mountains extends SpawnHandler

func getTileMap() -> TileMap:
	return $TileMap

func getLevelBounds() -> Area2D:
	return $TileMap/LevelBounds

func getLevelGoal() -> Area2D:
	var chicken : Chicken = $TileMap/chicken
	return chicken.getHitBox()

func prepare():
	setFeatherType(Feather.Type.brown)
	var chicken : Chicken = $TileMap/chicken
	chicken.setType(Feather.Type.brown)
	chicken.set_owner(getTileMap())
	for frog in getFrogs():
		frog.setType(Frog.Type.acid)
		frog.set_owner(getTileMap())

	super.prepare()
