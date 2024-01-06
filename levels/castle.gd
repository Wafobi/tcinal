class_name Castle extends SpawnHandler

func getTileMap() -> TileMap:
	return $TileMap

func getLevelBounds() -> Area2D:
	return $TileMap/LevelBounds

func getLevelGoal() -> Area2D:
	var chicken : Chicken = getChicken()
	return chicken.getHitBox()

func prepare():
	levelName = "Old Cathedral"
	var chicken : Chicken = getChicken()
	setFeatherType(Feather.Type.grey)
	chicken.setType(Feather.Type.grey)
	chicken.set_owner(getTileMap())
	for frog in getFrogs():
		frog.setType(Frog.Type.fire)
		frog.set_owner(getTileMap())
	super.prepare()

func getChicken() -> Chicken:
	return $TileMap/chicken

