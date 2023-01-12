extends Control

export(NodePath) var dialog_canvas_layer_np
onready var dialog_canvas_layer = get_node(dialog_canvas_layer_np) as CanvasLayer

var init_juice

func _ready():
	init_juice = Game.data.cattle_juice
	$UI/VBoxContainer/HBoxContainer/ItemShopPanel.visible = not Game.data.no_bomb_challenge
	
func _process(delta):
	var tax = Game.data.get_week_tax()
	if init_juice >= tax and Game.data.cattle_juice < tax:
		show_dialog("BigSpender", true)
		
func show_dialog(dialog_name, once_only:bool):
	if Game.data.skip_all_tutorial:
		return
		
	if once_only:
		if Game.data.seen_dialogs.has(dialog_name):
			return
		Game.data.seen_dialogs.append(dialog_name)
	
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
	
func _on_BackButton_pressed():
	SfxManager.play("buttonpress")
	Game.transition_to_scene("res://scenes/WorldMap.tscn")

func _on_UpgradeStatPanel_skill_purchased():
	SfxManager.play("confirm")
	update_ui()
	
func update_ui():
	var skill_panel = $UI/VBoxContainer/HBoxContainer/ForgePanel/MarginContainer/VBoxContainer/SkillPanel
	for skill in skill_panel.get_children():
		skill.update_ui()
	
	$UI/MainHUD.update_unit_slots()

func _on_purchase_done():
	SfxManager.play("confirm")
