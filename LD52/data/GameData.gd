extends Node

class_name GameData

signal end_of_day
signal end_of_week

export var player_name:String = "Player"

export var cattle_juice: int = 12

export var day_duration: float = 10.0
export var day: int = 1
export var time_of_day: float = 0.0
export var day_paused:bool = false
export var missed_taxes_once: bool = false

var seen_dialogs: Array

var selected_country: CountryData
var selected_delivery: DeliveryData

func increment_time_of_day(delta):
	if day_paused:
		return
	
	selected_delivery = null
	
	time_of_day += delta
	if time_of_day >= day_duration:
		day += 1
		time_of_day = 0.0
		emit_signal("end_of_day")
		if day % 7 == 0:
			emit_signal("end_of_week")

func get_week():
	return floor(day / 7) + 1
	
func get_week_tax():
	return get_tax_for_week(get_week())
	
func get_last_week_tax():
	return get_tax_for_week(get_week() - 1)
	
func get_tax_for_week(week):
	return week * 10

func get_world():
	return $WorldData

func get_army():
	return $ArmyData
	
func get_deliveries():
	return $Deliveries

func get_initial_cattle_sum():
	var world_data = get_world()
	var sum = 0
	for country in world_data.get_countries():
		sum += country.initial_population
	return sum
	
func get_current_cattle_sum():
	var world_data = get_world()
	var sum = 0
	for country in world_data.get_countries():
		sum += country.remaining_population
	return sum

func add_delivery(unit_name, item_name, amount):
	if selected_delivery == null:
		selected_delivery = DeliveryData.new()
		selected_delivery.time_to_delivery = 2 * day_duration
		get_deliveries().add_child(selected_delivery)
		
	if unit_name != "":
		for i in amount:
			selected_delivery.unit_names.append(unit_name)

	if item_name != "":
		for i in amount:
			selected_delivery.item_names.append(item_name)

func on_delivery_arrived(data:DeliveryData):
	add_to_army(data.unit_names, data.item_names)
	
func add_to_army(unit_names, item_names, amount = 1):
	var army = Game.data.get_army()
	for unit_name in unit_names:
		for unit_type in army.get_unit_types():
			if unit_type.unit_name == unit_name:
				unit_type.amount_in_barrack += amount
				break
	
	for item_name in item_names:
		for item_type in army.get_item_types():
			if item_type.item_name == item_name:
				item_type.amount_in_barrack += amount
				break
	
	
