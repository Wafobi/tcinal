class_name Mountains extends SpawnHandler

func getTileMap() -> TileMap:
	return $TileMap

func getLevelBounds() -> Area2D:
	return $TileMap/LevelBounds

func getLevelGoal() -> Area2D:
	var chicken : Chicken = getChicken()
	return chicken.getHitBox()

func prepare():
	levelName = "Hill"
	setFeatherType(Feather.Type.white)
	var chicken : Chicken = getChicken()
	chicken.setType(Feather.Type.white)
	chicken.set_owner(getTileMap())
	for frog in getFrogs():
		frog.setType(Frog.Type.acid)
		frog.set_owner(getTileMap())
	super.prepare()

func getChicken() -> Chicken:
	return $TileMap/chicken
