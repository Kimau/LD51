extends Node3D

var grabbed : RigidBody3D
var prevGrabbed : RigidBody3D
var grabTarget : Vector3
var grabRot : Vector3
var timeSinceCustomer : float = intervalCustomer
var timeSinceJunk : float = -1
var gameRunning = false
var count_good : int = 0
var count_bad : int = 0

@export var floor_plane : Plane
@export var wall_plane : Plane

const junkStart : int = 12
const junkMin : int = 1
const junkMax : int = 4
const intervalJunkMin : float = 4.0
const intervalJunkMax : float = 6.0
const intervalCustomer : float = 10.5

func _init():
	Engine.set_meta("NumCols", 4)
	Engine.set_meta("NumShapes", 4)
	Engine.set_meta("LastTouched", null)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func startGame():
	count_good = 0
	count_bad = 0
	gameRunning = true
	$JunkSrc.clearJunk()
	$CounterTop.newDeal()
	$JunkSrc.dumpJunk(junkStart)
	timeSinceJunk = randf_range(intervalJunkMin, intervalJunkMax)
	timeSinceCustomer = intervalCustomer

func end_game():
	$CanvasLayer/CustTimer.visible = false
	gameRunning = false
	$CounterTop/AnimationPlayer.play("end_game")
	
	var scoreMesh = load("res://score_mesh.tres")
	scoreMesh.text = str("Score: ", count_good)

func _process(dt):
	if not gameRunning:
		return
		
	timeSinceJunk -= dt	
	if timeSinceJunk < 0:
		$JunkSrc.dumpJunk(randi_range(junkMin, junkMax))
		timeSinceJunk = randf_range(intervalJunkMin, intervalJunkMax)
	
	if $CounterTop.waiting:
		$CanvasLayer/CustTimer.visible = false
		timeSinceCustomer = intervalCustomer
	else:
		timeSinceCustomer -= dt
		if ceil(timeSinceCustomer) != ceil(timeSinceCustomer + dt):
			$CanvasLayer/CustTimer.visible = true
			$CanvasLayer/CustTimer.text = str(
				"[center][outline_size=2][outline_color=black][font s=70]",
				ceil(timeSinceCustomer),
				"[/font][/outline_color][/outline_size][/center]")
				
		if timeSinceCustomer < 0:
			$CounterTop._on_bell_ring()
			timeSinceCustomer = intervalCustomer
	
	if prevGrabbed:
		prevGrabbed.sleeping = false
		
	if grabbed == null:
		return
	
	grabbed.sleeping = false
	var r : ShapeCast3D = $RayGrabbedToMouse
	var tp = r.target_position
	if false: #r.collision_result.size() > 0:
		var col = r.collision_result[0]
		tp = col.point + col.normal * 5.0
	
	var newP : Vector3 = lerp(grabbed.global_position, tp, 0.1)
	if false:
		var col : KinematicCollision3D = grabbed.move_and_collide(newP - grabbed.global_position)
		if col != null:
			grabbed.global_position = lerp(grabbed.global_position, newP + floor_plane.normal, 0.2)
	else:
		grabbed.global_position = newP
	
	grabbed.global_rotation = lerp(grabbed.global_rotation, grabRot, 0.1)
		
	r.global_position = grabbed.global_position
	r.target_position = grabTarget
	
func dragGrabbed(event : InputEventMouseMotion):
	var r : ShapeCast3D = $RayCamToMouse
	var c : Camera3D = $Camera3d
	var mPos = event.position
	r.global_position = c.project_position(mPos, 0.1)
	r.target_position = c.project_position(mPos, 50.0)
	
	if grabbed == null:
		return

	if r.collision_result.size() > 0:
		var col = r.collision_result[0]
		grabTarget = col.point + floor_plane.normal * 0.4
	else:
		var camPlane : Plane = Plane(Vector3(0,0,1), grabbed.global_position)
		var cHit = camPlane.intersects_ray(r.global_position, r.target_position)
		grabTarget = cHit
		
	var _fHit = floor_plane.intersects_ray(c.global_position, r.target_position)
	var _wHit = wall_plane.intersects_ray(c.global_position, r.target_position)
	return	
	
func _input(event):
	if not gameRunning:
		return
		
	if event.is_action_pressed("grabJunk"):
		grabbed = Engine.get_meta("LastTouched", null)
		if grabbed != null:
			$CounterTop.grabbed(grabbed)
			grabbed.freeze = true
			grabbed.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
			grabbed.sleeping = false
			grabbed.can_sleep = false
			grabTarget = grabbed.global_position
			grabRot = Vector3(
				round(grabbed.global_rotation.x / 45.0) * 45.0,
				round(grabbed.global_rotation.y / 45.0) * 45.0,
				round(grabbed.global_rotation.z / 45.0) * 45.0)
	elif event.is_action_released("grabJunk"):
		if grabbed != null:
			grabbed.freeze = false
			grabbed.sleeping = false
			$CounterTop.slotMe(grabbed)
			grabbed = null
	
	if event is InputEventMouseMotion:
		dragGrabbed(event)


func _on_sign_new_game():
	$CounterTop/AnimationPlayer.play("start_game")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "start_game":
		startGame()
	if anim_name == "good_deal":
		count_good += 1
	if anim_name == "bad_deal":
		count_bad += 1
		if (count_bad) >= 3:
			end_game()
