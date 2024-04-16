extends Node2D

signal money_updated(new_value : int)

@export var starting_money : int = 0

@onready var _money : int = starting_money :
	set(value):
		_money = value
		money_updated.emit(_money)

func _unhandled_input(event):
	if event.is_action_pressed("interact"):
		$SpawnController.spawn()

func _on_trade_controller_piece_sold(value):
	_money += value
