extends Node

class_name CountryData

export var display_name:String
export var initial_population: int
export var remaining_population: int
export var max_cattle_per_harvest: int
export var security_level: int
export var panic_level: int
export var max_panic_level: int = 5

export var mission_time: float
export(PackedScene) var cattle_scene

var start_harvest_population: int
var start_harvest_panic_level: int
var start_harvest_cattle_juice: int

func get_bonus_cards():
	return $Bonus.get_children()

func get_security():
	return $Security.get_children()
