class_name Main extends ResourceHandler

# for menu see https://www.youtube.com/watch?v=Ueivz6JY5Fw

var startLevel = "fields"

var level = null
var spawnPoint = Vector2(0,0)

var player : Player = null

func saveLevel():
	saveNode(level,saveFiles[level.name])

func saveplayer():
	saveNode(player, playerSaveFile)

# Called when the node enters the scene tree for the first time.
func _ready():
	loadplayer()
	szeneTransition(startLevel)

func loadplayer():
	player = loadIfSaveFileExists("player")
	player.dead.connect(onPlayerDeath)

func onPlayerDeath():
	level.cleanup(true)

func szeneTransition(toSzene : String ,target="SpawnPoint"):
	spawnPoint = target
	if player:
		saveplayer()
	if level:
		saveLevel()
		print("M: cleanup for " + level.name)
		level.cleanup(false)
		remove_child(level)
		level=null

	level = loadIfSaveFileExists(toSzene)
	level.loaded.connect(levelCreated)
	add_child(level)

func levelCreated():
	print("W: created " + level.name)
	level.doorSignal.connect(szeneTransition)
	level.prepare()
	print("W: searching ", spawnPoint)
	for sp in level.getSpawnPoints():
		if sp.name == spawnPoint:
			print("Player going to spawn in " + level.name + " at " + sp.name + " " + var_to_str(sp.position))
			level.setupPlayer(player, sp.position)
			return
