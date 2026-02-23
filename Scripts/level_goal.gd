extends Area2D

# This variable shows up in the Inspector so you can pick the next file
@export_file("*.tscn") var next_scene_path: String

# This is the function we just connected via the Signal tab
func _on_body_entered(body: Node2D):
	# We only want to change levels if the 'body' is our Player
	if body.name == "Player" or body is CharacterBody2D:
		if next_scene_path != "":
			get_tree().change_scene_to_file(next_scene_path)
		else:
			print("Error: You forgot to set the next_scene_path in the Inspector!")
