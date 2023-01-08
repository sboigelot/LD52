extends Sprite

export var mouse_pickup_range:float = 50.0
var picked = false

export var max_speed:float = 1500.0
export var speed_curve: Curve
export var destination:Vector2 = Vector2(1300, 0)
export var time_since_picked_up: float
var move_threshold:float = 20.0

func _process(delta):
	if picked:
		time_since_picked_up +=  delta
		move_to_destination(delta)
		return
		
	var mouse_pos = get_global_mouse_position()
	var distance = global_position.distance_to(mouse_pos)
	if distance >= mouse_pickup_range:
		return
	
	picked = true
	
func move_to_destination(delta):
	if global_position.distance_to(destination) < move_threshold:
		reach_destination()
		return
		
	var direction = global_position.direction_to(destination)
	var speed = speed_curve.interpolate(time_since_picked_up) * max_speed
	var velocity = direction * speed * delta
	global_position += velocity
		
func reach_destination():
	Game.data.cattle_juice += 1
	queue_free()
			
