extends AudioStreamPlayer2D

@export var fade_duration: float = 1.5
@export var fade_on_scene_path: String = "res://Scenes/level1.tscn"

func _ready():
	play()
	get_tree().root.child_entered_tree.connect(_on_scene_added)

func _on_scene_added(node: Node):
	# Only react if this is the current main scene
	if node == get_tree().current_scene:
		if node.scene_file_path == fade_on_scene_path:
			if playing:
				fade_out()

func fade_out():
	var tween = create_tween()
	tween.tween_property(self, "volume_db", -80.0, fade_duration)
	await tween.finished
	stop()
