extends Actor

class_name Unit

var cattle_nearby : Array
var cattle_target : Cattle

export(NodePath) var np_attack_animation_player
onready var attack_animation_player = get_node_or_null(np_attack_animation_player) as AnimationPlayer

func _on_StateMachinePlayer_transited(_from, _to):
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
	
	if data.attack_sfx_name != "":
		SfxManager.play(data.attack_sfx_name)
		
	cattle_target.take_damage(data.attack_damage)
	if cattle_target.data.health <= 0:
		attack_animation_player.stop()
	
func end_attack():
	attack_animation_player.play("RESET")

func _on_Unit_took_damage(actor):
	if not Game.data.better_ai:
		return
	if cattle_target == null:
		return
		
	if cattle_target.data.attack_damage > 0:
		return
		
	attack_animation_player.stop()
	attack_animation_player.play("RESET")
	cattle_target = null
	fsm.set_trigger("cattle_lost")
	
func check_for_new_cattle_nearby():
	if (not cattle_target_in_range_or_alive() and 
		cattle_nearby.size() > 0):
		if not Game.data.better_ai:
			cattle_target = cattle_nearby[randi() % cattle_nearby.size()]
		else:
			cattle_target = closest_cattle_nearby(true)
		
		if cattle_target != null:
			fsm.set_trigger("cattle_aquired")

func closest_cattle_nearby(prioritize_hostile):
	if cattle_nearby.size() == 0:
		return null
		
	var closest_cattle = null
	var min_distance = 100000
	
	var closest_military_cattle = null
	var closest_military_min_distance = 100000

	for cattle in cattle_nearby:
		var distance = global_position.distance_to(cattle.global_position)
		if distance < min_distance:
			closest_cattle = distance
			closest_cattle = cattle
			
		if cattle.data.attack_damage != 0:
			if distance < closest_military_min_distance:
				closest_military_min_distance = distance
				closest_military_cattle = cattle

	if prioritize_hostile and closest_military_cattle != null:
		return closest_military_cattle
		
	return closest_cattle
	
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
		
		if not Game.data.better_ai:
			return
			
		if body.data.attack_damage > 0:
			if cattle_target != null and cattle_target.data.attack_damage > 0:
				return
			cattle_target = null
			fsm.set_trigger("cattle_lost")

func _on_Area2D_body_exited(body):
	if body is Cattle:
		if cattle_nearby.has(body):
			cattle_nearby.erase(body)

