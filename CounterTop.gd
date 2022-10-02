extends Node3D

@export var trigger : Area3D
@export var animGood : Animation

var inSlot : Dictionary = {}
var custReq : Array = []
var dealGood : bool = false
var waiting : bool = false

var node_slots : Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	trigger.body_entered.connect(body_enter_trigger)
	trigger.body_exited.connect(body_exit_trigger)
	node_slots = { 
		0:[$Slot1, $Slot1/Req1, false, $Slot1/MagicCircle1],
		1:[$Slot2, $Slot2/Req2, false, $Slot2/MagicCircle2],
		2:[$Slot3, $Slot3/Req3, false, $Slot3/MagicCircle3],
		3:[$Slot4, $Slot4/Req4, false, $Slot4/MagicCircle4] 
	}
	custReq = [{},{},{},{}]
	inSlot = {0:null, 1:null, 2:null, 3:null}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	for k in inSlot:
		_processSlot(k)
	pass

func _processSlot(k):
	var p = inSlot[k] 
	var tarSlot = node_slots[k][0]
	const timeToLerp = 350.0
	if p == null:
		node_slots[k][3].visible = true
		return
	node_slots[k][3].visible = false
	p[0].freeze = true
	if p[1] < 0:
		return
		
	var timeInSlot = Time.get_ticks_msec() - p[1]
	if timeInSlot > timeToLerp:
		var tSecs = (timeInSlot - timeToLerp) * 0.001
		
		var pickupTrans : Transform3D
		if node_slots[k][2]:
			pickupTrans = Transform3D(
				tarSlot.global_transform.basis.rotated(Vector3(0,1,0), PI * 0.3 * sin(tSecs * 1)),
				tarSlot.global_position + Vector3(0,0.1,0) * (1.0 - cos(tSecs * 5)))
		else:
			pickupTrans = Transform3D(
				tarSlot.global_transform.basis.rotated(Vector3(0,1,0), PI * 0.05 * sin(tSecs * 0.01)),
				tarSlot.global_position + Vector3(0,-0.03,0) * (1.0 - cos(tSecs * 0.1)))
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
	if piece.has_meta("CounterTop"):
		if piece.get_meta("CounterTop") == -100:
			body_enter_trigger(piece)
	evalDeal()
		
func slotMe(piece : RigidBody3D):
	var s : int = piece.get_meta("CounterTop", -1)
	if(s < 0):
		return
	
	piece.freeze = true
	inSlot[s] = [piece, Time.get_ticks_msec(), piece.global_transform]
	evalDeal()

func _on_bell_ring():
	var ap : AnimationPlayer = $AnimationPlayer
	waiting = true
	$Bell.visible = false
	if dealGood:
		ap.play("good_deal")
	else:
		ap.play("bad_deal")
	
	for k in node_slots:
		node_slots[k][0].visible = false
		
	for k in inSlot:
		if inSlot[k] == null:
			return false
		inSlot[k][0].queue_free()
		inSlot[k] = null
	dealGood = false

func newDeal():
	dealGood = false
	var numSlots : int = randi_range(2,4)
	for k in node_slots:
		custReq[k] = {}
		node_slots[k][0].visible = false
		if numSlots <= 0:
			continue
		node_slots[k][0].visible = true
		var reqSprite : Sprite3D = node_slots[k][1]
		custReq[k] = PieceData.newReq()
		for cr in custReq[k]:
			reqSprite.region_rect.position = Vector2(2*32, 0*32);
			reqSprite.set_instance_shader_parameter("ColorParameter", Color.WHITE)
			if cr == "colorIdx":
				var col : Color = PieceData.getColorCached(custReq[k]["colorIdx"])
				reqSprite.set_instance_shader_parameter("ColorParameter", col)
			if cr == "shapeType":
				match custReq[k]["shapeType"]:
					GlobalEnum.PieceType.Letter:
						reqSprite.region_rect.position = Vector2(1*32, 0*32);
					GlobalEnum.PieceType.Bell:
						reqSprite.region_rect.position = Vector2(0*32, 1*32);
					GlobalEnum.PieceType.Rod:
						reqSprite.region_rect.position = Vector2(4*32, 1*32);
					GlobalEnum.PieceType.Corner:
						reqSprite.region_rect.position = Vector2(1*32, 1*32);
					GlobalEnum.PieceType.Triangle:
						reqSprite.region_rect.position = Vector2(2*32, 1*32);
					GlobalEnum.PieceType.Jigsaw:
						reqSprite.region_rect.position = Vector2(3*32, 1*32);
		numSlots -= 1
		
	waiting = false
	$Bell.visible = true
	pass # custReq

func evalDeal():
	dealGood = _subEvalDeal()
	
func _subEvalDeal():
	var gd = true
	for k in node_slots:
		node_slots[k][2] = true
		if custReq[k] == null or custReq[k] == {}:
			continue
			
		if inSlot[k] == null:
			node_slots[k][2] = false
			print(str(k, " : empty"))
			gd = false
			continue
			
		var p = inSlot[k]
		for t in custReq[k]:
			var a = p[0].data[t]
			var b = custReq[k][t]
			if a != b:
				print(str(k, " : ", t, " [", a, "!=", b))
				node_slots[k][2] = false
				gd = false
	return gd
	
func body_enter_trigger(body : Node3D):
	for k in inSlot:
		if custReq[k] == null || custReq[k] == {}:
			continue
		if inSlot[k] == null:
			body.set_meta("CounterTop", k)
			return
		
	body.set_meta("CounterTop", -100)
	pass
	
func body_exit_trigger(body : Node3D):
	body.set_meta("CounterTop", -1)
	pass

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "good_deal":
		newDeal()
	if anim_name == "bad_deal":
		newDeal()	
