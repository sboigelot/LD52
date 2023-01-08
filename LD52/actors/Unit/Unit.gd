extends Actor

class_name Unit

var cattle_nearby : Array
var cattle_target : Cattle

export(NodePath) var np_attack_animation_player
onready var attack_animation_player = get_node_or_null(np_attack_animation_player) as AnimationPlayer

func _on_StateMachinePlayer_transited(from, to):
	time_in_state = 0.0
	
func _on_StateMachinePlayer_updated(state, delta):
	time_in_state += delta
		
	match state:
		"Idle":
			if time_in_state >= idle_time:
				fsm.set_trigger("idle_over")
				
		"Hunt/WanderAndSearchForCattle/ChooseDestination":
			check_for_new_cattle_nearby()
			destination = Vector2(
				rand_range(0.0, get_viewport().size.x),
				rand_range(0.0, get_viewport().size.y)
			)
			fsm.set_trigger("destination_picked")
			
		"Hunt/WanderAndSearchForCattle/WalkToDestination":
			check_for_new_cattle_nearby()
			var distance_to_destination = global_position.distance_to(destination)
			if distance_to_destination >= data.move_threshold:
				var direction = global_position.direction_to(destination)
				move(direction, delta)
				flip_and_animate(direction)
			else:
				fsm.set_trigger("destination_reached")
				
		"Hunt/WanderAndSearchForCattle/Exit":
			fsm.set_trigger("cattle_aquired")
			
		"Hunt/MoveToAttackRange":
			if not cattle_target_in_range_or_alive():
				fsm.set_trigger("cattle_lost")
				cattle_target = null
				return
				
			if cattle_target_in_attack_range_or_alive(0.5):
				fsm.set_trigger("cattle_in_range")
			else:
				var direction = global_position.direction_to(cattle_target.global_position)
				move_or_auto_boost(direction, delta)
				flip_and_animate(direction)

		"Hunt/AttackCattle":
			if not cattle_target_in_attack_range_or_alive():
				fsm.set_trigger("cattle_lost")
				attack_animation_player.stop()
				cattle_target = null
				return
			attack_animation_player.play("Attack")

func attack_cattle():
	if not cattle_target_in_attack_range_or_alive():
		attack_animation_player.stop()
		fsm.set_trigger("cattle_lost")
		return
	
	cattle_target.take_damage(data.attack_damage)
	if cattle_target.data.health <= 0:
		attack_animation_player.stop()
	
func end_attack():
	attack_animation_player.play("RESET")

func check_for_new_cattle_nearby():
	if (not cattle_target_in_range_or_alive() and 
		cattle_nearby.size() > 0):
		cattle_target = cattle_nearby[randi() % cattle_nearby.size()]
		fsm.set_trigger("cattle_aquired")

func cattle_target_in_range_or_alive()->bool:
	if (cattle_target == null or
		not is_instance_valid(cattle_target)):
			return false 
	
	return cattle_nearby.has(cattle_target)
	
func cattle_target_in_attack_range_or_alive(margin:float = 1.0)->bool:
	if not cattle_target_in_range_or_alive():
			return false 
	
	var distance = global_position.distance_to(cattle_target.global_position)
	if distance <= data.attack_range * margin:
		return true
	return false
	
func _on_Area2D_body_entered(body):
	if body is Cattle:
		cattle_nearby.append(body)

func _on_Area2D_body_exited(body):
	if body is Cattle:
		if cattle_nearby.has(body):
			cattle_nearby.erase(body)
