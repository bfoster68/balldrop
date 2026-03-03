extends Node

var container: Node

func _ready() -> void:
	container = preload("res://global_audiocontainer.tscn").instantiate()
	add_child(container)  # So nodes like `get_node("player_*")` work

func play_at(sound_name: String, pos: Vector2, pitch: float) -> void:
	var original_player: AudioStreamPlayer2D = container.get_node_or_null("player_" + sound_name)
	if not original_player:
		push_error("Sound player for '%s' not found in container." % sound_name)
		return

	# Duplicate and configure the player
	var player: AudioStreamPlayer2D = original_player.duplicate()
	player.stream = original_player.stream.duplicate()
	player.position = pos
	player.pitch_scale = pitch
	player.autoplay = false

	# Add to scene and play
	get_tree().root.add_child(player)
	player.play()

	# Free it after playback
	player.finished.connect(player.queue_free)
