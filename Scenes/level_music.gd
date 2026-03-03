extends AudioStreamPlayer2D
@export var fade_duration: float = 3
@export var target_volume: float = 0.0  # 0 dB = normal volume



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func play_music(music)-> void:
	var volume_db = -80.0   # start silent
	
	LevelMusic.stream=music
	
	GlobalMusic.playing=false
	var tween = create_tween()
	LevelMusic.playing=true
	
	tween.tween_property(LevelMusic, "volume_db", target_volume, fade_duration)
	
	
func fade_out():
	var tween = create_tween()
	tween.tween_property(self, "volume_db", -80.0, fade_duration)
	await tween.finished
	stop()
