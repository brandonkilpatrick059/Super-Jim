extends Control

@onready var balance_num : Label = $CenterContainer/TextureRect/balance_num
@onready var transaction_num : Label = $CenterContainer/TextureRect/transaction_num
@onready var transaction_type : Label = $CenterContainer/TextureRect/transaction_type

func set_balance_num(str : String):
	balance_num.text = str

func set_transaction_num(str : String):
	transaction_num.text = str

func set_transaction_type(str : String):
	transaction_type.text = str
	
