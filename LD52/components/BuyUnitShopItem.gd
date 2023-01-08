tool
extends MarginContainer


export(Texture) var texture setget set_texture

func set_texture(value):
	if $MarginContainer/HBoxContainer/TextureRect != null:
		$MarginContainer/HBoxContainer/TextureRect.texture = value
	texture = value
	
export var amount: int setget set_amount

func set_amount(value):
	if $MarginContainer/HBoxContainer/TextureRect/AmoutLabel != null:
		$MarginContainer/HBoxContainer/TextureRect/AmoutLabel.text = "x%d" % value
		$MarginContainer/HBoxContainer/TextureRect/AmoutLabel.visible = value > 1
	amount = value
	
export var cost: int setget set_cost

func set_cost(value):
	if $MarginContainer/HBoxContainer/CostLabel != null:
		$MarginContainer/HBoxContainer/CostLabel.text = str(value)
	cost = value

export var unit_name:String
export var item_name:String

func _process(delta):
	if Engine.editor_hint:
		return
		
	if Game.data == null:
		return
		
	$BuyButton.disabled = Game.data.cattle_juice < cost


func _on_BuyButton_pressed():
	if Game.data.cattle_juice < cost:
		return
	
	$FloatingLabel/AnimationPlayer.play("Popup")
	
	Game.data.cattle_juice -= cost
	Game.data.add_delivery(unit_name, item_name, amount)
