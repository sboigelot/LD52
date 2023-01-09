tool
extends Node2D

class_name WorldMapCountry

signal mouse_clicked(country)

export var display_name: String
export var polygon: PoolVector2Array setget set_polygon
export var default_color:Color = Color.white
export var defeated_color:Color = Color.red
export var mouse_over_color:Color = Color.lightblue
export var mouse_click_color:Color = Color.aqua

export var anihilated_label_np: NodePath
onready var anihilated_label = get_node(anihilated_label_np)

var data: CountryData

func set_polygon(values:PoolVector2Array):
	if $Polygon2D != null:
		$Polygon2D.polygon = values
	if $Area2D/CollisionPolygon2D != null:
		$Area2D/CollisionPolygon2D.polygon = values
	polygon = values

export(NodePath) var polygon2d_np
onready var polygon2d = get_node(polygon2d_np) as Polygon2D

func _ready():
	if Engine.is_editor_hint():
		return
		
	polygon2d.color = default_color
	anihilated_label.visible = false

func _process(delta):
	if Engine.is_editor_hint():
		return
		
	if data == null:
		return
		
	if data.remaining_population == 0:
		polygon2d.color = defeated_color
		anihilated_label.visible = true		

func _on_Area2D_mouse_entered():
	polygon2d.color = mouse_over_color

func _on_Area2D_mouse_exited():
	polygon2d.color = default_color

func _on_Area2D_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:
			polygon2d.color = mouse_click_color
		else:
			polygon2d.color = mouse_over_color
			emit_signal("mouse_clicked", self)

func blink(color, times, delay):
	for _i in times:
		polygon2d.color = color
		yield(get_tree().create_timer(delay), "timeout")
		polygon2d.color = default_color
		yield(get_tree().create_timer(delay), "timeout")
