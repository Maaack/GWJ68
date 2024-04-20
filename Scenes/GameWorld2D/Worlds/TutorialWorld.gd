extends GameWorld2D

@export var target_trade_offers_completed : int = 6
var trade_offers_completed : int = 0

func _trade_offer_completed():
	trade_offers_completed += 1
	if trade_offers_completed >= target_trade_offers_completed:
		level_won.emit()
