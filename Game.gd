extends Node3D

var grabbed : RigidBody3D
var prevGrabbed : RigidBody3D
var grabTarget : Vector3
var grabRot : Vector3
@export var floor_plane : Plane
@export var wall_plane : Plane

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
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
			grabbed.can_sleep = true
			$CounterTop.slotMe(grabbed)
			grabbed = null
	
	if event is InputEventMouseMotion:
		dragGrabbed(event)
