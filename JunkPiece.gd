extends RigidBody3D

# Called when the node enters the scene tree for the first time.
func _ready():
	var cs = CollisionShape3D.new()
	var s = SphereShape3D.new()
	s.radius = 0.1
	cs.shape = s
	self.add_child(cs)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if transform.origin.y < -5.0:
		transform = Transform3D.IDENTITY
