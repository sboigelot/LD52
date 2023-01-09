extends Node

class_name UnitTypeData

export var unit_name: String
export var unit_scene: PackedScene
export var button_texture: Texture
export var amount_in_barrack: int

export(Resource) var default_unit_data

func spawn_data():
	var army = Game.data.get_army() as ArmyData
	
	var data = default_unit_data.duplicate() as ActorData
	data.max_health += army.bonus_health
	data.health = data.max_health
	
	data.attack_damage += army.bonus_attack
	data.speed += (army.bonus_speed * 10)
	data.max_stamina += (army.bonus_speed * 0.5)
	data.stamina = data.max_stamina
	data.sigth_range += (army.bonus_sight * 50)
	
	return data
