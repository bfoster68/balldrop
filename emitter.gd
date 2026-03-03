extends Node2D

const MAX_BALLS: int = 200

@export_enum("bell", "kick", "snare", "laser")
var sound: String = "bell"

@onready var BallScene = preload("res://ball.tscn")

var angle := 0
var cached_notes: Array = []

func _ready():
	cached_notes = gen_notes()

func _on_timer_timeout() -> void:
	var containers = get_tree().get_nodes_in_group("ball_container")
	if containers.size() == 0:
		push_error("No node found in 'ball_container' group!")
		return

	var container = containers[0]
	if container.get_child_count() >= MAX_BALLS:
		return

	var ball = BallScene.instantiate()
	ball.position = position
	ball.sound = sound
	ball.vel = Vector2(4, 0).rotated(deg_to_rad(angle + 45))
	ball.notes = cached_notes
	container.add_child(ball)

	angle = (angle + 90) % 360


func gen_notes() -> Array:
	var notes: Array = []

	seed(3) # consistent seeding
	randi()

	var base_pitch = 0.06

	var note1 = randi() % 12
	var note2 = randi() % 12
	var note3 = randi() % 12

	notes.append(2 * base_pitch)
	notes.append(pow(2, 1 + note1 / 12.0) * base_pitch)
	notes.append(pow(2, 1 + note2 / 12.0) * base_pitch)
	notes.append(pow(2, 1 + note3 / 12.0) * base_pitch)

	for i in range(100):
		var n1 = notes[-1]
		var n2 = notes[-2]
		var n3 = notes[-3]
		var n4 = notes[-4]

		# Stop before pitch_scale values exceed what audio hardware handles well
		if maxf(maxf(n1, n2), maxf(n3, n4)) * 2.0 > 4.0:
			break

		notes.append(n1 * 2)
		notes.append(n2 * 2)
		notes.append(n3 * 2)
		notes.append(n4 * 2)

	return notes
