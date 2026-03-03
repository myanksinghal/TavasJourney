extends Control

const SAVE_PATH = "user://first_launch.cfg"

func _ready():
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	# Make sure the name matches your animation exactly (case-sensitive!)
	
	# If the file doesn't exist, it's the first launch
	if err != OK:
		$AnimationPlayer.play("fade_from_black")
		await $AnimationPlayer.animation_finished
		$RichTextLabel.text="Tava comes up to a burnt forest"

		$AnimationPlayer.play("pan_and_zoom")
		config.set_value("level1-2", "visited", true)
		#config.save(SAVE_PATH)
		
		await $AnimationPlayer.animation_finished
		#$RichTextLabel.text="Until the great fire took it away"
		$RichTextLabel.text=""

		
		#$AnimationPlayer.play("burn_animation")
		#await $AnimationPlayer.animation_finished
		#$RichTextLabel.text=""
		
		$RichTextLabel2.text="Maybe she should climb up to see where to go"
		$AnimationPlayer.play("fade_to_black")
		#$RichTextLabel2.text="Will she find her new home?"
		LevelMusic.fade_out()
		await $AnimationPlayer.animation_finished
		var music=preload("res://Assets/Music/Drifting Memories.ogg")
		LevelMusic.play_music(music)
		



	# Transition to your actual main menu
	get_tree().change_scene_to_file("res://Scenes/level2.tscn")
