extends Node2D

class_name Delivery

signal delivered(data)

var data: DeliveryData

var origin: Vector2
var destination: Vector2
var move_threshold:float = 20.0

func _process(delta):
	if data == null:
		queue_free()
		return
	
	if Game.data.day_paused:
		return
	
	data.travel_time += delta
	
	if data.travel_time > data.time_to_delivery:
		emit_signal("delivered", data)
		queue_free()
		return
		
	var percent_of_travel = data.travel_time / data.time_to_delivery
	var travelled = origin.distance_to(destination) * percent_of_travel
	global_position = origin.move_toward(destination, travelled)
	
