extends Control

var selected_country: CountryData

export(NodePath) var stat_panel_pop_np
onready var stat_panel_pop = get_node(stat_panel_pop_np) as HarvestStatPanel

export(NodePath) var stat_panel_panic_np
onready var stat_panel_panic = get_node(stat_panel_panic_np) as HarvestStatPanel

export(NodePath) var stat_panel_juice_np
onready var stat_panel_juice = get_node(stat_panel_juice_np) as HarvestStatPanel

export(NodePath) var dialog_canvas_layer_np
onready var dialog_canvas_layer = get_node(dialog_canvas_layer_np) as CanvasLayer

var anim_time = 2
	
func _ready():
	#allow debug
	if Game.data.selected_country == null:
		Game.data.selected_country = Game.data.get_world().get_countries()[0]
		selected_country = Game.data.selected_country as CountryData
		selected_country.start_harvest_panic_level = 4
		selected_country.panic_level = selected_country.start_harvest_panic_level + 1
		selected_country.start_harvest_population = 10
		selected_country.remaining_population = 1
		selected_country.start_harvest_cattle_juice = Game.data.cattle_juice - 5
	
	$UI/ButtonBar/ButtonBar/MaginContainer/HBox/BackButton.disabled = true
	$UI/VBoxContainer/BackButton.disabled = true
	$UI/VBoxContainer/BackButton.modulate = Color.transparent
	
	selected_country = Game.data.selected_country as CountryData
	
	$UI/VBoxContainer/HBoxContainer/StatPanel/MarginContainer/VBoxContainer/CountryNameLabel.text = selected_country.display_name
	
	randomize_cards()
	
	stat_panel_pop.max_value = selected_country.initial_population
	stat_panel_pop.value = selected_country.start_harvest_population
	
	stat_panel_panic.max_value = selected_country.max_panic_level
	stat_panel_panic.value = selected_country.start_harvest_panic_level
	
	stat_panel_juice.max_value = Game.data.cattle_juice
	stat_panel_juice.value = selected_country.start_harvest_cattle_juice
	
	stat_panel_juice.modulate = Color.transparent
	stat_panel_panic.modulate = Color.transparent
	$UI/VBoxContainer/CardRewardPanel.modulate = Color.transparent
	
	yield(get_tree().create_timer(1.0),"timeout")
	
	stat_panel_pop.anim_value_to(selected_country.remaining_population, anim_time)
	
		
func raise_world_panic():
	for country in Game.data.get_world().get_children():
			country.panic_level = min(country.panic_level + 1, country.max_panic_level)

func randomize_cards():
	var bonus_card_data = selected_country.get_bonus_cards()
	
	if Game.data.no_bomb_challenge:
		for card_data in bonus_card_data.duplicate():
			if card_data.item_name == "":
				bonus_card_data.probability = 0
		
	var card_grid = $UI/VBoxContainer/CardRewardPanel/VBoxContainer/RewardCardGrid
	for card_node in card_grid.get_children():
		var card_data = WeightedRandom.pickp(bonus_card_data, "probability")
		set_card_data(card_node, card_data)
	
func set_card_data(card_node:RewardCard, card_data:BonusCardData):
	card_node.unit_name = card_data.unit_name
	card_node.item_name = card_data.item_name
	card_node.cattle_juice = card_data.is_juice
	card_node.amount = card_data.amount
	card_node.display_name = card_data.display_name
	card_node.texture = card_data.texture

func _on_BackButton_pressed():
	SfxManager.play("buttonpress")
	Game.transition_to_scene("res://scenes/WorldMap.tscn")

func _on_RewardCard_picked(card:RewardCard):
	SfxManager.play("buttonpress")
	var card_parent = card.get_parent()
	for child in card_parent.get_children():
		if child != card:
			child.disable()

	$UI/ButtonBar/ButtonBar/MaginContainer/HBox/BackButton.disabled = false
	$UI/VBoxContainer/BackButton.disabled = false
	$UI/VBoxContainer/BackButton.modulate = Color.white
	
	if card.unit_name != "" or card.item_name != "":
		Game.data.add_to_army([card.unit_name], [card.item_name], card.amount)
		$UI/MainHUD.update_unit_slots()
		
	if card.cattle_juice:
		Game.data.cattle_juice += card.amount

func _on_PopStatPanel_animation_completed():
	stat_panel_juice.modulate = Color.white
	stat_panel_juice.anim_value_to(Game.data.cattle_juice, anim_time)

func _on_JuiceStatPanel_animation_completed():
	stat_panel_panic.modulate = Color.white
	stat_panel_panic.anim_value_to(selected_country.panic_level, anim_time)

func _on_PanicStatPanel_animation_completed():
	if selected_country.remaining_population == 0:
		raise_world_panic()
		show_dialog("CountryDead")
		return
		
	if selected_country.start_harvest_panic_level != selected_country.panic_level:
		if selected_country.panic_level >= selected_country.max_panic_level:
			raise_world_panic()
			show_dialog("WorldPanic")
			return
	
	$UI/VBoxContainer/CardRewardPanel.modulate = Color.white

func show_dialog(dialog_name):
	Game.data.day_paused = true
	var dialog = Dialogic.start(dialog_name)
#	dialog.connect("dialogic_signal", self, "on_dialogic_signal")
	dialog.connect("timeline_end", self, "on_dialogic_timeline_end")
	dialog.connect("letter_displayed", self, "on_dialogic_letter_displayed")
	dialog_canvas_layer.add_child(dialog)

func on_dialogic_letter_displayed(letter):
	Game.voice_gen(letter)
	
func on_dialogic_timeline_end(timeline):
	Game.data.day_paused = false
	$UI/VBoxContainer/CardRewardPanel.modulate = Color.white
