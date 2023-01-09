extends PanelContainer

class_name RewardCard

signal picked(card)

export var unit_name: String
export var item_name: String
export var cattle_juice: bool

export var texture: Texture setget set_texture
func set_texture(v):
	if $FrontTextureRect != null:
		$FrontTextureRect.texture = v
	
	texture = v
	
export var amount: int setget set_amount
func set_amount(v):
	if $MarginContainer2/CountLabel != null:
		$MarginContainer2/CountLabel.text = "%d" % v
	
	amount = v

export var display_name: String setget set_display_name
func set_display_name(v):
	if $MarginContainer/NameLabel != null:
		$MarginContainer/NameLabel.text = v
	
	display_name = v
	
func _on_PickButton_pressed():
	if modulate == Color.transparent:
		return
	$BackTextureRect.visible = false
	$PickButton.visible = false
	emit_signal("picked", self)
	
func disable():
	$PickButton.disabled = true
