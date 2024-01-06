class_name Main extends Node2D

# for paralex background : https://www.youtube.com/watch?v=f8z4x6R7OSM

var level : SpawnHandler
var spawnPoint :String
var player : Player

var mainMenu : Control
var levelEndScreen : Control

var highScore : Control
var levelStats : Control

var highScoreLabel : Label
var levelLabel : Label

var levelEndScreenLabel : Label

var loadSavedGameButton : Button

var transitionAnimation : SzeneTransitioner
var currentMenu : Control

func savePlayer():
	ResourceHandler.saveNode(player)

signal start_gaming
# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = Node.PROCESS_MODE_PAUSABLE
	mainMenu = $"CanvasLayer/MarginContainer/Main Menu"
	highScore = $CanvasLayer/MarginContainer/Highscore
	levelStats = $CanvasLayer/MarginContainer/LevelStats
	levelEndScreen = $CanvasLayer/MarginContainer/LevelEndScreen
	
	highScoreLabel = $CanvasLayer/MarginContainer/Highscore/HighScorePoints
	levelLabel = $CanvasLayer/MarginContainer/LevelStats/LevelPoints
	levelEndScreenLabel = $CanvasLayer/MarginContainer/LevelEndScreen/GridContainer/Label
	
	transitionAnimation = $CanvasLayer/Transition
	
	levelEndScreen.hide()
	levelStats.hide()
	highScore.hide()
	mainMenu.hide()
	currentMenu = null
	loadSavedGameButton = $"CanvasLayer/MarginContainer/Main Menu/GridContainer/Continue"
	loadSavedGameButton.hide()
	if ResourceHandler.saveFileExists("player"):
		loadSavedGameButton.show()

	level = null
	spawnPoint = ""
	player = null
	startGame()

func loadPlayer():
	player = ResourceHandler.loadIfSaveFileExists("player")
	player.dead.connect(onPlayerDeath)
	player.setupDone.connect(onPlayerSetupDone)

func onPlayerSetupDone():
	print("Player ready in ", level.name)
	level.activateEntities()

	transitionAnimation.revealLevel()
	await transitionAnimation.revealDone
	if mainMenu.inMenu:
		currentMenu.show()
		await start_gaming
		currentMenu.hide()
		mainMenu.inMenu = false

	match level.name:
		"demo_room" :
			updateHighScoreLabel()
			levelStats.hide()
			highScore.show()
		_ :
			updateLevelLabel()
			highScore.hide()
			levelStats.show()
	if player:
		player.active = true

func szeneTransition(toSzene : String ,target : String ="SpawnPoint"):
	if not toSzene:
		return
	if player and player.active:
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
	print("W: created ", level.name)
	print("W: searching ", spawnPoint)
	for sp in level.getSpawnPoints():
		if sp.name == spawnPoint:
			Checkpoints.levelspawn = sp.position
			player.position = sp.position
			print("Player going to spawn in ", level.name, " at ", sp.name, " ", var_to_str(sp.position))
			level.setupPlayer(player)
			return

func levelDone():
	player.active = false
	player.velocity = Vector2.ZERO
	levelEndScreenLabel.text = level.getLevelStatistics()
	player.points += level.levelPoints
	player.feathers += level.feathersCollected
	levelStats.hide()
	player.position.x -= 2 #TODO this is a hack ... to prevent the restored player from instantly hitting the chicken
	savePlayer()
	mainMenu.inMenu = true
	currentMenu = levelEndScreen
	call_deferred("loadMainRoom", level.name+"_SpawnPoint")

func updateLevelLabel():
	if level:
		levelLabel.text = level.getCurrentStatistics()

func updateHighScoreLabel():
	highScoreLabel.text = "Health: %.0f | Points: %d | Feathers: %d" % [player.health, player.points, player.feathers]

func _on_timer_timeout():
	updateLevelLabel()

func onPlayerDeath():
	levelStats.hide()
	player.velocity = Vector2.ZERO
	player.active = false
	levelEndScreenLabel.text = """You died!"""
	if player.points > 0:
		levelEndScreenLabel.text = """You died
		and lost 10 Points"""
	mainMenu.inMenu = true
	currentMenu = levelEndScreen
	call_deferred("loadMainRoom", level.name+"_SpawnPoint")

func loadMainRoom(target : String ="SpawnPoint"):
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
		start_gaming.emit()

func _on_new_game_pressed():
	ResourceHandler.prune()
	if player:
		player.reset()
	start_gaming.emit()

func _on_exit_game_pressed():
	get_tree().quit()
