extends Area2D

signal mouse_clicked(country)

export var default_color:Color = Color.white
export var mouse_over_color:Color = Color.lightblue
export var mouse_click_color:Color = Color.aqua

func _ready():
	$Sprite.modulate = default_color
	
func _on_MothershipArea2D_mouse_exited():
	$Sprite.modulate = default_color

func _on_MothershipArea2D_mouse_entered():
	$Sprite.modulate = mouse_over_color

func _on_MothershipArea2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:
			$Sprite.modulate = mouse_click_color
		else:
			$Sprite.modulate = mouse_over_color
			emit_signal("mouse_clicked", self)
