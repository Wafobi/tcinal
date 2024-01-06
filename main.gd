class_name Main extends Node2D

# for paralex background : https://www.youtube.com/watch?v=f8z4x6R7OSM

var level : SpawnHandler
var spawnPoint :String
var player : Player

var mainMenu : Control
var levelEndScreen : Control

var levelStats : Control

var levelLabel : Label

var levelEndScreenLabel : Label

var loadSavedGameButton : Button

var transitionAnimation : SzeneTransitioner
var currentMenu : Control

var healthBar : ProgressBar

func saveGame():
	ResourceHandler.savePlayerValues(player)

signal start_gaming
# Called when the node enters the scene tree for the first time.
func _ready():
	for input in InputMap.action_get_events("jump"):
		print(input.as_text())
	process_mode = Node.PROCESS_MODE_PAUSABLE
	mainMenu = $"CanvasLayer/MarginContainer/Main Menu"
	levelStats = $CanvasLayer/MarginContainer/LevelStats
	levelEndScreen = $CanvasLayer/MarginContainer/LevelEndScreen
	healthBar = $CanvasLayer/MarginContainer/LevelStats/VBoxContainer/healthBar
	levelLabel = $CanvasLayer/MarginContainer/LevelStats/VBoxContainer/HBoxContainer/LevelLabel
	levelEndScreenLabel = $CanvasLayer/MarginContainer/LevelEndScreen/GridContainer/Label
	
	transitionAnimation = $CanvasLayer/Transition
	
	levelEndScreen.hide()
	levelStats.hide()
	mainMenu.hide()
	currentMenu = null
	loadSavedGameButton = $"CanvasLayer/MarginContainer/Main Menu/GridContainer/Continue"
	loadSavedGameButton.hide()
	if ResourceHandler.saveFileExists():
		loadSavedGameButton.show()

	level = null
	spawnPoint = ""
	player = null
	startGame()

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
		currentMenu.show()
		await start_gaming
		currentMenu.hide()
		mainMenu.inMenu = false

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
		transitionAnimation.hideLevel()
		await transitionAnimation.hideDone
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
			player.position = sp.position
			print("Player going to spawn in ", level.name, " at ", sp.name, " ", var_to_str(sp.position))
			level.setupPlayer(player)
			return

func levelDone():
	ResourceHandler.addChicken(level.getChicken().type)
	levelEndScreenLabel.text = level.getLevelStatistics()
	player.active = false
	player.velocity = Vector2.ZERO
	currentMenu = levelEndScreen
	mainMenu.inMenu = true
	if level.name == "demo_room":
		currentMenu.show()
		ResourceHandler.freeChickens()
		await start_gaming
		currentMenu.hide()
		player.active = true
		mainMenu.inMenu = false
		saveGame()
	else:
		player.points += level.levelPoints
		player.feathers += level.feathersCollected
		levelStats.hide()
		player.health = player.max_health
		saveGame()
		call_deferred("loadMainRoom")

func updateLevelLabel():
	if level:
		levelLabel.text = level.getCurrentStatistics()

func _on_timer_timeout():
	updateLevelLabel()

func onPlayerDeath():
	levelStats.hide()
	player.velocity = Vector2.ZERO
	player.active = false
	levelEndScreenLabel.text = """You died!"""
	if player.feathers >= 5:
		levelEndScreenLabel.text = """You died!
		
		2 feathers lost.
		
		Health restored."""
		player.points -= 20
		player.feathers -= 2
	mainMenu.inMenu = true
	currentMenu = levelEndScreen
	player.health = player.max_health
	call_deferred("loadMainRoom", level.name+"_SpawnPoint")

func loadMainRoom(target : String ="SpawnPoint"):
	ResourceHandler.loadChickenCoop()
	if ResourceHandler.game_settings.demo:
		szeneTransition("demo_room", target)

func startGame():
	currentMenu = mainMenu
	mainMenu.inMenu = true
	loadPlayer()
	loadMainRoom()

func _on_level_done_button_pressed():
	start_gaming.emit()

func _on_continue_pressed():
	if get_tree().paused:
		mainMenu.exitMenu()
	else:
		print("restoring state")
		ResourceHandler.loadPlayerValues(player)
		start_gaming.emit()

func _on_new_game_pressed():
	ResourceHandler.prune()
	if player:
		player.reset()
	start_gaming.emit()

func _on_exit_game_pressed():
	get_tree().quit()
