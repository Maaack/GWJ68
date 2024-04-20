class_name TradeController
extends Node

const ROTATION_STEPS : float = PI/4

signal piece_sold(value : int)
signal offer_completed

@export var delete_delay : float = 0.0

@export var trade_offers : Array[TradeOffer]
@export var respawn_position_node_2d : Node2D
@onready var _respawn_position = respawn_position_node_2d.position
@export var trading_boxes : Array[TradingBoxBase2D]
@export var refill_trade_box_offers : bool = true
var _current_trade_offers : Array[TradeOffer]

func get_random_trade_offer() -> TradeOffer:
	if _current_trade_offers.size() == 0:
		return null
	_current_trade_offers.shuffle()
	return _current_trade_offers.pop_back()

func _on_offer_completed(trade_offer_completed : TradeOffer, trading_box : TradingBoxBase2D):
	offer_completed.emit()
	_current_trade_offers.append(trade_offer_completed)
	if refill_trade_box_offers:
		trading_box.trade_offer = get_random_trade_offer()

func _on_piece_rejected(metal_piece_2d : MetalPiece2D):
	PhysicsServer2D.body_set_state(
		metal_piece_2d.get_rid(),
		PhysicsServer2D.BODY_STATE_TRANSFORM,
		Transform2D.IDENTITY.translated(_respawn_position)
	)

func _on_piece_sold(metal_piece, money_earned):
	piece_sold.emit(money_earned)
	if delete_delay > 0:
		await(get_tree().create_timer(delete_delay, false, true).timeout)
	metal_piece.queue_free()

func _connect_trading_box(node : Node):
	if node is TradingBoxBase2D:
		if not node.piece_sold.is_connected(_on_piece_sold):
			node.piece_sold.connect(_on_piece_sold)
		if not node.piece_rejected.is_connected(_on_piece_rejected):
			node.piece_rejected.connect(_on_piece_rejected)
		if not node.offer_completed.is_connected(_on_offer_completed.bind(node)):
			node.offer_completed.connect(_on_offer_completed.bind(node))

func _connect_trading_boxes():
	for trading_box in trading_boxes:
		_connect_trading_box(trading_box)

func _populate_trade_offers():
	for trading_box in trading_boxes:
		if trading_box.trade_offer == null:
			trading_box.trade_offer = get_random_trade_offer()

func _ready():
	_current_trade_offers = trade_offers
	_connect_trading_boxes()
	_populate_trade_offers()
