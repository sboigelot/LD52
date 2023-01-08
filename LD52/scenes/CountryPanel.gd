extends PanelContainer

export(NodePath) var country_name_label_np
export(NodePath) var init_pop_label_np
export(NodePath) var remain_pop_label_np
export(NodePath) var secu_lvl_label_np
export(NodePath) var panic_lvl_label_np
export(NodePath) var harvest_button_np

onready var country_name_label = get_node(country_name_label_np) as Label
onready var init_pop_label = get_node(init_pop_label_np) as Label
onready var remain_pop_label = get_node(remain_pop_label_np) as Label
onready var secu_lvl_label = get_node(secu_lvl_label_np) as Label
onready var panic_lvl_label = get_node(panic_lvl_label_np) as Label
onready var harvest_button = get_node(harvest_button_np) as Button

var world_country
var country_data: CountryData

func _ready():
	visible = false

func update_ui(country):
	world_country = country
	country_data = world_country.data
	if country_data == null:
		visible = false
		return
		
	visible = true
	country_name_label.text = country_data.display_name
	init_pop_label.text = "%d Mil" % country_data.initial_population
	remain_pop_label.text = "%d Mil" % country_data.remaining_population
	if country_data.remaining_population <= 0:
		remain_pop_label.text = "Harvested"	
	secu_lvl_label.text = str(country_data.security_level)
	panic_lvl_label.text = str(country_data.panic_level)
	harvest_button.disabled = country_data.remaining_population == 0
	
func _on_HarvestButton_pressed():
	Game.transition_to_scene("res://scenes/HarvestLevel.tscn")
