class_name Fields extends SpawnHandler

func getTileMap() -> TileMap:
	return $TileMap

func getLevelBounds() -> Area2D:
	return $TileMap/LevelBounds

func getLevelGoal() -> Area2D:
	var chicken : Chicken = $TileMap/chicken
	return chicken.getHitBox()

func prepare():
	setFeatherType(Feather.Type.grey)
	var chicken : Chicken = $TileMap/chicken
	chicken.setType(Feather.Type.grey)
	super.prepare()
