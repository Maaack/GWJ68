class_name PieceBase2D
extends Node2D

@onready var polygon_2d : Polygon2D = $Polygon2D

func get_polygon() -> PackedVector2Array:
	return polygon_2d.polygon

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
