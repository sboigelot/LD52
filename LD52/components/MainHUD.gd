extends PanelContainer

export var unit_slot_scene:PackedScene
export var title: String = "World Map"
export var show_mother_ship_text: bool = true
export var unit_slot_clickable:bool = true

signal unit_slot_pressed(unit_slot)

func _ready():
	$TopBar/MaginContainer/HBox/WorldMapLabel.text = title
	$BottomBar/MaginContainer/HBox/MarginContainer2.visible = show_mother_ship_text
	$BottomBar/MaginContainer/HBox/WorldMapLabel.visible = show_mother_ship_text
	update_unit_slots()
	
func update_unit_slots():
	var unit_slot_placeholder = $BottomBar/MaginContainer/HBox/UnitInventory
	for child in unit_slot_placeholder.get_children():
		child.queue_free()
	
	var army = Game.data.get_army() as ArmyData
	var unit_types = army.get_unit_types()
	
	for unit_type in unit_types:
		var unit_item_slot = unit_slot_scene.instance() as UnitItemSlot
		unit_item_slot.spawned_unit = unit_type.unit_scene
		unit_item_slot.texture = unit_type.button_texture
		unit_item_slot.amount = unit_type.amount_in_barrack
		unit_item_slot.connect("pressed", self, "_on_UnitItemSlot_pressed")
		unit_slot_placeholder.add_child(unit_item_slot)
		
func _on_UnitItemSlot_pressed(unit_slot):
	if not unit_slot_clickable:
		return
		
	if unit_slot.amount <= 0:
		return
	
	unit_slot.amount -= 1
	emit_signal("unit_slot_pressed", unit_slot)

func _process(delta):
	update_ui()
	
func update_ui():
	if Game.data == null:
		return
		
	var data = Game.data as GameData
	
	var juice_count_label = $TopBar/MaginContainer/HBox/JuicePanelContainer/MarginContainer/HBoxContainer/DayCountLabel
	juice_count_label.text = "%05d" % data.cattle_juice
