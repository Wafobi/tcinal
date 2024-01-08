class_name Main extends Node2D

# for paralex background : https://www.youtube.com/watch?v=f8z4x6R7OSM

var level : SpawnHandler
var spawnPoint :String
var player : Player

var mainMenu : MainMenu
var levelEndScreen : LevelEndScreen
var levelStats : LevelStats


var transitionAnimation : SzeneTransitioner

var healthBar : ProgressBar

func saveGame():
	ResourceHandler.savePlayerValues(player)

signal continueGaming

# Called when the node enters the scene tree for the first time.
func _ready():
	mainMenu = $"CanvasLayer/MarginContainer/MainMenu"
	levelStats = $CanvasLayer/MarginContainer/LevelStats
	levelEndScreen = $CanvasLayer/MarginContainer/LevelEndScreen

	mainMenu.hide()
	mainMenu.new_game.connect(newGame)
	mainMenu.continue_game.connect(loadSaveGame)

	levelEndScreen.hide()
	levelEndScreen.continuePressed.connect(continueGame)
	levelStats.hide()

	healthBar = levelStats.getHealthBar()

	transitionAnimation = $CanvasLayer/Transition
	
	level = null
	spawnPoint = ""
	player = null
	call_deferred("startGame")

func loadPlayer():
	player = ResourceHandler.instantiate_resource("player")
	player.healthBar = healthBar
	player.dead.connect(onPlayerDeath)
	player.setupDone.connect(onPlayerSetupDone)

func onPlayerSetupDone():
	print("Player ready in ", level.name)
	level.activateEntities()
	if not ResourceHandler.game_settings.testing:
			match level.name:
					"demo_room" :
							player.setCameraOn(false)
							level.cameraOn()
					_ :
							player.setCameraOn()

	transitionAnimation.revealLevel()
	await transitionAnimation.revealDone

	if mainMenu.inMenu:
		await continueGaming
		mainMenu.inMenu = false
	print("ok")
	updateLevelLabel()
	levelStats.show()
	if player:
		player.active = true

func szeneTransition(toSzene : String ,target : String ="SpawnPoint"):
	if not toSzene:
		return
	if player and player.active:
		levelStats.hide()
		player.active = false
	var new_level = ResourceHandler.instantiate_resource(toSzene)
	if new_level:
		if level:
			print("M: cleanup for " + level.name)
			level.cleanup(false)
			remove_child(level)
			level=null
		Checkpoints.last_checkpoint = null
		spawnPoint = target
		level = new_level
		level.loaded.connect(levelCreated)
		add_child(level)
	else:
		print(toSzene, " not found")
		player.active = true

func levelCreated():
	level.doorSignal.connect(szeneTransition)
	level.levelDone.connect(levelDone)
	level.prepare()
	print("created ", level.name)
	print("searching ", spawnPoint)
	for sp in level.getSpawnPoints():
		if sp.name == spawnPoint:
			Checkpoints.levelspawn = sp.position
			if player:
				player.position = sp.position
				print("Player going to spawn in ", level.name, " at ", sp.name, " ", var_to_str(sp.position))
				level.setupPlayer(player)
			return

func levelDone():
	transitionAnimation.hideLevel()
	await transitionAnimation.hideDone
	ResourceHandler.addChicken(level.getChicken().type)
	levelEndScreen.getLabel().text = level.getLevelStatistics()
	player.active = false
	player.velocity = Vector2.ZERO
	if level.name == "demo_room":
		ResourceHandler.freeChickens()

		mainMenu.inMenu = true
		levelEndScreen.showMenu()

		await continueGaming
		mainMenu.inMenu = false

		player.active = true
		saveGame()
	else:
		player.points += level.levelPoints
		player.feathers += level.feathersCollected
		levelStats.hide()
		player.health = player.max_health
		saveGame()
		mainMenu.inMenu = true
		levelEndScreen.showMenu()
		call_deferred("loadMainRoom")

func updateLevelLabel():
	if level:
		levelStats.getLabel().text = level.getCurrentStatistics()

func _on_timer_timeout():
	updateLevelLabel()

func onPlayerDeath():
	levelStats.hide()
	player.velocity = Vector2.ZERO
	player.active = false
	levelEndScreen.getLabel().text = """You died!"""
	if player.feathers >= 5:
		levelEndScreen.getLabel().text = """You died!
		
		2 feathers lost.
		
		Health restored."""
		player.points -= 20
		player.feathers -= 2
	player.health = player.max_health
	mainMenu.inMenu = true
	levelEndScreen.showMenu()
	call_deferred("loadMainRoom", level.name+"_SpawnPoint")

func loadMainRoom(target : String ="SpawnPoint"):
	ResourceHandler.loadChickenCoop()
	if ResourceHandler.game_settings.demo:
		szeneTransition("demo_room", target)

func startGame():
	mainMenu.inMenu = true
	mainMenu.showMenu()
	loadPlayer()
	loadMainRoom()

func continueGame():
	continueGaming.emit()

func loadSaveGame():
	print("restoring state")
	ResourceHandler.loadPlayerValues(player)
	continueGame()

func newGame():
	ResourceHandler.prune()
	if player:
		player.reset()
	continueGame()

