extends Node3D

var pieceByShape : Dictionary
var junkQ : int = 0
var lastDump : float = -1

const intervalJunkSpawn : float = 0.1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if(event.is_action_pressed("debugDumpJunk")):
		dumpJunk(1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(dt):
	lastDump -= dt
	if junkQ > 0 && lastDump < 0:
		spawnJunk()
		junkQ -= 1
		lastDump = intervalJunkSpawn
	pass

func dumpJunk(numJunk : int):
	junkQ += numJunk
	
func spawnJunk():
	var newData = PieceData.new()
	newData.regen()
	
	var p : Node = pieceByShape[newData.shapeType][randi() % pieceByShape[newData.shapeType].size()]
	var np : Node = p.duplicate()
	self.add_child(np)
	var rb : RigidBody3D = np as RigidBody3D
	rb.freeze = false
	rb.transform = Transform3D.IDENTITY
	
	np.data = newData

func _on_piece_collection_pieces_ready(pieceList : Array):
	pieceByShape = {}
	for p in pieceList:
		var pi : int = p.pieceType if p.pieceType else 0
		
		if pieceByShape.has(pi):
			pieceByShape[pi].push_back(p)
		else:
			pieceByShape[pi] = [p]
