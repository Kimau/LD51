extends Node3D

var pieceCollection : Array

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if(event.is_action_pressed("debugDumpJunk")):
		dumpJunk()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func dumpJunk():
	var i : int = randi_range(0, pieceCollection.size()-1)
	var p : Node = pieceCollection[i]
	var np : Node = p.duplicate()
	self.add_child(np)
	var rb : RigidBody3D = np as RigidBody3D
	rb.freeze = false
	rb.transform = Transform3D.IDENTITY
	# np.emit_signal("regenPiece") - self emit on Ready

func _on_piece_collection_pieces_ready(pieceList : Array):
	pieceCollection = pieceList
