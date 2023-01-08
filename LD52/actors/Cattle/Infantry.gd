extends Cattle

class_name Infrantry

export(NodePath) var np_attack_animation_player
onready var attack_animation_player = get_node_or_null(np_attack_animation_player) as AnimationPlayer

var alien_target

func _on_StateMachinePlayer_updated(state, delta):
	time_in_state += delta
		
	match state:
		"Idle":
			if time_in_state >= idle_time:
				fsm.set_trigger("idle_over")
				
		"Hunt/WanderAndSearchForAlien/ChooseDestination":
			check_for_new_alien_nearby()
			destination = Vector2(
				rand_range(0.0, get_viewport().size.x),
				rand_range(0.0, get_viewport().size.y)
			)
			fsm.set_trigger("destination_picked")
			
		"Hunt/WanderAndSearchForAlien/WalkToDestination":
			check_for_new_alien_nearby()
			var distance_to_destination = global_position.distance_to(destination)
			if distance_to_destination >= data.move_threshold:
				var direction = global_position.direction_to(destination)
				move(direction, delta)
				flip_and_animate(direction)
			else:
				fsm.set_trigger("destination_reached")
				
		"Hunt/WanderAndSearchForAlien/Exit":
			fsm.set_trigger("alien_aquired")
			
		"Hunt/MoveToAttackRange":
			if not alien_target_in_range_or_alive():
				fsm.set_trigger("alien_lost")
				alien_target = null
				return
				
			if alien_target_in_attack_range_or_alive(0.5):
				fsm.set_trigger("alien_in_range")
			if not data.attack_is_melee and alien_target_in_attack_range_or_alive(0.9):
				fsm.set_trigger("alien_in_range")
			else:
				var direction = global_position.direction_to(alien_target.global_position)
				move_or_auto_boost(direction, delta)
				flip_and_animate(direction)

		"Hunt/AttackAlien":
			if not alien_target_in_attack_range_or_alive():
				fsm.set_trigger("alien_lost")
				attack_animation_player.stop()
				alien_target = null
				return
			attack_animation_player.play("Attack")

func attack_alien():
	if not alien_target_in_attack_range_or_alive():
		attack_animation_player.stop()
		fsm.set_trigger("alien_lost")
		return
		
	if data.attack_is_melee:
		attack_alien_melee()
	else:
		attack_alien_range()
		
func attack_alien_melee():	
	alien_target.take_damage(data.attack_damage)
	if alien_target.data.health <= 0:
		attack_animation_player.stop()

func attack_alien_range():
	var projectile_parent = get_parent()
	var projectile = data.range_attack_projectile_scene.instance()
	projectile.global_position = global_position
	projectile.target = alien_target
	projectile.damage = data.attack_damage
	projectile.speed = data.range_attack_projectle_speed
	projectile_parent.add_child(projectile)

func end_attack():
	attack_animation_player.play("RESET")

func check_for_new_alien_nearby():
	if (not alien_target_in_range_or_alive() and 
		alien_nearby.size() > 0):
		alien_target = alien_nearby[randi() % alien_nearby.size()]
		fsm.set_trigger("alien_aquired")

func alien_target_in_range_or_alive()->bool:
	if (alien_target == null or
		not is_instance_valid(alien_target)):
			return false 
	
	return alien_nearby.has(alien_target)
	
func alien_target_in_attack_range_or_alive(margin:float = 1.0)->bool:
	if not alien_target_in_range_or_alive():
			return false 
	
	var distance = global_position.distance_to(alien_target.global_position)
	if distance <= data.attack_range * margin:
		return true
	return false
	
