class_name ForgeController
extends Node

@export var forge_area : Area2D
@export var forge_temperature : float = 1000.0

var heating_pieces : Array[MetalPiece2D]

func _ready():
	if not forge_area.body_entered.is_connected(_add_heat_piece):
		forge_area.body_entered.connect(_add_heat_piece)
	if not forge_area.body_exited.is_connected(_remove_heat_piece):
		forge_area.body_exited.connect(_remove_heat_piece)

func _add_heat_piece(object):
	if object is MetalPiece2D:
		heating_pieces.append(object)
		object.heat_controller.ambient_temperature = forge_temperature
		
func _remove_heat_piece(object):
	if object is MetalPiece2D and object in heating_pieces:
		heating_pieces.erase(object)
		object.heat_controller.ambient_temperature = 0
