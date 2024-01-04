class_name Fields extends SpawnHandler

func getTileMap() -> TileMap:
	return $TileMap2

func getLevelBounds() -> Area2D:
	return $TileMap2/LevelBounds

func getLevelGoal() -> Area2D:
	var chicken : Chicken = $TileMap2/chicken
	return chicken.getHitBox()

func prepare():
	setFeatherType(Feather.Type.grey)
	var chicken : Chicken = $TileMap2/chicken
	chicken.setType(Feather.Type.grey)
	chicken.set_owner(getTileMap())
	for frog in getFrogs():
		frog.setType(Frog.Type.water)
		frog.set_owner(getTileMap())
	super.prepare()
