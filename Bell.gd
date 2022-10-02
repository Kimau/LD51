extends Area3D

var lightOn : bool = false
var dealGood : bool = false
@export var colorGood : Color
@export var colorBad : Color
signal ring

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var bl : OmniLight3D = $BellLight
	if bl == null:
		return
	if dealGood:
		bl.light_color = colorGood
	else:
		bl.light_color = colorBad
		
	if lightOn:
		bl.light_energy = lerp(bl.light_energy, 2.0, 0.3)
	else:
		bl.light_energy = lerp(bl.light_energy, 0.0, 0.8)

func _input(event):
	if lightOn && event.is_action_pressed("grabJunk"):
		ring.emit()

func _mouse_enter():
	lightOn = true

func _mouse_exit():
	lightOn = false

#
