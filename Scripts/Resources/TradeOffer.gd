class_name TradeOffer
extends Resource

enum Resolutions{
	LOW,
	HALF,
	HIGH,
	MAX,
}

enum Sizes{
	TINY,
	SMALL,
	MEDIUM,
	LARGE,
}

const ResolutionDict : Dictionary = {
	Resolutions.LOW : 0.25,
	Resolutions.HALF : 0.5,
	Resolutions.HIGH : 0.75,
	Resolutions.MAX : 1.0,
}

const SizeDict : Dictionary = {
	Sizes.TINY : Vector2(16, 16),
	Sizes.SMALL : Vector2(24, 24),
	Sizes.MEDIUM : Vector2(32, 32),
	Sizes.LARGE : Vector2(48, 48),
}

@export var value : int = 0
@export var polygon : PackedVector2Array = []
@export var tally : int = 0
@export var precision_required : float = 1.0
@export var check_size : Sizes = Sizes.TINY :
	set(value):
		check_size = value
		if check_size in SizeDict:
			area_size = SizeDict[check_size]
@export var check_resolution : Resolutions = Resolutions.HALF :
	set(value):
		check_resolution = value
		if check_resolution in ResolutionDict:
			var resolution_ratio : float = ResolutionDict[check_resolution]
			area_resolution = Vector2i(round(resolution_ratio * area_size))

var area_size : Vector2
var area_resolution : Vector2i

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
