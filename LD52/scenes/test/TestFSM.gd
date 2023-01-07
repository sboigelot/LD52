extends Node2D

var accu: float


func _on_StateMachinePlayer_updated(state, delta):
	
	match state:
		"SearchTarget":
			accu += delta
			if accu >= 5.0:
				$StateMachinePlayer.set_trigger("taget_found")

		"Hunt":
			if accu >= 4.0:
				$StateMachinePlayer.set_trigger("taget_dead")

func _on_StateMachinePlayer_transited(from, to):
	print("change state %s -> %s"%[from,to])
	accu = 0
