class_name MetalPiece2D
extends RigidBody2D

const ROTATION_STEPS = 4
signal clicked

var held = false

func _input_event(viewport, event, shape_idx):
	if event.is_action_pressed("select"):
		clicked.emit(self)
		rotation = (round((rotation / PI) * ROTATION_STEPS) / ROTATION_STEPS) * PI
	if event.is_action_pressed("rotate_left"):
		if held:
			rotation += PI/ROTATION_STEPS
	if event.is_action_pressed("rotate_right"):
		if held:
			rotation -= PI/ROTATION_STEPS

func _physics_process(delta):
	if held:
		global_transform.origin = get_global_mouse_position()

func set_polygon(new_value : PackedVector2Array):
	$Polygon2D.polygon = new_value
	$CollisionPolygon2D.polygon = new_value

func get_polygon():
	return $Polygon2D.polygon

func pickup():
	if held:
		return
	freeze = true
	held = true

func drop(impulse=Vector2.ZERO):
	if held:
		freeze = false
		apply_central_impulse(impulse)
		held = false


func _on_body_entered(body):
	print(body)
	if body is MetalPiece2D:
		if body.held:
			var position_offset = position - body.position
			var _transform = transform.rotated(rotation - body.rotation)
			var _transformed_polygon: PackedVector2Array = []
			for _vector in get_polygon(): _transformed_polygon.append(_transform.basis_xform(_vector + position_offset))
			var new_polygons = Geometry2D.merge_polygons(_transformed_polygon, body.get_polygon())
			body.call_deferred("set_polygon", new_polygons[0])
			queue_free()
