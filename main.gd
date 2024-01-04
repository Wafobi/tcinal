class_name Main extends ResourceHandler

# for menu see https://www.youtube.com/watch?v=Ueivz6JY5Fw
# for paralex background : https://www.youtube.com/watch?v=f8z4x6R7OSM

var level : SpawnHandler
var spawnPoint :String
var player : Player

var levelTime : float

func saveLevel():
	saveNode(level,saveFiles[level.name])

func saveplayer():
	saveNode(player, playerSaveFile)

# Called when the node enters the scene tree for the first time.
func _ready():
	levelTime = 0.0
	level = null
	spawnPoint = ""
	player = null
	super._ready()
	loadplayer()
	SzeneTransition.done.connect(activatePlayer)
	szeneTransition("fields")

func loadplayer():
	player = loadIfSaveFileExists("player")
	player.dead.connect(onPlayerDeath)
	player.setupDone.connect(onPlayerSetupDone)

func onPlayerSetupDone():
	print("Player ready in ", level.name)
	var levelLabel : Label = getLevelLabel()
	var highScoreLabel : Label = getHighScoreLabel()
	match level.name:
		"demo_room" :
			updateHighScoreLabel()
			levelLabel.hide()
			highScoreLabel.show()
		_ :
			updateLevelLabel()
			highScoreLabel.hide()
			levelLabel.show()

func activatePlayer():
	print("GO")
	player.active = true

func _process(delta):
	if player.active:
		levelTime += delta

func onPlayerDeath():
	szeneTransition("demo_room")

func fadeIn():
	SzeneTransition.fadeIn()
	await SzeneTransition.done
	
func fadeOut():
	SzeneTransition.fadeOut()
	await SzeneTransition.done

func szeneTransition(toSzene : String ,target="SpawnPoint"):
	if not toSzene:
		return
	fadeIn()
	var new_level = loadIfSaveFileExists(toSzene)
	if new_level:
		if player:
			player.active = false
			saveplayer()
		if level:
			saveLevel()
			print("M: cleanup for " + level.name)
			level.cleanup(false)
			remove_child(level)
			level=null
		Checkpoints.last_checkpoint = null
		spawnPoint = target
		level = new_level
		level.loaded.connect(levelCreated)
		level.levelDone.connect(levelDone)
		add_child(level)
	else:
		fadeOut()
		print(toSzene, " not found")

func levelCreated():
	levelTime = 0.0
	levelPoints = 0
	feathers = 0
	level.doorSignal.connect(szeneTransition)
	level.prepare()
	for feather : Feather in level.getFeathers():
		feather.collected.connect(featherCollected)
	print("W: created ", level.name)
	print("W: searching ", spawnPoint)
	for sp in level.getSpawnPoints():
		if sp.name == spawnPoint:
			Checkpoints.levelspawn = sp.position
			print("Player going to spawn in ", level.name, " at ", sp.name, " ", var_to_str(sp.position))
			level.setupPlayer(player, sp.position)
			fadeOut()
			return

var levelPoints = 0
var points = 0
var feathers = 0
func featherCollected(feather : Feather):
	feathers+=1
	levelPoints += feather.points
	points += feather.points
	updateLevelLabel()

func levelDone(levelName):
	player.active = false
	player.velocity = Vector2.ZERO
	player.gravity = 50
	print("Player finish ", levelName, " duration ", int(levelTime))
	print(" points from level ", levelPoints, " all points ", points)
	print(" Feathers: ", feathers, "/", len(level.getFeathers()))
#	levelLabel.hide()
#	highScoreLabel.hide()


func updateLevelLabel():
	var levelLabel = getLevelLabel()
	levelLabel.text = level.name + ": Points: " + var_to_str(levelPoints) + " Time: " + var_to_str(int(levelTime))

func updateHighScoreLabel():
	var highscoreLabel = getHighScoreLabel()
	highscoreLabel.text = "Points: " + var_to_str(points)

func getHighScoreLabel() -> Label :
	return $CanvasLayer/MarginContainer/Highscore/HighScorePoints

func getLevelLabel() -> Label :
	return $CanvasLayer/MarginContainer/LevelStats/LevelPoints

func _on_timer_timeout():
	updateLevelLabel()

func _on_level_done_button_pressed():
	call_deferred("szeneTransition","demo_room")
