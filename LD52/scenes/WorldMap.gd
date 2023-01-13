extends Node2D

export(PackedScene) var delivery_scene

export(NodePath) var dialog_canvas_layer_np
onready var dialog_canvas_layer = get_node(dialog_canvas_layer_np) as CanvasLayer

export(NodePath) var countries_np
onready var countries = get_node(countries_np) as Node2D

export(NodePath) var dayshadow_np
onready var dayshadow = get_node(dayshadow_np) as Node2D

func _ready():
	$ForegroundUI/SpeedBar/SpeedBar/MaginContainer/HBox/PauseButton.text = "Unpause" if Game.data.day_paused else "Pause"
	$ForegroundUI/SpeedBar/SpeedBar/MaginContainer/HBox/PauseButton.pressed = Game.data.day_paused
	
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
	
	Game.data.connect("end_of_day", self, "on_end_of_day")
	Game.data.connect("end_of_week", self, "on_end_of_week")

	$MothershipArea2D/AnimationPlayer.play("Hover")

	show_dialog("Intro01", true)
	
	spawn_deliveries()
	
	var cattle_sum = Game.data.get_current_cattle_sum()
	if cattle_sum == 0:
		show_dialog("victory", false)
	elif cattle_sum < Game.data.get_initial_cattle_sum(): 
		show_dialog("FirstBackInWorld", true)
		
func _on_QuitButton_pressed():
	show_dialog("QuitGame", false)
	
func show_dialog(dialog_name, is_tutorial:bool)->bool:
	if Game.data.skip_all_tutorial and is_tutorial:
		return false
		
	if is_tutorial:
		if Game.data.seen_dialogs.has(dialog_name):
			return false
		Game.data.seen_dialogs.append(dialog_name)
	
	Game.data.day_paused = true
	var dialog = Dialogic.start(dialog_name)
	dialog.connect("dialogic_signal", self, "on_dialogic_signal")
	dialog.connect("timeline_end", self, "on_dialogic_timeline_end")
	dialog.connect("letter_displayed", self, "on_dialogic_letter_displayed")
	dialog_canvas_layer.add_child(dialog)
	return true

func on_end_of_day():
	Dialogic.set_variable("days", Game.data.day)

func on_end_of_week():
	var weektax = Game.data.get_last_week_tax()
	Dialogic.set_variable("weektax", weektax)
	Dialogic.set_variable("nextweektax", Game.data.get_week_tax())
	
	if Game.data.cattle_juice >= weektax:
		show_dialog("EndWeekTaxOk", false)
	elif not Game.data.missed_taxes_once:
		Game.data.missed_taxes_once = true
		show_dialog("EndWeekTaxNokFirst", false)
	else:
		show_dialog("EndWeekTaxNokLast", false)
	
func on_dialogic_signal(signal_param):
	match signal_param:
		"blink_belgium":
			blink_country("Belgium", Color(1.0, 0.0, 0.0, 0.4), 10, 0.3)
		
		"pay_taxes":
			Game.data.cattle_juice -= Game.data.get_last_week_tax()
			
		"game_over":
			Game.transition_to_scene("res://scenes/MainMenu.tscn")
			
		"skip_all":
			Game.data.skip_all_tutorial = true
			
		"confirm_harvest":
			Game.transition_to_scene("res://scenes/HarvestLevel.tscn")
			
		"quit_game":
			Game.transition_to_scene("res://scenes/MainMenu.tscn")
			
	
func on_dialogic_timeline_end(timeline):
	Game.data.day_paused = false	
	
func on_dialogic_letter_displayed(letter):
	Game.voice_gen(letter)

func blink_country(display_name, color, times, delay):
	for country in countries.get_children():
		if country.data == null:
			continue
		if country.data.display_name == display_name:
			country.blink(color, times, delay)
			return

func on_country_mouse_clicked(country):
	Game.data.selected_country = country.data
	get_node("%CountryPanel").update_ui(country)

func _process(delta):
	Game.data.increment_time_of_day(delta)
	update_day_shadow()

func _on_MothershipArea2D_mouse_clicked(country):
	SfxManager.play("buttonpress")
	Game.transition_to_scene("res://scenes/Mothership.tscn")
	
func update_day_shadow():
	var max_offset = 1920
	var percent_of_day = Game.data.time_of_day / Game.data.day_duration
	dayshadow.position.x = max_offset * percent_of_day

func spawn_deliveries():
	for delivery in Game.data.get_deliveries().get_children():
		spawn_delivery(delivery)
		
func spawn_delivery(data:DeliveryData):
	var delivery = delivery_scene.instance() as Delivery
	delivery.data = data
	delivery.origin = $DeliverySpawnPosition2D.global_position
	delivery.destination = $DeliveryDestinationPosition2D.global_position
	delivery.connect("delivered", self, "on_delivery_delivered")
	$Deliveries.add_child(delivery)
	
func on_delivery_delivered(data:DeliveryData):
	Game.data.on_delivery_arrived(data)
	$ForegroundUI/MainHUD.update_unit_slots()

func _on_PauseButton_toggled(button_pressed):
	SfxManager.play("buttonpress")
	$ForegroundUI/SpeedBar/SpeedBar/MaginContainer/HBox/PauseButton.text = "Unpause" if button_pressed else "Pause"
	Game.data.day_paused = button_pressed
