extends Node2D

export(NodePath) var dialog_canvas_layer_np
onready var dialog_canvas_layer = get_node(dialog_canvas_layer_np) as CanvasLayer

export(NodePath) var countries_np
onready var countries = get_node(countries_np) as Node2D

func _ready():
	var country_datas = Game.data.get_world().get_countries()
	var country_map = {}
	for country in country_datas:
		country_map[country.display_name] = country
	
	for country in countries.get_children():
		country.connect("mouse_clicked", self, "on_country_mouse_clicked")
		
		if country_map.has(country.display_name):
			country.data = country_map[country.display_name]
		else:
			printerr("Country %s not found in data" % country.display_name)
	
	show_dialog("Intro01", true)
	
func show_dialog(dialog_name, once_only:bool):
	
	if once_only:
		if Game.data.seen_dialogs.has(dialog_name):
			return
		Game.data.seen_dialogs.append(dialog_name)
	
	var dialog = Dialogic.start(dialog_name)
	dialog.connect("dialogic_signal", self, "on_dialogic_signal")
	dialog_canvas_layer.add_child(dialog)

func on_dialogic_signal(signal_param):
	
	match signal_param:
		"blink_belgium":
			blink_country("Belgium", Color(1.0, 0.0, 0.0, 0.4), 10, 0.3)
			
func blink_country(display_name, color, times, delay):
	for country in countries.get_children():
		if country.data == null:
			continue
		if country.data.display_name == display_name:
			country.blink(color, times, delay)
			return

func on_country_mouse_clicked(country):
	get_node("%CountryPanel").update_ui(country)

func _process(delta):
	Game.data.increment_time_of_day(delta)

func _on_MothershipArea2D_mouse_clicked(country):
	Game.transition_to_scene("res://scenes/Mothership.tscn")
