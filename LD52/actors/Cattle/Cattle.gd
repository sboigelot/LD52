extends Actor

class_name Cattle

export var juice_scene: PackedScene

func _on_StateMachinePlayer_transited(from, to):
	time_in_state = 0.0

func _on_StateMachinePlayer_updated(state, delta):
	if paused:
		return
	
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
				move(direction)
				flip_and_animate(direction)
			else:
				fsm.set_trigger("destination_reached")

func on_death():
	.on_death()
	
	if juice_scene == null:
		return
		
	var instance = juice_scene.instance() as Node2D
	instance.global_position = global_position
	var map = get_parent().get_parent()
	map.add_child(instance)
