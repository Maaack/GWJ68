class_name HeatController
extends Node

@export var melting_point : float = 1000
@export var specific_heat_capacity : float = 1.0
@export var thermal_conductivity : float = 1.0
@export var body_2d : MetalPiece2D

var ambient_temperature : float
var body_temperature : float

func update_heat(delta : float):
	var body_area := body_2d.get_surface_area()
	var body_mass := body_2d.mass
	var conduction_heat_transfer := ambient_temperature - body_temperature
	conduction_heat_transfer *= thermal_conductivity * delta * body_area
	var temperature_diff := conduction_heat_transfer / (specific_heat_capacity * body_mass)
	body_temperature += temperature_diff

func _process(delta):
	update_heat(delta)

func print_status():
	print(ambient_temperature, " ", body_temperature)
	
