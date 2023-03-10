extends Node

export(PackedScene) var game_data_scene
var data: GameData

func _ready():
	new_game() # for debug singl components
	randomize()
	
func new_game():
	if data != null:
		data.queue_free()
	
	data = game_data_scene.instance()
	add_child(data)

func transition_to_scene(scene_path):
	var colors = [
		Color.black,
		Color.blueviolet,
		Color.goldenrod,
		Color.purple,
		Color.sienna
	]

	var textures = [
		load("res://addons/node_library/assets/transition-texture.png"),
		load("res://addons/node_library/assets/screen-transition-alternate.png"),
		load("res://addons/node_library/assets/screen-transition-alternate2.png"),
#		load("res://addons/node_library/assets/screen-transition-alternate3.png")
	]

	var color_index = randi() % colors.size()
	var texture_index = randi() % textures.size()
	ScreenTransition.set_transition_color(colors[color_index])
	ScreenTransition.set_transition_texture(textures[texture_index])
	ScreenTransition.transition_to_scene(scene_path)

func _input(_event):
	if Input.is_action_just_released("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen

func voice_gen(text):
	$VoiceGeneratorAudioStreamPlayer.read(text)
