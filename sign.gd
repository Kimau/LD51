extends Node3D

signal newGame

func _ready():
	$SpotLight3d.visible = false


func _input(event):
	if event.is_action_pressed("grabJunk"):
		if $SpotLight3d.visible:
			newGame.emit()


func _on_area_3d_mouse_entered():
	$SpotLight3d.visible = true


func _on_area_3d_mouse_exited():
	$SpotLight3d.visible = false
