extends Node

class_name ArmyData

export var bonus_health: int
export var bonus_attack: int
export var bonus_speed: int
export var bonus_sight: int

func get_unit_types():
	return $UnitTypes.get_children()

func get_item_types():
	return $ItemTypes.get_children()
