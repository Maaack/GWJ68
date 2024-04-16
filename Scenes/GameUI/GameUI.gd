extends Control

const MONEY_LABEL_TEXT = "$ %d"

@onready var money_label : Label = %MoneyLabel

func _on_first_game_world_2d_money_updated(new_value):
	money_label.text = MONEY_LABEL_TEXT % new_value
