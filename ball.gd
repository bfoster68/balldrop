extends Node2D

# === Constants ===
const GRAVITY: float = 20.0
const MAX_Y: float = 2000.0
const RESTITUTION: float = 0.8
const COLLISION_OFFSET: float = 0.1

# === Variables ===
var vel: Vector2 = Vector2.ZERO
var prevpos: Vector2 = Vector2.ZERO
var sound: String = "bell" # Default; should be assigned dynamically as needed
var notes: Array = [] # Make sure this is populated before running

var colliders: Array = []

@onready var spr = $spr
@onready var parts = $parts

func _ready():
	prevpos = position
	colliders = get_tree().get_nodes_in_group("line")

	var goalcol: Color

	match sound:
		"bell":
			goalcol = Color(0, 1, 1)
		"kick":
			goalcol = Color(1, 0, 0)
		"snare":
			goalcol = Color(0, 1, 0)
		"laser":
			goalcol = Color(1, 1, 0)
		_:
			goalcol = Color(1, 1, 1)

	spr.modulate = goalcol
	parts.modulate = goalcol * 0.3


func _physics_process(delta: float) -> void:
	if position.y > MAX_Y:
		queue_free()
		return

	# Basic gravity and motion
	vel += Vector2.DOWN * GRAVITY * delta
	prevpos = position
	position += vel

	# Collision with custom line segments
	for c in colliders:
		if not is_instance_valid(c):
			continue
		var p1 = c.a
		var p2 = c.b
		var norm = (p2 - p1).orthogonal().normalized()

		var coll = Geometry2D.segment_intersects_segment(prevpos, position, p1, p2)
		if coll:
			if vel.length() > 1.0:
				var pitch = vel.length()
				if sound != "bell":
					pitch *= 2

				# Index safety check
				if notes.size() > 0:
					var index = clamp(round(pitch), 0, notes.size() - 1)
					pitch = notes[index]
					pitch += randf_range(-1, 1) * 0.002
					AudioPlayer.play_at(sound, position, pitch)

			# Flip norm to oppose velocity so the pushout moves the ball back
			# to the side it came from. reflect() and slide() are invariant
			# to sign of norm, so only the pushout on the next line is affected.
			if vel.dot(norm) > 0:
				norm = -norm

			# Reflect and slide with restitution
			vel = (-vel.reflect(norm)).lerp(vel.slide(norm), 1.0 - RESTITUTION)
			position = coll + norm * COLLISION_OFFSET

			# Spawn shockwave
			var shockwave = preload("res://shockwave.tscn").instantiate()
			shockwave.position = position
			shockwave.modulate = spr.modulate
			get_parent().add_child(shockwave)
