extends Node

const MIN_LINE_LENGTH: float = 10.0
const LINE_PICK_RADIUS: float = 10.0

var current_line: Node2D = null
var p1: Vector2
var p2: Vector2

var last_mouse_pos: Vector2

@onready var camera: Camera2D = $cam
@onready var LineScene: PackedScene = preload("res://line.tscn")
@onready var EmitterScene: PackedScene = preload("res://emitter.tscn")

func _ready() -> void:
	await get_tree().create_timer(5).timeout

	spawn_emitter("bell", Vector2(0.3, 0.2))
	spawn_emitter("kick", Vector2(0.3, 0.6))
	spawn_emitter("snare", Vector2(0.7, 0.2))
	spawn_emitter("laser", Vector2(0.7, 0.6))

func spawn_emitter(sound_name: String, pos: Vector2) -> void:
	var emitter = EmitterScene.instantiate()
	emitter.sound = sound_name
	emitter.position = pos * Vector2(get_window().size)
	add_child(emitter)

func _process(delta: float) -> void:
	last_mouse_pos = camera.get_global_mouse_position()
	p2 = last_mouse_pos

	if current_line != null:
		current_line.set_ends(p1, p2)

func _input(event: InputEvent) -> void:
	if event.is_action_released("ui_cancel"):
		get_tree().quit()

	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			p1 = last_mouse_pos
			p2 = p1

			current_line = LineScene.instantiate()
			add_child(current_line)
			current_line.set_ends(p1, p2)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if current_line != null and p1.distance_to(p2) < MIN_LINE_LENGTH:
				current_line.queue_free()
			current_line = null
		elif event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			_delete_line_at(last_mouse_pos)

func _delete_line_at(pos: Vector2) -> void:
	for line in get_tree().get_nodes_in_group("line"):
		if not is_instance_valid(line):
			continue
		var closest := Geometry2D.get_closest_point_to_segment(pos, line.a, line.b)
		if pos.distance_to(closest) <= LINE_PICK_RADIUS:
			line.queue_free()
			return
