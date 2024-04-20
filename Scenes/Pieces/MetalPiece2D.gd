@tool
class_name MetalPiece2D
extends RigidBody2D

const ROTATION_STEPS : float = PI/4
signal clicked

@export var starting_metal_piece : MetalPiece :
	set(value):
		starting_metal_piece = value
		if starting_metal_piece and (is_inside_tree() or Engine.is_editor_hint()):
			starting_collision_polygon_2d.polygon = starting_metal_piece.get_polygon()
			polygon_2d.polygon = starting_metal_piece.get_polygon()
			polygon_2d.color = starting_metal_piece.color
			mass = starting_metal_piece.get_mass()

var held : bool = false
@onready var heat_controller : HeatController = $HeatController
@onready var polygon_2d : Polygon2D = $Polygon2D
@onready var starting_collision_polygon_2d : CollisionPolygon2D = $CollisionPolygon2D

var hold_offset : Vector2 = Vector2.ZERO
var merging : bool = false
var scored : bool = false

func _ready():
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	starting_metal_piece = starting_metal_piece

func _input_event(viewport, event, shape_idx):
	if event.is_action_pressed("select"):
		clicked.emit(self)
		rotation = round(rotation / ROTATION_STEPS) * ROTATION_STEPS
	if held:
		if event.is_action_pressed("rotate_left"):
			rotation += ROTATION_STEPS
		if event.is_action_pressed("rotate_right"):
			rotation -= ROTATION_STEPS

func _physics_process(delta):
	if held:
		global_transform.origin = get_global_mouse_position()

func merge_to(other_piece : MetalPiece2D):
	for child in get_children():
		if child is CollisionPolygon2D:
			child.reparent(other_piece)
	other_piece.mass += mass
	other_piece.update_polygon_shape()
	queue_free()

func get_polygon() -> PackedVector2Array:
	return polygon_2d.polygon

func update_polygon_shape():
	move_origin(-hold_offset)
	var full_polygon : PackedVector2Array
	var merge_list : Array[PackedVector2Array] = []
	for child in get_children():
		if child is CollisionPolygon2D:
			var child_polygon = transform_polygon(child.polygon, child.transform, child.position)
			if not full_polygon:
				full_polygon = child_polygon
			merge_list.append(child_polygon)
	var _last_merge_count = merge_list.size() + 1
	while(merge_list.size() > 0 and merge_list.size() < _last_merge_count):
		var duplicate_merge_list = merge_list.duplicate()
		merge_list.clear()
		for merge_polygon in duplicate_merge_list:
			var merged_polygons = Geometry2D.merge_polygons(full_polygon, merge_polygon)
			if merged_polygons.size() != 1:
				merge_list.append(merge_polygon)
			full_polygon = merged_polygons[0]
		_last_merge_count = merge_list.size()

	polygon_2d.polygon = full_polygon
	polygon_2d.position = Vector2.ZERO

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
	if scored or held:
		return
	freeze = true
	held = true
	move_origin(-to_local(get_global_mouse_position()))

func drop(impulse=Vector2.ZERO):
	if held:
		held = false
		set_deferred("freeze", false)
		apply_central_impulse(impulse * mass)

func move_origin(new_origin_offset : Vector2):
	hold_offset += new_origin_offset
	for child in get_children():
		if not child is Node2D:
			continue
		child.position += new_origin_offset

func transform_polygon(polygon : PackedVector2Array, body_transform : Transform2D, offset : Vector2 = Vector2.ZERO) -> PackedVector2Array:
	var global_polygon : PackedVector2Array = []
	for vertex in polygon:
		var global_vertex = body_transform.basis_xform(vertex)
		global_vertex += offset
		global_polygon.append(round(global_vertex))
	return global_polygon

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

func _can_merge_with_piece(piece : MetalPiece2D) -> bool:
	var _melting_temp = _is_temp_greater_than_melting(heat_controller, piece.heat_controller)
	var _global_polygon_1 = transform_polygon(get_polygon(), polygon_2d.global_transform, polygon_2d.global_position)
	var _global_polygon_2 = transform_polygon(piece.get_polygon(), piece.polygon_2d.global_transform, piece.polygon_2d.global_position)
	var _polygons_overlap_flag = _polygons_overlap(_global_polygon_1, _global_polygon_2)
	return _melting_temp and _polygons_overlap_flag

func _on_body_entered(body):
	if body is MetalPiece2D and not held and not body.merging:
		if _can_merge_with_piece(body):
			merging = true
			call_deferred("merge_to", body)

func get_polygon_center_of_mass() -> Vector2:
	var area_sum = 0.0
	var center_sum = Vector2.ZERO
	var _polygon = get_polygon()
	for i in range(_polygon.size()):
		var current_vertex = _polygon[i]
		var next_vertex = _polygon[(i + 1) % _polygon.size()]
		var cross_product = current_vertex.cross(next_vertex)
		var area = cross_product / 2.0
		area_sum += area
		center_sum += (current_vertex + next_vertex) * area
	var _center_of_mass = center_sum / (3.0 * area_sum)
	return _center_of_mass
