extends Control

export(NodePath) var mouse_bound_sprite_np
onready var mouse_bound_sprite = get_node(mouse_bound_sprite_np) as Sprite

export(NodePath) var cattles_np
onready var cattles = get_node(cattles_np) as Node2D

export(NodePath) var units_np
onready var units = get_node(units_np) as Node2D

export(NodePath) var harvest_completed_panel_np
export(NodePath) var harvest_completed_count_label_np

onready var harvest_completed_panel = get_node(harvest_completed_panel_np) as Container
onready var harvest_completed_count_label = get_node(harvest_completed_count_label_np) as Label

var selected_unit_slot
var selected_country: CountryData
var mission_time_left: float

var end_harvest_timer_max:float = 5.0
var end_harvest_timer:float = end_harvest_timer_max
var transition_started:bool = false

func _ready():
	harvest_completed_panel.visible = false
	mouse_bound_sprite.visible = false
	
	#allow debug
	if Game.data.selected_country == null:
		Game.data.selected_country = Game.data.get_world().get_countries()[0]
	
	selected_country = Game.data.selected_country as CountryData
	mission_time_left = selected_country.mission_time
	spawn_cattles()

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
		cattle.connect("died", self, "on_cattle_died")
		cattles.add_child(cattle)

func on_cattle_died(cattle):
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
				spawn_unit(selected_unit_slot)
				selected_unit_slot = null
				mouse_bound_sprite.visible = false
		elif event.button_index == BUTTON_RIGHT:
			mouse_bound_sprite.visible = false

func spawn_unit(unit_slot):
	var unit_scene = unit_slot.unit_type.unit_scene
	unit_slot.unit_type.amount_in_barrack -= 1
	var unit = unit_scene.instance()
	unit.position = get_global_mouse_position()
	unit.data = ActorData.new()
	unit.data.speed = 100
	
	units.add_child(unit)

func _process(delta):
	if harvest_completed_panel.visible:
		end_harvest_timer -= delta
		if end_harvest_timer <= 0:
			if not transition_started:
				transition_started = true
				Game.transition_to_scene("res://scenes/WorldMap.tscn")
		else:
			harvest_completed_count_label.text = str(round(end_harvest_timer))
		return
		
	mission_time_left -= delta
	if mission_time_left <= 0:
		end_of_harvest()
		return
		
	if cattles.get_child_count() == 0:
		end_of_harvest()
		return

	update_ui()
	
func update_ui():
	var timer_label = $UI/MenuBar/MenuBar/PanelContainer/MaginContainer/HBox/TimeLeftCountLabel
	timer_label.text = str(round(mission_time_left))

func end_of_harvest():
	harvest_completed_panel.visible = true
	
	selected_country.panic_level += 1
	
	for cattle in cattles.get_children():
		cattle.paused = true
		
	for child in units.get_children():
		if child is Unit:
			child.paused = true
