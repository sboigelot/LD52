extends Node

class_name GameData

signal end_of_day

export var player_name:String = "Player"

export var cattle_juice: int = 0

export var day_duration: float = 20.0
export var day: float = 0.0
export var time_of_day: float = 0.0

var seen_dialogs: Array

var selected_country: CountryData

func increment_time_of_day(delta):
	time_of_day += delta
	if time_of_day >= day_duration:
		day += 1
		time_of_day = 0.0
		emit_signal("end_of_day")

func get_world():
	return $WorldData

func get_army():
	return $ArmyData
