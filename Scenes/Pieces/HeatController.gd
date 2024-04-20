class_name HeatController
extends Node

@export var melting_point : float = 1000
@export var specific_heat_capacity : float = 1.0
@export var thermal_conductivity : float = 1.0
@export var body_2d : MetalPiece2D
@export var heat_gradient : Gradient
@export var melting_collider_layer : int

var ambient_temperature : float
var body_temperature : float

func update_heat(delta : float):
	var body_area := body_2d.get_surface_area()
	var body_mass := body_2d.mass
	var conduction_heat_transfer := ambient_temperature - body_temperature
	conduction_heat_transfer *= thermal_conductivity * delta * body_area
	var temperature_diff := conduction_heat_transfer / (specific_heat_capacity * body_mass)
	body_temperature += temperature_diff
	_update_polygon_color()
	if melting_collider_layer > 0 and melting_collider_layer <= 32:
		body_2d.set_collision_layer_value(melting_collider_layer, body_temperature < melting_point)

func _process(delta):
	update_heat(delta)

func print_status():
	print(ambient_temperature, " ", body_temperature)

func _get_melting_point_ratio() -> float:
	if melting_point == 0:
		return 0.0
	return body_temperature / melting_point

func _get_heat_gradient_sample(melt_ratio):
	var sample_point := clampf(melt_ratio / 2, 0, 1)
	return heat_gradient.sample(sample_point)

func _update_polygon_color():
	var melt_ratio := _get_melting_point_ratio()
	var heat_color = _get_heat_gradient_sample(melt_ratio)
	var metal_color = body_2d.starting_metal_piece.color
	body_2d.polygon_2d.color = metal_color + heat_color
