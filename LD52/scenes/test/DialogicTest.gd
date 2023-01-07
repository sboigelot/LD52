extends Control

export(NodePath) var dialog_canvas_layer_np
onready var dialog_canvas_layer = get_node(dialog_canvas_layer_np) as CanvasLayer

func _on_Button_pressed():
	var dialog = Dialogic.start("Intro01")
	dialog_canvas_layer.add_child(dialog)
