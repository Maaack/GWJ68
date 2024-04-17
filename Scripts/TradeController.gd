class_name TradeController
extends Node

const AREA_SIZE_VECTOR : Vector2 = Vector2(16, 16)
const AREA_RESOLUTION_VECTOR : Vector2i = Vector2i(8, 8)
const ROTATION_STEPS : float = PI/4

signal piece_sold(value : int)

@export var trade_area : Area2D
@export var delete_delay : float = 0.0
@export var trade_offer : TradeOffer :
	set(value):
		trade_offer = value
		if is_inside_tree():
			%SellValue.text = "$ %d" % trade_offer.value
			%TradePolygon.polygon = trade_offer.polygon
			%PrecisionLabel.text = "> %d%%" % round(trade_offer.precision_required * 100)

func _ready():
	trade_offer = trade_offer
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
	var half_step := point_ratio / 2
	for x in range(area_resolution.x):
		for y in range(area_resolution.y):
			point = Vector2(x, y) * point_ratio
			point += area_corner_offset + half_step
			area_points.append(Geometry2D.is_point_in_polygon(point, polygon))
	return area_points

func _get_overlapping_points(area_size : Vector2, area_resolution : Vector2i, polygon_1 : PackedVector2Array, polygon_2 : PackedVector2Array) -> Array[bool]:
	var area_points_1 = _get_polygon_area_points(area_size, area_resolution, polygon_1)
	var area_points_2 = _get_polygon_area_points(area_size, area_resolution, polygon_2)
	var overlapping_points : Array[bool]
	for i in range(area_points_1.size()):
		overlapping_points.append(area_points_1[i] == area_points_2[i])
	return overlapping_points

func _get_percentage_overlapping_points(area_size : Vector2, area_resolution : Vector2i, polygon_1 : PackedVector2Array, polygon_2 : PackedVector2Array) -> float:
	var overlap_percent : float
	var overlapping_points := _get_overlapping_points(area_size, area_resolution, polygon_1, polygon_2)
	var total_overlapped : int = 0
	for overlap_result in overlapping_points:
		total_overlapped += int(overlap_result)
	return float(total_overlapped) / float(overlapping_points.size())

func rotate_polygon(polygon: PackedVector2Array, rotation: float) -> PackedVector2Array:
	var rotated_polygon : PackedVector2Array = []
	for vertex in polygon:
		var x = vertex.x * cos(rotation) - vertex.y * sin(rotation)
		var y = vertex.x * sin(rotation) + vertex.y * cos(rotation)
		rotated_polygon.append(Vector2(x, y))
	return rotated_polygon

func _score_piece(piece : MetalPiece2D):
	piece.update_polygon_shape()
	var scoring_polygon = piece.get_polygon()
	var trade_polygon = trade_offer.get_polygon()
	var scoring_polygon_center = piece.get_polygon_center_of_mass()
	var trade_polygon_center = trade_offer.get_polygon_center_of_mass()
	var scoring_normalized_polygon = _get_offset_polygon(scoring_polygon, -scoring_polygon_center)
	var trade_normalized_polygon = _get_offset_polygon(trade_polygon, -trade_polygon_center)
	#print(scoring_polygon_center, "  ...  ", scoring_normalized_polygon)
	#print(trade_polygon_center, "  ...  ", trade_normalized_polygon)
	var max_overlapping_percent : float = 0.0
	var rotation : float = 0.0
	var area_size := trade_offer.area_size
	var area_resolution := trade_offer.area_resolution
	while(rotation < 2 * PI and max_overlapping_percent < 1):
		var rotated_polygon = rotate_polygon(scoring_normalized_polygon, rotation)
		var overlapping_percent := _get_percentage_overlapping_points(area_size, area_resolution, rotated_polygon, trade_normalized_polygon)
		max_overlapping_percent = max(overlapping_percent, max_overlapping_percent)
		rotation += ROTATION_STEPS
	print(max_overlapping_percent)
	if max_overlapping_percent >= trade_offer.precision_required:
		piece_sold.emit(trade_offer.value)
		

func _delete_piece(object):
	if object is MetalPiece2D and not object.scored:
		_score_piece(object)
		object.scored = true
		if delete_delay > 0:
			await(get_tree().create_timer(delete_delay, false, true).timeout)
		object.queue_free()

