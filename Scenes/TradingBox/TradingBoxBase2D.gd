@tool
class_name TradingBoxBase2D
extends Node2D

const ROTATION_STEPS : float = PI/4

signal piece_sold(metal_piece : MetalPiece2D, value : int)
signal piece_rejected(metal_piece : MetalPiece2D)
signal offer_completed(completed_trade_offer : TradeOffer)

@export var trade_offer : TradeOffer :
	set(value):
		trade_offer = value
		if is_inside_tree() or Engine.is_editor_hint():
			if trade_offer != null:
				var center_of_mass = trade_offer.get_polygon_center_of_mass()
				var offset_polygon = _get_offset_polygon(trade_offer.get_polygon(), -center_of_mass)
				%TradePolygon.polygon = offset_polygon
				tally = trade_offer.tally
			else:
				%TradePolygon.polygon = []
				tally = -1
@export var fade_out_text_scene : PackedScene

@onready var trade_area : Area2D = %TradeArea2D
@onready var trade_completed_particles_2d : GPUParticles2D = %TradeCompletedParticles2D
@onready var trade_accepted_particles_2d : GPUParticles2D = %TradeAcceptedParticles2D
@onready var trade_polygon : Polygon2D = %TradePolygon
@onready var fade_out_text_marker_2d : Marker2D = %FadeOutTextMarker2D

var tally : int :
	set(value):
		tally = value
		if is_inside_tree():
			if tally >= 0:
				%TallyLabel.text = "x%d" % tally
			else:
				%TallyLabel.text = ""

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
	var overlapping_points : Array[bool] = []
	for i in range(area_points_1.size()):
		overlapping_points.append(area_points_1[i] == area_points_2[i])
	return overlapping_points

func _get_percentage_overlapping_points(area_size : Vector2, area_resolution : Vector2i, polygon_1 : PackedVector2Array, polygon_2 : PackedVector2Array) -> float:
	var overlapping_points := _get_overlapping_points(area_size, area_resolution, polygon_1, polygon_2)
	var total_overlapped : int = 0
	for overlap_result in overlapping_points:
		total_overlapped += int(overlap_result)
	return float(total_overlapped) / float(overlapping_points.size())

func rotate_polygon(polygon: PackedVector2Array, input_rotation: float) -> PackedVector2Array:
	var rotated_polygon : PackedVector2Array = []
	for vertex in polygon:
		var x = vertex.x * cos(input_rotation) - vertex.y * sin(input_rotation)
		var y = vertex.x * sin(input_rotation) + vertex.y * cos(input_rotation)
		rotated_polygon.append(Vector2(x, y))
	return rotated_polygon

func _offer_completed():
	trade_completed_particles_2d.emitting = true
	var completed_trade_offer : TradeOffer = trade_offer
	trade_offer = null
	offer_completed.emit(completed_trade_offer)

func _lower_tally():
	if tally > 0:
		tally -= 1
		if tally == 0:
			_offer_completed()
		else:
			trade_accepted_particles_2d.emitting = true

func _spawn_fade_out_text(quality : FadeOutText.Qualities):
	var fade_out_text : FadeOutText = fade_out_text_scene.instantiate()
	if not fade_out_text: return
	add_child(fade_out_text)
	fade_out_text.position = fade_out_text_marker_2d.position
	fade_out_text.quality = quality

func _piece_accepted(piece : MetalPiece2D, percent_match : float):
	piece_sold.emit(piece, trade_offer.value)
	if percent_match == 1:
		_spawn_fade_out_text(FadeOutText.Qualities.PERFECT)
	elif percent_match > 0.975:
		_spawn_fade_out_text(FadeOutText.Qualities.EXCELLENT)
	elif percent_match > 0.950:
		_spawn_fade_out_text(FadeOutText.Qualities.GREAT)
	elif percent_match > 0.925:
		_spawn_fade_out_text(FadeOutText.Qualities.GOOD)
	elif percent_match > 0.900:
		_spawn_fade_out_text(FadeOutText.Qualities.OKAY)
	elif percent_match > 0.850:
		_spawn_fade_out_text(FadeOutText.Qualities.BAD)
	else:
		_spawn_fade_out_text(FadeOutText.Qualities.TERRIBLE)
	_lower_tally()

func _reject_piece(piece : MetalPiece2D):
	piece_rejected.emit(piece)
	piece.scored = false
	_spawn_fade_out_text(FadeOutText.Qualities.REJECTED)

func _score_piece(piece : MetalPiece2D):
	if trade_offer == null:
		_reject_piece(piece)
		return
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
	var _rotation : float = 0.0
	var area_size := trade_offer.area_size
	var area_resolution := trade_offer.area_resolution
	while(_rotation < 2 * PI and max_overlapping_percent < 1):
		var rotated_polygon = rotate_polygon(scoring_normalized_polygon, _rotation)
		var overlapping_percent := _get_percentage_overlapping_points(area_size, area_resolution, rotated_polygon, trade_normalized_polygon)
		max_overlapping_percent = max(overlapping_percent, max_overlapping_percent)
		_rotation += ROTATION_STEPS
	print(max_overlapping_percent)
	if max_overlapping_percent >= trade_offer.precision_required:
		_piece_accepted(piece, max_overlapping_percent)
	else:
		_reject_piece(piece)

func _trade_piece(object):
	if object is MetalPiece2D and not object.scored:
		object.drop()
		object.scored = true
		_score_piece(object)

func _on_trade_area_2d_body_entered(body):
	_trade_piece(body)

func _ready():
	trade_offer = trade_offer
