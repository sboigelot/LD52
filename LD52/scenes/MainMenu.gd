extends Control

func _on_StartGameButton_pressed():
	Game.new_game()
	Game.transition_to_scene("res://scenes/WorldMap.tscn")
