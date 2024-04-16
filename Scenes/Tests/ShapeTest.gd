extends Node2D


@export var starting_money : int = 0

@onready var total_money : int = starting_money

func _unhandled_input(event):
	if event.is_action_pressed("interact"):
		$SpawnController.spawn()


func _on_trade_controller_piece_sold(value):
	total_money += value
