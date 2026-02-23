extends Control

const SAVE_PATH = "user://first_launch.cfg"

func _ready():
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	# Make sure the name matches your animation exactly (case-sensitive!)
	
	# If the file doesn't exist, it's the first launch
	if err != OK:
		$AnimationPlayer.play("intro_pan")
		config.set_value("intro_scene", "visited", true)
		#config.save(SAVE_PATH)
		await $AnimationPlayer.animation_finished
		$AnimationPlayer.play("fade_to_black")
		await $AnimationPlayer.animation_finished
		
	
	# Transition to your actual main menu
	get_tree().change_scene_to_file("res://Scenes/forest_scene.tscn")
