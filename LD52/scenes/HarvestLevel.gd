extends Control

export(NodePath) var mouse_bound_sprite_np
onready var mouse_bound_sprite = get_node(mouse_bound_sprite_np) as Sprite

export(NodePath) var cattles_np
onready var cattles = get_node(cattles_np) as Node2D

export(NodePath) var units_np
onready var units = get_node(units_np) as Node2D

export(NodePath) var harvest_completed_panel_np
export(NodePath) var harvest_completed_count_label_np

export(NodePath) var dialog_canvas_layer_np
onready var dialog_canvas_layer = get_node(dialog_canvas_layer_np) as CanvasLayer

onready var harvest_completed_panel = get_node(harvest_completed_panel_np) as Container
onready var harvest_completed_count_label = get_node(harvest_completed_count_label_np) as Label

var selected_unit_slot
var selected_country: CountryData
var mission_started: bool = false
var mission_time_left: float
var misson_time_elapsed: float

var end_harvest_timer_max:float = 5.0
var end_harvest_timer:float = end_harvest_timer_max
var transition_started:bool = false

var security_to_spawn: Array

var no_unit_max_duation: float = 5.0
var no_unit_timer: float = 0.0

func _ready():
	harvest_completed_panel.visible = false
	mouse_bound_sprite.visible = false
	
	#allow debug
	if Game.data.selected_country == null:
		Game.data.selected_country = Game.data.get_world().get_countries()[0]
	
	selected_country = Game.data.selected_country as CountryData
	mission_time_left = selected_country.mission_time
	selected_country.start_harvest_panic_level = selected_country.panic_level
	selected_country.start_harvest_population = selected_country.remaining_population
	selected_country.start_harvest_cattle_juice = Game.data.cattle_juice
	
	spawn_cattles()
	security_to_spawn = selected_country.get_security().duplicate()

func spawn_cattles():	
	var count = min(selected_country.max_cattle_per_harvest, selected_country.remaining_population)
	
	var spawn_margin = 150
	for i in count:
		var cattle = selected_country.cattle_scene.instance()
		cattle.position = Vector2(
			(randi() % int(rect_size.x - spawn_margin)) + spawn_margin,
			(randi() % int(rect_size.y - spawn_margin)) + spawn_margin
		)
		cattle.data = ActorData.new()
		
		cattle.data.max_health = 5
		cattle.data.health = 5
		cattle.data.speed = 50
		cattle.data.max_stamina = selected_country.panic_level * 0.5
		cattle.data.stamina = cattle.data.max_stamina
		cattle.data.stamina_regen_per_second = 0.1
		cattle.data.auto_boost_threshold = 0.2
		cattle.data.boost_stamina_cost_per_second = 1.0
		cattle.data.boost_speed_multiplier = 1.2
		
		cattle.connect("died", self, "on_cattle_died")
		cattles.add_child(cattle)
		
func spawn_security(scene):
	var cattle = scene.instance()
	var spawn_margin = 150
	cattle.position = Vector2(
		(randi() % int(rect_size.x - spawn_margin)) + spawn_margin,
		(randi() % int(rect_size.y - spawn_margin)) + spawn_margin
	)
#	cattle.connect("died", self, "on_cattle_died")
	cattles.add_child(cattle)
	
	if not $ForegroundUI/SecurityAnimationPlayer.is_playing():
		$ForegroundUI/SecurityAnimationPlayer.play("Popup")
	
	yield(get_tree().create_timer(2.0),"timeout")
	show_dialog("CattleSecurity", true)

func show_dialog(dialog_name, once_only:bool):
	if once_only:
		if Game.data.seen_dialogs.has(dialog_name):
			return
		Game.data.seen_dialogs.append(dialog_name)
	
	Game.data.day_paused = true
	var dialog = Dialogic.start(dialog_name)
#	dialog.connect("dialogic_signal", self, "on_dialogic_signal")
	dialog.connect("timeline_end", self, "on_dialogic_timeline_end")
	dialog_canvas_layer.add_child(dialog)

func on_dialogic_timeline_end(timeline):
	Game.data.day_paused = false	
	
func on_cattle_died(cattle):
	if cattle.is_security:
		return
	selected_country.remaining_population -= 1
	$UI/MainHUD.update_cattle_count()

func _on_MainHUD_unit_slot_pressed(unit_slot):
	selected_unit_slot = unit_slot
	mouse_bound_sprite.texture = unit_slot.texture
	mouse_bound_sprite.visible = true

func _input(event):
	if (event is InputEventMouseButton and event.pressed):
		if event.button_index == BUTTON_LEFT:
			if selected_unit_slot != null:
				spawn_unit_or_item(selected_unit_slot)
				selected_unit_slot = null
				mouse_bound_sprite.visible = false
		elif event.button_index == BUTTON_RIGHT:
			mouse_bound_sprite.visible = false
			selected_unit_slot = null
			$UI/MainHUD.update_unit_slots()

func spawn_unit_or_item(unit_slot):
	
	mission_started = true
	
	if unit_slot.unit_type != null:
		var unit_type = unit_slot.unit_type as UnitTypeData
		var unit_scene = unit_type.unit_scene
		unit_type.amount_in_barrack -= 1
		
		var unit = unit_scene.instance()
		unit.position = get_global_mouse_position()
		var data = unit_type.default_unit_data.duplicate() as ActorData
		unit.data = data
		
		var army = Game.data.get_army() as ArmyData
		data.max_health += army.bonus_health
		data.health = unit.data.max_health
		
		data.attack_damage += army.bonus_attack
		data.speed += (army.bonus_speed * 10)
		data.sigth_range += (army.bonus_sight * 50)
		
		units.add_child(unit)
	
	if unit_slot.item_type != null:
		var item_type = unit_slot.item_type as ItemTypeData
		var item_scene = item_type.item_scene
		item_type.amount_in_barrack -= 1
		
		var item = item_scene.instance()
		item.position = get_global_mouse_position()
		units.add_child(item)
		
func _process(delta):
	if not mission_started:
		return
	
	if harvest_completed_panel.visible:
		end_harvest_timer -= delta
		if end_harvest_timer <= 0:
			if not transition_started:
				transition_started = true
				Game.transition_to_scene("res://scenes/EndHarvest.tscn")
		else:
			harvest_completed_count_label.text = str(round(end_harvest_timer))
		return
		
	mission_time_left -= delta
	misson_time_elapsed += delta
	if mission_time_left <= 0:
		end_of_harvest()
		return
		
	if cattles.get_child_count() == 0:
		end_of_harvest()
		return
		
	if units.get_child_count() != 0:
		no_unit_timer = 0.0
	else:
		no_unit_timer += delta
		if no_unit_timer >= no_unit_max_duation:
			end_of_harvest()
			return
		
	for security in security_to_spawn.duplicate():
		if security.spawn_time < misson_time_elapsed:
			for _i in security.amount:
				spawn_security(security.security_scene)
			security_to_spawn.erase(security)

	update_ui()
	
func update_ui():
	var timer_label = $UI/MenuBar/MenuBar/PanelContainer/MaginContainer/HBox/TimeLeftCountLabel
	if no_unit_timer > 0:
		timer_label.text = "No unit left: %s" % str(round(min(no_unit_max_duation - no_unit_timer, mission_time_left)))
	else:
		timer_label.text = str(round(mission_time_left))

func end_of_harvest():
	harvest_completed_panel.visible = true
	
	selected_country.panic_level += min(
	selected_country.max_panic_level, 
	selected_country.panic_level + 1)
