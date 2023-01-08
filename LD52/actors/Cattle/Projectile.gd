extends Node2D

var target:Node2D
var damage:int
var speed: float

var hit_threshold: float = 20.0

func _process(delta):
	if target == null or not is_instance_valid(target):
		queue_free()
		return
	
	var distance = global_position.distance_to(target.global_position)
	if distance < hit_threshold:
		target.take_damage(damage)
		queue_free()
		return
		
	var direction = global_position.direction_to(target.global_position)
	var velocity = direction * speed * delta
	global_position += velocity
	
