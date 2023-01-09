extends PanelContainer

export(NodePath) var country_name_label_np
export(NodePath) var init_pop_label_np
export(NodePath) var remain_pop_label_np
export(NodePath) var secu_lvl_label_np
export(NodePath) var secu_lvl_hbox_np
export(NodePath) var panic_lvl_label_np
export(NodePath) var panic_lvl_hbox_np
export(NodePath) var harvest_button_np

onready var country_name_label = get_node(country_name_label_np) as Label
onready var init_pop_label = get_node(init_pop_label_np) as Label
onready var remain_pop_label = get_node(remain_pop_label_np) as Label
onready var secu_lvl_label = get_node(secu_lvl_label_np) as Label
onready var secu_lvl_hbox = get_node(secu_lvl_hbox_np) as Container
onready var panic_lvl_label = get_node(panic_lvl_label_np) as Label
onready var panic_lvl_hbox = get_node(panic_lvl_hbox_np) as Container
onready var harvest_button = get_node(harvest_button_np) as Button

export(NodePath) var world_view_np
onready var world_view = get_node(world_view_np)

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
		remain_pop_label.text = "None"	
	secu_lvl_label.text = str(country_data.security_level)
	show_child_color_rect(secu_lvl_hbox, country_data.security_level)
	panic_lvl_label.text = str(country_data.panic_level)
	show_child_color_rect(panic_lvl_hbox, country_data.panic_level)
	harvest_button.disabled = country_data.remaining_population == 0

func show_child_color_rect(container:Container, count:int):
	for i in container.get_child_count():
		var child = container.get_child(i) as ColorRect
		child.color = Color.transparent if i > count else Color.red


func _on_HarvestButton_pressed():
	
	if country_data.security_level > 0:
		if world_view.show_dialog("CountrySecurity", true):
			return
	
	Game.transition_to_scene("res://scenes/HarvestLevel.tscn")
