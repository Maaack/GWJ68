extends Control

const MONEY_LABEL_TEXT = "$ %d"
const RENT_LABEL_TEXT = "$ %d Due"

@onready var money_label : Label = %MoneyLabel
@onready var rent_label : Label = %RentLabel
@onready var night_time_control : Control = %NightTimeControl
@onready var night_panel_container : PanelContainer = %NightPanelContainer
@onready var game_world : GameWorld2D = $SubViewportContainer/SubViewport/FirstGameWorld2D
@onready var shop_panel : ShopPanel = %ShopPanel

func _on_first_game_world_2d_money_updated(new_value):
	shop_panel.money_available = new_value
	money_label.text = MONEY_LABEL_TEXT % new_value

func _on_first_game_world_2d_day_progress_updated(new_value):
	%DayProgressBar.value = new_value

func start_day():
	game_world.start_day()
	rent_label.text = RENT_LABEL_TEXT % game_world.daily_rent_due

func _on_next_day_button_pressed():
	night_time_control.hide()
	start_day()

func _end_day():
	night_time_control.show()
	night_panel_container.cash_available = game_world.money
	night_panel_container.rent_due = game_world.daily_rent_due
	night_panel_container.update()

func _on_first_game_world_2d_day_ended():
	_end_day()

func _ready():
	start_day()

func pay_rent():
	game_world.money -= game_world.daily_rent_due

func _on_night_panel_container_next_day_pressed():
	night_time_control.hide()
	pay_rent()
	start_day()

func _on_shop_panel_pieces_bought(metal_pieces):
	for metal_piece in metal_pieces:
		game_world.spawn_metal_piece(metal_piece)

func _on_shop_panel_money_spent(money):
	game_world.money -= money
