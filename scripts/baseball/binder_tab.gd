extends AnimatedSprite2D

@onready var _team_symbol = $team_symbol
@onready var _num_label = $num_label
@onready var _name_label = $name_label

func set_tab(num : int, tab_name : String, tab_state : String, tab_team : String):
	if(num < 10):
		_num_label.text = str(str("#0",num)," ")
	else:
		_num_label.text = str(str("#",num)," ")
	_name_label.text = tab_name
	play(tab_state)
	_team_symbol.play(tab_team)
