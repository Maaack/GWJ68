class_name MetalPiece
extends Resource

const MASS_DENSITY = 1.0

@export var piece_shape : PieceShape
@export var color : Color

func get_polygon() -> PackedVector2Array:
	return piece_shape.get_polygon()

func get_mass() -> float:
	return MASS_DENSITY * piece_shape.size

func get_polygon_center_of_mass() -> Vector2:
	return piece_shape.get_polygon_center_of_mass()
