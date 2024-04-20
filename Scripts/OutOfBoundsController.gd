class_name OutOfBoundsController
extends Node

@export var play_area : Area2D
@export var respawn_position_node_2d : Node2D
@onready var _respawn_position = respawn_position_node_2d.position

func _on_piece_left_bounds(metal_piece_2d : MetalPiece2D):
	metal_piece_2d.drop()
	PhysicsServer2D.body_set_state(
		metal_piece_2d.get_rid(),
		PhysicsServer2D.BODY_STATE_TRANSFORM,
		Transform2D.IDENTITY.translated(_respawn_position)
	)

func _on_play_area_body_exited(node : Node2D):
	if is_instance_valid(node) and node is MetalPiece2D:
		_on_piece_left_bounds(node)

func _ready():
	if not play_area.body_exited.is_connected(_on_play_area_body_exited):
		play_area.body_exited.connect(_on_play_area_body_exited)
