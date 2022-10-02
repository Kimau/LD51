extends Node3D

@export var trigger : Area3D
@export var slots : Array

var numPieces : int = 0
var inSlot : Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	trigger.body_entered.connect(body_enter_trigger)
	trigger.body_exited.connect(body_exit_trigger)
	#trigger.mouse_entered.connect(mouse_enter_trigger)
	#trigger.mouse_exit.connect(mouse_exit_trigger)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	for k in inSlot:
		_processSlot(inSlot[k], get_node(slots[k]))
	pass

func _processSlot(p, tarSlot):
	const timeToLerp = 350.0
	if p == null:
		return
	p[0].freeze = true
	if p[1] < 0:
		return
		
	var timeInSlot = Time.get_ticks_msec() - p[1]
	if timeInSlot > timeToLerp:
		var tSecs = (timeInSlot - timeToLerp) * 0.001
		var pickupTrans : Transform3D = Transform3D(
			tarSlot.global_transform.basis.rotated(Vector3(0,1,0), PI * 0.3 * sin(tSecs * 1)),
			tarSlot.global_position + Vector3(0,0.1,0) * (1.0 - cos(tSecs * 5)))
		p[0].global_transform = pickupTrans
		return
	if tarSlot == null:
		return
	
	p[0].global_position = lerp(p[2].origin, tarSlot.global_position, timeInSlot / timeToLerp)
	p[0].global_transform.basis = lerp(p[2].basis, tarSlot.global_transform.basis, timeInSlot / timeToLerp)

func grabbed(piece : RigidBody3D):
	for k in inSlot:
		if inSlot[k] == null:
			continue
		if inSlot[k][0] != piece:
			continue
		inSlot[k] = null
		numPieces -= 1
		
func slotMe(piece : RigidBody3D):
	var s : int = piece.get_meta("CounterTop", -1)
	if(s < 0):
		return
	
	piece.freeze = true
	inSlot[s] = [piece, Time.get_ticks_msec(), piece.global_transform]
	numPieces += 1
	
func body_enter_trigger(body : Node3D):
	if numPieces >= slots.size():
		return
	body.set_meta("CounterTop", numPieces)	
	pass
	
func body_exit_trigger(body : Node3D):
	body.set_meta("CounterTop", -1)
	pass
	
func mouse_enter_trigger():
	pass
	
func mouse_exit_trigger():
	pass
