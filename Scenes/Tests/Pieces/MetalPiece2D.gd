class_name MetalPiece2D
extends RigidBody2D

const ROTATION_STEPS = 4
signal clicked

var held : bool = false

func _input_event(viewport, event, shape_idx):
	if event.is_action_pressed("select"):
		clicked.emit(self)
		rotation = (round((rotation / PI) * ROTATION_STEPS) / ROTATION_STEPS) * PI
	if held:
		if event.is_action_pressed("rotate_left"):
			rotation += PI/ROTATION_STEPS
		if event.is_action_pressed("rotate_right"):
			rotation -= PI/ROTATION_STEPS

func _physics_process(delta):
	if held:
		global_transform.origin = get_global_mouse_position()

func merge_to(other_piece : MetalPiece2D):
	for child in get_children():
		if child is CollisionPolygon2D or child is Polygon2D:
			child.call_deferred("reparent", other_piece)
	other_piece.mass += mass
	queue_free()

func get_polygon():
	return $Polygon2D.polygon

func pickup():
	if held:
		return
	freeze = true
	held = true
	move_origin(-to_local(get_global_mouse_position()))

func drop(impulse=Vector2.ZERO):
	if held:
		freeze = false
		apply_central_impulse(impulse * mass)
		held = false

func move_origin(new_origin_offset : Vector2):
	for child in get_children():
		child.position += new_origin_offset

func _on_body_entered(body):
	if body is MetalPiece2D:
		if body.held:
			merge_to(body)
