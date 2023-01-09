tool
extends MarginContainer

class_name UnitItemSlot

signal pressed(unit_slot)

export var amount: int setget set_amount

var unit_type
var item_type
export(Texture) var texture setget set_texture

var stat_container_enabled_mouse_position: Vector2

func set_texture(value):
	if $Node2D/Button != null:
		$Node2D/Button.icon = value
	texture = value

func set_amount(value):
	if $Label != null:
		$Label.text = "x%s" % value
	amount = value
		
	if $Node2D/Button != null:
		$Node2D/Button.modulate = Color.white if amount > 0 else Color.gray

func _ready():
	$Node2D/StatContainer.visible = false
	
	if unit_type != null:
		$Node2D/StatContainer/VBoxContainer/NameLabel.text = unit_type.unit_name
		
		var data = unit_type.spawn_data() as ActorData
		$Node2D/StatContainer/VBoxContainer/GridContainer/Health.text = str(data.max_health)
		$Node2D/StatContainer/VBoxContainer/GridContainer/Speed.text = str(data.speed)
		$Node2D/StatContainer/VBoxContainer/GridContainer/Attack.text = str(data.attack_damage)
		$Node2D/StatContainer/VBoxContainer/GridContainer/Sight.text = str(data.sigth_range)
		return
		
	if item_type != null:
		$Node2D/StatContainer/VBoxContainer/NameLabel.text = item_type.item_name
		$Node2D/StatContainer/VBoxContainer/GridContainer.visible = false
		return


func _process(delta):
	if $Node2D/StatContainer.visible:
		$Node2D/StatContainer.rect_position.y = -$Node2D/StatContainer.rect_size.y - 6
		var distance = stat_container_enabled_mouse_position.distance_to(get_global_mouse_position())
		if distance > 40.0:
			$Node2D/StatContainer.visible = false

func _on_Button_pressed():
	$Node2D/StatContainer.visible = false
	emit_signal("pressed", self)

func _on_Button_mouse_entered():
	stat_container_enabled_mouse_position = get_global_mouse_position()
	$Node2D/StatContainer.visible = true
	
func _on_Button_mouse_exited():
	$Node2D/StatContainer.visible = true
