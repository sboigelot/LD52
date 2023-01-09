extends Actor

class_name Cattle

export var juice_scene: PackedScene
export var is_security: bool = false

export(Array, SpriteFrames) var sprite_frames = []
export(Array, Color) var hair_colors = []
export(Array, Color) var tshirt_colors = []

var alien_nearby : Array

var duration_without_direction_change = 3.0
var timer_without_direction_change = 0.0

func _ready():
	if hair_colors.size() == 0:
		return
	apply_shader_color(
		hair_colors[randi() % hair_colors.size()],
		tshirt_colors[randi() % hair_colors.size()]		
	)
	animated_sprite.frames = sprite_frames[randi() % sprite_frames.size()]

func _on_StateMachinePlayer_transited(_from, _to):
	time_in_state = 0.0

func _on_StateMachinePlayer_updated(state, delta):
	time_in_state += delta
	
	match state:		
		"Idle":
			if time_in_state >= idle_time:
				fsm.set_trigger("idle_over")
				
		"Wander/ChooseDestination":
			destination = Vector2(
				rand_range(0.0, get_viewport().size.x),
				rand_range(0.0, get_viewport().size.y)
			)
			fsm.set_trigger("destination_picked")
			
		"Wander/WalkToDestination":
			var distance_to_destination = global_position.distance_to(destination)
			if distance_to_destination >= data.move_threshold:
				var direction = global_position.direction_to(destination)
				move(direction, delta)
				flip_and_animate(direction)
			else:
				fsm.set_trigger("destination_reached")

		"Wander/Exit":
			fsm.set_trigger("alien_nearby")
		
		"Flee":
			if alien_nearby.size() == 0:
				fsm.set_trigger("no_alien_nearby")
				return
				
			var sum_direction_of_aliens = Vector2(0, 0)
			for alien in alien_nearby:
				var direction = global_position.direction_to(alien.global_position)
				sum_direction_of_aliens += direction
			
			var average_direction_of_aliens = sum_direction_of_aliens / alien_nearby.size()
			var direction = average_direction_of_aliens * -1
			
			direction = bound_direction(direction, delta)
			
			boost(direction, delta)
			flip_and_animate(direction)

func bound_direction(direction, delta):
	
	if timer_without_direction_change > 0:
		timer_without_direction_change -= delta
		return global_position.direction_to(Vector2(1920/2, 1080/2))
	
	if (global_position.x > 1820 or 
				global_position.x < 100 or
				global_position.y > 980 or
				global_position.y < 100):
					timer_without_direction_change = duration_without_direction_change
					direction = global_position.direction_to(Vector2(1920/2, 1080/2))  
	return direction

func on_death():
	.on_death()
	
	if juice_scene == null:
		return
		
	var instance = juice_scene.instance() as Node2D
	instance.global_position = global_position
	var map = get_parent().get_parent()
	map.add_child(instance)

func _on_VisionArea2D_body_entered(body):
#	if body is Unit:
	alien_nearby.append(body)
	fsm.set_trigger("alien_nearby")

func _on_VisionArea2D_body_exited(body):
#	if body is Unit:
	if alien_nearby.has(body):
		alien_nearby.erase(body)

func apply_shader_color(hair_color:Color, tshirt_color:Color):
	animated_sprite.get_material().set_shader_param("NEWCOLOR1", hair_color)
	animated_sprite.get_material().set_shader_param("NEWCOLOR2", tshirt_color)
