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

func merge_to(other_piece : MetalPiece2D):
	for child in get_children():
		if child is CollisionPolygon2D or child is Polygon2D:
			var _globa_position = child.global_position
			child.call_deferred("reparent", other_piece)
			child.global_position = _globa_position
	other_piece.mass += mass
	queue_free()

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
		apply_central_impulse(impulse * mass)
		held = false

func _on_body_entered(body):
	print(body)
	if body is MetalPiece2D:
		if body.held:
			merge_to(body)
