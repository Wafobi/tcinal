class_name Main extends Node2D

# for menu see https://www.youtube.com/watch?v=Ueivz6JY5Fw
# for paralex background : https://www.youtube.com/watch?v=f8z4x6R7OSM

var level : SpawnHandler
var spawnPoint :String
var player : Player

var levelTime : float

var mainMenu : Control
var levelEndScreen : Control

var highScore : Control
var levelStats : Control

var highScoreLabel : Label
var levelLabel : Label

var levelEndScreenLabel : Label

var loadSavedGameButton : Button

func savePlayer():
	ResourceHandler.saveNode(player)

# Called when the node enters the scene tree for the first time.
func _ready():
	mainMenu = $"CanvasLayer/MarginContainer/Main Menu"
	highScore = $CanvasLayer/MarginContainer/Highscore
	levelStats = $CanvasLayer/MarginContainer/LevelStats
	levelEndScreen = $CanvasLayer/MarginContainer/LevelEndScreen
	
	highScoreLabel = $CanvasLayer/MarginContainer/Highscore/HighScorePoints
	levelLabel = $CanvasLayer/MarginContainer/LevelStats/LevelPoints
	levelEndScreenLabel = $CanvasLayer/MarginContainer/LevelEndScreen/GridContainer/Label
	levelEndScreen.hide()
	levelStats.hide()
	highScore.hide()
	mainMenu.show()

	loadSavedGameButton = $"CanvasLayer/MarginContainer/Main Menu/GridContainer/Continue"
	loadSavedGameButton.hide()
	if ResourceHandler.saveFileExists("player"):
		loadSavedGameButton.show()

	levelTime = 0.0
	level = null
	spawnPoint = ""
	player = null
	SzeneTransition.done.connect(activatePlayer)

func loadPlayer():
	player = ResourceHandler.loadIfSaveFileExists("player")
	player.dead.connect(onPlayerDeath)
	player.setupDone.connect(onPlayerSetupDone)

func onPlayerSetupDone():
	print("Player ready in ", level.name)
	match level.name:
		"demo_room" :
			updateHighScoreLabel()
			levelStats.hide()
			highScore.show()
		_ :
			highScore.hide()
			levelStats.show()
			updateLevelLabel()
	fadeOut()

func activatePlayer():
	if player:
		print("Player active")
		player.active = true
	level.activateEntities()

func _process(delta):
	if player and player.active:
		levelTime += delta

func fadeIn():
	SzeneTransition.fadeIn()
	
func fadeOut():
	SzeneTransition.fadeOut()

func szeneTransition(toSzene : String ,target="SpawnPoint"):
	if not toSzene:
		return
	fadeIn()
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
		fadeOut() # possible bug - shouldn't activate player
		print(toSzene, " not found")

var levelFeatherCount = 0
var levelFrogCount = 0
func levelCreated():
	levelTime = 0.0
	levelPoints = 0
	feathers = 0
	levelFeatherCount = level.getFeathers().size()
	levelFrogCount = level.getFrogs().size()
	level.doorSignal.connect(szeneTransition)
	level.levelDone.connect(levelDone)
	level.respawn.connect(playerRespawned)
	level.prepare()
	for feather : Feather in level.getFeathers():
		feather.collected.connect(featherCollected)
	for frog : Frog in level.getFrogs():
		frog.killed.connect(frogKilled)
	print("W: created ", level.name, " with ", levelFeatherCount)
	print("W: searching ", spawnPoint)
	for sp in level.getSpawnPoints():
		if sp.name == spawnPoint:
			Checkpoints.levelspawn = sp.position
			player.position = sp.position
			print("Player going to spawn in ", level.name, " at ", sp.name, " ", var_to_str(sp.position))
			level.setupPlayer(player)
			return

var points = 0
var levelPoints = 0
var feathers = 0
var frogs = 0

func playerRespawned():
	levelPoints -= 2

func frogKilled():
	levelPoints += 2
	updateLevelLabel()

func featherCollected(feather : Feather):
	feathers+=1
	levelPoints += feather.points
	updateLevelLabel()

func levelDone(levelName):
	player.active = false
	levelEndScreenLabel.text = """Congratulations
	You finished the level %s.
	Time %d seconds
	Points Collected: %d
	Feathers collected %d / %d
	Frogs killed %d / %d""" % [levelName, int(levelTime), levelPoints, feathers, levelFeatherCount, frogs, levelFrogCount]
	fadeIn()
	points += levelPoints
	levelStats.hide()
	levelEndScreen.show()
	player.position.x -= 2 #TODO this is a hack ... to prevent the restored player from instantly hitting the chicken
	savePlayer()

func updateLevelLabel():
	if level:
		levelLabel.text = level.name + ": Points: " + var_to_str(levelPoints) + " Time: " + var_to_str(int(levelTime))

func updateHighScoreLabel():
	highScoreLabel.text = "Points: " + var_to_str(points)

func _on_timer_timeout():
	updateLevelLabel()

func loadMainRoom():
	szeneTransition("demo_room")

func onPlayerDeath():
	loadMainRoom()

func startGame():
	mainMenu.hide()
	loadPlayer()
	loadMainRoom()

func _on_level_done_button_pressed():
	call_deferred("loadMainRoom")
	levelEndScreen.hide()

func _on_continue_pressed():
	call_deferred("startGame")

func _on_new_game_pressed():
	ResourceHandler.prune()
	call_deferred("startGame")
