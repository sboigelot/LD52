extends Control

func _on_BackButton_pressed():
	Game.transition_to_scene("res://scenes/WorldMap.tscn")


func _on_UpgradeStatPanel_skill_purchased():
	update_ui()
	
func update_ui():
	
	var skill_panel = $UI/VBoxContainer/HBoxContainer/ForgePanel/MarginContainer/VBoxContainer/SkillPanel
	for skill in skill_panel.get_children():
		skill.update_ui()
