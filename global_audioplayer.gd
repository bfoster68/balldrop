extends Node

# Pre-built pool of players per sound type.
# Eliminates allocation, scene-tree insertion, and signal connection on every hit.
const POOL_SIZE: int = 16

var _pools: Dictionary = {}

func _ready() -> void:
	var container = preload("res://global_audiocontainer.tscn").instantiate()
	add_child(container)

	for sound_name in ["bell", "kick", "snare", "laser"]:
		var source: AudioStreamPlayer2D = container.get_node_or_null("player_" + sound_name)
		if not source:
			push_error("Sound player for '%s' not found." % sound_name)
			continue

		var pool: Array = []
		for i in range(POOL_SIZE):
			var p: AudioStreamPlayer2D = source.duplicate()
			p.stream = source.stream  # share stream data, don't copy it
			p.autoplay = false
			add_child(p)
			pool.append(p)

		_pools[sound_name] = pool

func play_at(sound_name: String, pos: Vector2, pitch: float) -> void:
	var pool: Array = _pools.get(sound_name, [])
	for player: AudioStreamPlayer2D in pool:
		if not player.playing:
			player.position = pos
			player.pitch_scale = pitch
			player.play()
			return
	# All slots busy — skip rather than allocate
