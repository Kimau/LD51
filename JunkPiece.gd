extends RigidBody3D

var meshInst : GeometryInstance3D
var mouseTime

@export var pieceType : GlobalEnum.PieceType
var data : PieceData
var colorCached : Color
signal regenPiece

func _init():
	data = PieceData.new()
	
func _ready():
#	var cs = CollisionShape3D.new()
#	var s = SphereShape3D.new()
#	s.radius = 0.1
#	cs.shape = s
#	self.add_child(cs)
	
	var kids = self.get_children()
	meshInst = kids.filter(func(node): return node.get_class() == "MeshInstance3D")[0]
	
	regen()	
	self.connect("regenPiece", regen)	
	pass # Replace with function body.
	
func regen():
	data.regen(pieceType)
	colorCached = data.getColorCached()

func _mouse_enter():
	mouseTime = Time.get_ticks_msec()
	sleeping = false
	Engine.set_meta("LastTouched", self)

func _mouse_exit():
	if self.freeze:
		pass
	if self == Engine.get_meta("LastTouched"):
		Engine.set_meta("LastTouched", null)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# Emission
	var emitCol = Color.BLACK
	
	if self.freeze:
		var c1 = colorCached
		var c2 = colorCached
		c1.h -= 0.01
		c2.h += 0.01
		emitCol = lerp(c1,c2, sin(Time.get_ticks_msec() / 100.0))
	elif mouseTime != null:
		var emitVal = 0.0
		var mt = Time.get_ticks_msec() - mouseTime
		if 1000.0 > mt:
			emitVal = (1000.0 - mt) / 1000.0
		else:
			mouseTime = null
		emitCol = lerp(Color.BLACK, colorCached, emitVal)
	
	
	meshInst.set_instance_shader_parameter("Color", colorCached)
	meshInst.set_instance_shader_parameter("Emission", emitCol)
	if transform.origin.y < -5.0:
		transform = Transform3D.IDENTITY
