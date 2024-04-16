class_name MetalPiece2D
extends RigidBody2D

const ROTATION_STEPS = 4
signal clicked

var held : bool = false
@onready var heat_controller : HeatController = $HeatController
@onready var polygon_2d : Polygon2D = $Polygon2D

var hold_offset : Vector2 = Vector2.ZERO

func _ready():
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC

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

func merge_to(relative_polygon : PackedVector2Array, other_piece : MetalPiece2D):
	for child in get_children():
		if child is CollisionPolygon2D:
			child.reparent(other_piece)
	other_piece.mass += mass
	other_piece.add_polygon(relative_polygon)
	queue_free()

func get_polygon() -> PackedVector2Array:
	return polygon_2d.polygon

func add_polygon(polygon : PackedVector2Array):
	var new_polygons = Geometry2D.merge_polygons(get_polygon(), polygon)
	if new_polygons.size() == 1:
		polygon_2d.polygon = new_polygons[0]

func get_surface_area() -> float:
	var polygon := get_polygon()
	var surface_area : float = 0.0
	var prev_point : Vector2
	for vec2 in polygon:
		if not prev_point:
			prev_point = vec2
			continue
		surface_area += prev_point.distance_to(vec2)
		prev_point = vec2
	return surface_area

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
	hold_offset += new_origin_offset
	for child in get_children():
		if not child is Node2D:
			continue
		child.position += new_origin_offset

func _get_polygon_relative_to_piece(other_piece : MetalPiece2D) -> PackedVector2Array:
	var position_offset = polygon_2d.global_position - other_piece.polygon_2d.global_position
	var _transform = transform.rotated(other_piece.global_rotation)
	var _transformed_polygon: PackedVector2Array = []
	var _transformed_offset = position_offset.rotated(-other_piece.global_rotation)
	for _vector in get_polygon(): _transformed_polygon.append(_transform.basis_xform(_vector) + _transformed_offset)
	return _transformed_polygon

func _polygons_overlap(polygon_a : PackedVector2Array, polygon_b : PackedVector2Array) -> bool:
	var new_polygons = Geometry2D.merge_polygons(polygon_a, polygon_b)
	if new_polygons.size() == 1:
		return true
	return false

func _is_temp_greater_than_melting(heat_controller_a : HeatController, heat_controller_b : HeatController):
	var _temp_a = heat_controller_a.body_temperature
	var _temp_b = heat_controller_b.body_temperature
	var _min_melting_point = min(heat_controller_a.melting_point, heat_controller_b.melting_point)
	return (_temp_a + _temp_b) / 2 > _min_melting_point

func _can_merge_with_piece(polygon : PackedVector2Array, piece : MetalPiece2D) -> bool:
	var _melting_temp = _is_temp_greater_than_melting(heat_controller, piece.heat_controller)
	var _polygons_overlap = _polygons_overlap(polygon, piece.get_polygon())
	return _melting_temp and _polygons_overlap

func _on_body_entered(body):
	if body is MetalPiece2D and not body.held:
		var relative_polygon = _get_polygon_relative_to_piece(body)
		if _can_merge_with_piece(relative_polygon, body):
			call_deferred("merge_to", relative_polygon, body)
