extends Node3D

signal PiecesReady(pieceList : Array)
@export var doEditor = false

func _ready():
	PiecesReady.emit(self.get_children().filter(func(node): return node.get_class() == "RigidBody3D"))
	pass
	
func _process(_delta):
	if Engine.is_editor_hint() && doEditor:
		doEditor = false
		for cn in self.get_children():
			_setup_mesh(cn)
			_setup_com(cn)

func _setup_com(node : Node):
	if node.get_class() != "RigidBody3D":
		return
	
	var rb : RigidBody3D = node
	
	var cs = rb.find_child(str(rb.name).replace("P ", "C "))
	if cs == null:
		print("Fucked ", str(rb.name).replace("P ", "C "))
		return
	if cs.get_class() != "CollisionShape3D":
		return
	
	var csp : ConvexPolygonShape3D = cs.shape
	var com = Vector3.ZERO
	for pt in csp.points:
		com += pt
	com /= csp.points.size()
	rb.center_of_mass_mode = 1 # CENTER_OF_MASS_MODE_CUSTOM
	rb.center_of_mass = com
 
		
func _setup_mesh(node : Node):
	if node.get_class() != "MeshInstance3D":
		return
		
	node.transform = Transform3D.IDENTITY
		
	var rb : RigidBody3D = RigidBody3D.new()
	self.add_child(rb)	
	rb.set_owner(get_tree().edited_scene_root)
	var cs : CollisionShape3D = CollisionShape3D.new()
	rb.add_child(cs)
	cs.set_owner(get_tree().edited_scene_root)
	
	
	rb.name = "P " + str(node.name)
	cs.name = "C " + str(node.name)
	rb.freeze = true
	
	self.remove_child(node)
	rb.add_child(node)
	node.set_owner(get_tree().edited_scene_root)
	cs.make_convex_from_siblings()
