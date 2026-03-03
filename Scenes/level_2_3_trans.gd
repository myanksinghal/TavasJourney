extends Control

const SAVE_PATH = "user://first_launch.cfg"

func _ready():
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	# Make sure the name matches your animation exactly (case-sensitive!)
	
	# If the file doesn't exist, it's the first launch
	if err != OK:
		GlobalMusic.fade_out()
		#LevelMusic.fade_out()
		var music=preload("res://Assets/Music/Wanderers Tale.ogg")
		LevelMusic.play_music(music)
		$RichTextLabel.text="She comes across the distant mountain at the edge of the forest"

		$AnimationPlayer.play("zoom_out_up")
		config.set_value("level2-3", "visited", true)
		#config.save(SAVE_PATH)
		
		await $AnimationPlayer.animation_finished
		$RichTextLabel.text=""
		$RichTextLabel2.text="Maybe if she climbs up to the peak she can escape."
		
		$AnimationPlayer.play("fade_to_black")
		await $AnimationPlayer.animation_finished
		
		
		
	
	# Transition to your actual main menu
	get_tree().change_scene_to_file("res://Scenes/level3.tscn")
