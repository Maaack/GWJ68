extends Control

const MONEY_LABEL_TEXT = "$ %d"

@onready var money_label : Label = %MoneyLabel
@onready var night_time_control : Control = %NightTimeControl
@onready var game_world : Node = $SubViewportContainer/SubViewport/FirstGameWorld2D

func _on_first_game_world_2d_money_updated(new_value):
	money_label.text = MONEY_LABEL_TEXT % new_value

func _on_first_game_world_2d_day_progress_updated(new_value):
	%DayProgressBar.value = new_value

func _on_next_day_button_pressed():
	game_world.start_day()
	night_time_control.hide()

func _on_first_game_world_2d_day_ended():
	night_time_control.show()
