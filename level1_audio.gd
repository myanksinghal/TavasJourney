extends AudioStreamPlayer2D


@export var fade_duration: float = 3
@export var target_volume: float = 0.0  # 0 dB = normal volume

func _ready():
	volume_db = -80.0   # start silent
	play()

	var tween = create_tween()
	tween.tween_property(self, "volume_db", target_volume, fade_duration)
