extends CanvasLayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()

func _unhandled_input(event):
	if event.is_action_pressed("ui_pause"):
		toggle_pause()

func toggle_pause():
	var paused = !get_tree().paused
	get_tree().paused = paused
	visible = paused

func _on_play_button_pressed() -> void:
	get_tree().paused = false
	hide()
