tool
extends MarginContainer

class_name UnitItemSlot

signal pressed(unit_slot)

export var amount: int setget set_amount

var unit_type
export(Texture) var texture setget set_texture

func set_texture(value):
	if $Node2D/Button != null:
		$Node2D/Button.icon = value
	texture = value

func set_amount(value):
	if $Label != null:
		$Label.text = "x%s" % value
	amount = value
		
	if $Node2D/Button != null:
		$Node2D/Button.modulate = Color.white if amount > 0 else Color.gray

func _on_Button_pressed():
	emit_signal("pressed", self)
