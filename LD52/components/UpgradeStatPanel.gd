tool
extends MarginContainer

signal skill_purchased

enum BONUS {
	HEATH,
	ATTACK,
	SPEED,
	SIGHT
}

const bonus_label = {
	BONUS.HEATH : "Unit health",
	BONUS.ATTACK : "Unit attack",
	BONUS.SPEED : "Unit speed",
	BONUS.SIGHT : "Unit sight",
}

export(BONUS) var bonus_type setget set_bonus_type

func set_bonus_type(value):
	bonus_type = value
	if $MarginContainer/HBoxContainer/Label != null:
		$MarginContainer/HBoxContainer/Label.text = bonus_label[bonus_type]

func _ready():
	update_ui()

func update_ui():
	if Engine.is_editor_hint():
		return
	
	var skill_level = get_skill_level()
	
	var skill_square_parent = $MarginContainer/HBoxContainer/HBoxContainer
	for i in skill_square_parent.get_child_count():
		var child = skill_square_parent.get_child(i) as ColorRect
		child.color = Color.black if i >= skill_level else Color.green
	
	if skill_level > 4:
		$MarginContainer/HBoxContainer/CostLabel.text = "maxed"
		$BuyButton.visible = false
		$MarginContainer/HBoxContainer/CattleJuiceLabel.visible = false
	else:	
		var next_level_cost = get_next_level_cost()
		$MarginContainer/HBoxContainer/CostLabel.text = str(next_level_cost)
		$BuyButton.disabled = Game.data.cattle_juice < next_level_cost
	
func get_skill_level():
	var army = Game.data.get_army() as ArmyData
	var skill_level = 0
	match bonus_type:
		BONUS.HEATH:
			skill_level = army.bonus_health
		BONUS.ATTACK:
			skill_level = army.bonus_attack
		BONUS.SPEED:
			skill_level = army.bonus_speed
		BONUS.SIGHT:
			skill_level = army.bonus_sight
	skill_level += 1
	return skill_level
	
func get_next_level_cost():
	return get_skill_level() * 10
	
func _on_BuyButton_pressed():
	var next_level_cost = get_next_level_cost()
	if Game.data.cattle_juice < next_level_cost:
		return
		
	Game.data.cattle_juice -= next_level_cost
	
	var army = Game.data.get_army() as ArmyData
	match bonus_type:
		BONUS.HEATH:
			army.bonus_health += 1
		BONUS.ATTACK:
			army.bonus_attack += 1
		BONUS.SPEED:
			army.bonus_speed += 1
		BONUS.SIGHT:
			army.bonus_sight += 1
	
	update_ui()
	emit_signal("skill_purchased")
