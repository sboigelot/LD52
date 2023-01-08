tool
extends MarginContainer

class_name HarvestStatPanel

export var stat_name: String setget set_stat_name
func set_stat_name(value):
	
	if $MarginContainer/VBoxContainer/HBoxContainer/StatLabel != null:
		$MarginContainer/VBoxContainer/HBoxContainer/StatLabel.text = value
		
	stat_name = value

export var max_value: int setget set_max_value
func set_max_value(v):

	if $MarginContainer/VBoxContainer/HBoxContainer/ProgressBar != null:
		$MarginContainer/VBoxContainer/HBoxContainer/ProgressBar.max_value = v
		
	max_value = v
	self.set_increment_text("+0")

export var value: int setget set_value
func set_value(v):
	if $MarginContainer/VBoxContainer/HBoxContainer/CostLabel != null:
		$MarginContainer/VBoxContainer/HBoxContainer/CostLabel.text = "%d" % v
	
	if $MarginContainer/VBoxContainer/HBoxContainer/ProgressBar != null:
		$MarginContainer/VBoxContainer/HBoxContainer/ProgressBar.value = v
		
	value = v

export var increment_text: String setget set_increment_text
func set_increment_text(v):
	if $MarginContainer/VBoxContainer/HBoxContainer/IncrementLabel != null:
		$MarginContainer/VBoxContainer/HBoxContainer/IncrementLabel.text = v
	
	increment_text = v

export var info_hint: String setget set_info_hint
func set_info_hint(value):
	
	if $MarginContainer/VBoxContainer/InfoLabel != null:
		$MarginContainer/VBoxContainer/InfoLabel.text = value
		$MarginContainer/VBoxContainer/InfoLabel.visible = value != ""
		
	info_hint = value

func anim_value_to(to:int, delay:float):
	var increment = to - value
	
	var add = increment > 0
	increment = abs(increment)
	
	for i in increment:
		if add:
			self.value += 1
			self.increment_text = "+%d" % (i+1)
		else:
			self.value -= 1
			self.increment_text = "-%d" % (i+1)
		yield(get_tree().create_timer(delay / abs(increment)), "timeout")
