extends StaticBody2D

var a: Vector2
var b: Vector2

@onready var shape: CollisionShape2D = $shape
@onready var line2d: Line2D = $spr

func set_ends(p1: Vector2, p2: Vector2) -> void:
	a = p1
	b = p2

	var distance = a.distance_to(b)
	var center = (a + b) * 0.5
	var angle = a.angle_to_point(b) + PI / 2

	if shape and shape.shape is CapsuleShape2D:
		var capsule := shape.shape as CapsuleShape2D
		capsule.height = distance
		shape.position = center
		shape.rotation = angle
	else:
		push_error("Missing or invalid shape.")

	if line2d:
		line2d.points = PackedVector2Array([a, b])
	else:
		push_error("Missing line node.")
