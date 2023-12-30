class_name Main extends ResourceHandler

# for menu see https://www.youtube.com/watch?v=Ueivz6JY5Fw

var level : SpawnHandler
var spawnPoint :String
var player : Player

func saveLevel():
	saveNode(level,saveFiles[level.name])

func saveplayer():
	saveNode(player, playerSaveFile)

# Called when the node enters the scene tree for the first time.
func _ready():
	level = null
	spawnPoint = ""
	player = null
	super._ready()
	loadplayer()
	szeneTransition("demo_room")

func loadplayer():
	player = loadIfSaveFileExists("player")
	player.dead.connect(onPlayerDeath)

func onPlayerDeath():
	szeneTransition("demo_room")

func szeneTransition(toSzene : String ,target="SpawnPoint"):
	var new_level = loadIfSaveFileExists(toSzene)
	if new_level:
		if player:
			saveplayer()
		if level:
			saveLevel()
			print("M: cleanup for " + level.name)
			level.cleanup(false)
			remove_child(level)
			level=null
		spawnPoint = target
		level = new_level
		level.loaded.connect(levelCreated)
		add_child(level)
	else:
		print(toSzene, " not found")

func levelCreated():
	level.doorSignal.connect(szeneTransition)
	level.prepare()
	print("W: created ", level.name)
	print("W: searching ", spawnPoint)
	for sp in level.getSpawnPoints():
		if sp.name == spawnPoint:
			Checkpoints.levelspawn = sp.position
			print("Player going to spawn in ", level.name, " at ", sp.name, " ", var_to_str(sp.position))
			level.setupPlayer(player, sp.position)
			return
