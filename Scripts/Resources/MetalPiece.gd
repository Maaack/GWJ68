class_name MetalPiece
extends Resource

@export var mass : float = 1.0
@export var polygon : PackedVector2Array
@export var color : Color

func get_polygon() -> PackedVector2Array:
	return polygon

func get_polygon_center_of_mass() -> Vector2:
	var area_sum = 0.0
	var center_sum = Vector2.ZERO
	for i in range(polygon.size()):
		var current_vertex = polygon[i]
		var next_vertex = polygon[(i + 1) % polygon.size()]
		var cross_product = current_vertex.cross(next_vertex)
		var area = cross_product / 2.0
		area_sum += area
		center_sum += (current_vertex + next_vertex) * area
	var _center_of_mass = center_sum / (3.0 * area_sum)
	return _center_of_mass
