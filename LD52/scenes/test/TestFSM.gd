extends Node2D

var accu: float

func _on_StateMachinePlayer_updated(state, delta):
	accu += delta
	
	match state:
		"SearchTarget":
			if accu >= 5.0:
				$StateMachinePlayer.set_trigger("target_found")

		"Hunt":
			if accu >= 4.0:
				$StateMachinePlayer.set_trigger("target_dead")

func _on_StateMachinePlayer_transited(from, to):
	print("change state %s -> %s"%[from,to])
	accu = 0
