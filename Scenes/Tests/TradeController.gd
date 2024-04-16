class_name TradeController
extends Node

signal piece_sold(value : int)

@export var trade_area : Area2D
@export var delete_delay : float = 0.0

func _ready():
	if not trade_area.body_entered.is_connected(_delete_piece):
		trade_area.body_entered.connect(_delete_piece)

func _delete_piece(object):
	if object is MetalPiece2D:
		if delete_delay > 0:
			await(get_tree().create_timer(delete_delay, false, true).timeout)
		piece_sold.emit(int(object.mass))
		object.queue_free()
