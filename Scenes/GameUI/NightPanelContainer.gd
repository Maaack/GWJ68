extends PanelContainer

const CASH_POSITIVE_LABEL_TEXT = "$ %d"
const CASH_NEGATIVE_LABEL_TEXT = "- $ %d"

signal next_day_pressed
signal next_level_pressed

@export var cash_available : int = 0
@export var rent_due : int = 0
@export var money_goal : int = 0
@export var profit_color : Color = Color.WHITE
@export var deficit_color : Color = Color.RED

@onready var cash_available_label : Label = %CashAvailableLabel
@onready var rent_due_label : Label = %RentDueLabel
@onready var total_remaining_label : Label = %TotalRemainingLabel
@onready var next_day_button : Button = %NextDayButton
@onready var next_level_button : Button = %NextLevelButton
@onready var restart_button : Button = %RestartButton


func update():
	cash_available_label.text = CASH_POSITIVE_LABEL_TEXT % cash_available
	rent_due_label.text = CASH_NEGATIVE_LABEL_TEXT % rent_due
	var total_remaining : int = cash_available - rent_due
	if money_goal > 0 and total_remaining > money_goal:
		total_remaining_label.text = CASH_POSITIVE_LABEL_TEXT % total_remaining
		total_remaining_label.add_theme_color_override("font_color", profit_color)
		next_day_button.hide()
		next_level_button.show()
	elif total_remaining >= 0:
		total_remaining_label.text = CASH_POSITIVE_LABEL_TEXT % total_remaining
		total_remaining_label.add_theme_color_override("font_color", profit_color)
		next_day_button.show()
		next_level_button.hide()
	else:
		total_remaining_label.text = CASH_NEGATIVE_LABEL_TEXT % -total_remaining
		total_remaining_label.add_theme_color_override("font_color", deficit_color)
		next_day_button.hide()
		next_level_button.hide()

func _on_next_day_button_pressed():
	next_day_pressed.emit()

func _on_next_level_button_pressed():
	next_level_pressed.emit()

func _on_restart_button_pressed():
	SceneLoader.reload_current_scene()
