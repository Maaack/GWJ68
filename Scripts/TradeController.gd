class_name TradeController
extends Node

const AREA_SIZE_VECTOR : Vector2 = Vector2(16, 16)
const AREA_RESOLUTION_VECTOR : Vector2i = Vector2i(8, 8)

signal piece_sold(value : int)

@export var trade_area : Area2D
@export var delete_delay : float = 0.0
@export var blueprint_2d : PieceBase2D

func _ready():
	if not trade_area.body_entered.is_connected(_delete_piece):
		trade_area.body_entered.connect(_delete_piece)

func _get_offset_polygon(polygon : PackedVector2Array, offset : Vector2) -> PackedVector2Array:
	var _offset_polygon : PackedVector2Array = []
	for vertex in polygon:
		_offset_polygon.append(vertex + offset)
	return _offset_polygon


func _get_polygon_area_points(area_size : Vector2, area_resolution : Vector2i, polygon : PackedVector2Array) -> Array[bool]:
	var point : Vector2
	var area_corner_offset := -(area_size / 2)
	var area_points : Array[bool] = []
	var point_ratio := area_size / Vector2(area_resolution)
	for x in range(area_resolution.x):
		for y in range(area_resolution.y):
			point = Vector2(x, y) * point_ratio
			point += area_corner_offset
			area_points.append(Geometry2D.is_point_in_polygon(point, polygon))
	return area_points

func _get_overlapping_points(area_size : Vector2, area_resolution : Vector2i, polygon_1 : PackedVector2Array, polygon_2 : PackedVector2Array) -> Array[bool]:
	var area_points_1 = _get_polygon_area_points(area_size, area_resolution, polygon_1)
	var area_points_2 = _get_polygon_area_points(area_size, area_resolution, polygon_2)
	var overlapping_points : Array[bool]
	for i in range(area_points_1.size()):
		overlapping_points.append(area_points_1[i] == area_points_2[i])
	return overlapping_points

func _get_percentage_overlapping_points(polygon_1 : PackedVector2Array, polygon_2 : PackedVector2Array) -> float:
	var overlap_percent : float
	var overlapping_points := _get_overlapping_points(AREA_SIZE_VECTOR, AREA_RESOLUTION_VECTOR, polygon_1, polygon_2)
	print(overlapping_points)
	var total_overlapped : int = 0
	for overlap_result in overlapping_points:
		total_overlapped += int(overlap_result)
	return float(total_overlapped) / float(overlapping_points.size())

func _score_piece(piece : MetalPiece2D):
	var scoring_polygon = piece.get_polygon()
	var blueprint_polygon = blueprint_2d.get_polygon()
	var scoring_polygon_center = piece.get_polygon_center_of_mass()
	var blueprint_polygon_center = blueprint_2d.get_polygon_center_of_mass()
	var scoring_normalized_polygon = _get_offset_polygon(scoring_polygon, -scoring_polygon_center)
	var blueprint_normalized_polygon = _get_offset_polygon(blueprint_polygon, -blueprint_polygon_center)
	print(scoring_polygon_center, "  ...  ", scoring_normalized_polygon)
	print(blueprint_polygon_center, "  ...  ", blueprint_normalized_polygon)
	var overlapping_percent := _get_percentage_overlapping_points(scoring_normalized_polygon, blueprint_normalized_polygon)
	print(overlapping_percent)
	

func _delete_piece(object):
	if object is MetalPiece2D:
		_score_piece(object)
		if delete_delay > 0:
			await(get_tree().create_timer(delete_delay, false, true).timeout)
		piece_sold.emit(int(object.mass))
		object.queue_free()

