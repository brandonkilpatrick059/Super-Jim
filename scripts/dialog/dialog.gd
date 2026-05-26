extends Node

var baseball_game = preload("res://baseball/baseball_manager.tscn")

@onready var _DialogBubble = $DialogBubble
@onready var _ResponseBubble = $ResponseBubble
@onready var _AudioStreamPlayer = $AudioStreamPlayer

@export var alternate_dialog_bubble : PackedScene = null

var speaker_node : Node
var tree : dialog_tree
var player_ref
var dialog_choice_index = 0
var responding = false

var shopping = false
var ware_commenting = false
var shop_deciding = false
var shop_buy_decision = true
var shop_pick_index : int = 0
var sold_out = false

var dialog_started = false
var shop : shop_manager = null
var nudge_vector = Vector2(0,0)

var playing_cards = false

var waited_ware : Node = null

var queued_script : Node = null

func set_shop(new_shop : shop_manager):
	shop = new_shop

func set_nudge_vector(input : Vector2):
	nudge_vector = input

func set_speaker_node(node : Node):
	speaker_node = node

# Called when the node enters the scene tree for the first time.
func _ready():
	player_ref = get_tree().get_first_node_in_group("player")
	if(alternate_dialog_bubble != null):
		var bubble = alternate_dialog_bubble.instantiate()
		_DialogBubble.queue_free()
		add_child(bubble)
		_DialogBubble = bubble
	_DialogBubble.visible = false
	_ResponseBubble.visible = false

func set_alternate_bubble(scene_path : String):
	alternate_dialog_bubble = load(scene_path)
	#var bubble = alternate_dialog_bubble.instantiate()
	#_DialogBubble.queue_free()
	#add_child(bubble)
	#_DialogBubble = bubble

func play_current_branch():
	if(tree.get_sound_path() != null && tree.get_sound_path() != ""):
		_AudioStreamPlayer.stream = load(tree.get_sound_path())
		_AudioStreamPlayer.play()
	if(!tree.get_plays_cards()):
		responding = false
		if(tree.get_speaker_name() != null && tree.get_speaker_name() != ""):
			speaker_node = get_tree().get_first_node_in_group(tree.get_speaker_name())
			
		_ResponseBubble.visible = false
		_DialogBubble.set_label("")
		_DialogBubble.global_position = speaker_node.global_position + Vector2(-48,-96) + nudge_vector
		#_DialogBubble.set_portrait(tree.get_speaker_portrait(), tree.get_speaker_emote())
		_DialogBubble.set_portrait(null, "") #no portraits :(
		_DialogBubble.visible = true
		_DialogBubble.play_text(tree.get_speaker_text(), tree.get_voice())
		
		var branch_gives_money_amount = tree.get_give_money_amount()
		player_ref._on_add_money(branch_gives_money_amount)
		var branch_script = tree.get_dialog_script()
		if(branch_script != null):
			if(tree.script_runs_after_dialog()):
				queued_script = branch_script
			else:
				branch_script.run_script()
	else:
		play_cards()

func play_text(text : String, voice : String):
	_ResponseBubble.visible = false
	_DialogBubble.set_label("")
	_DialogBubble.global_position = speaker_node.global_position + Vector2(-48,-96) + nudge_vector
	_DialogBubble.set_portrait(null, "") #no portraits :(
	_DialogBubble.visible = true
	_DialogBubble.play_text(text, tree.get_voice())

func set_tree_and_start_dialog(in_tree :dialog_tree):
	tree = in_tree
	dialog_started = true
	_DialogBubble.visible = true
	play_current_branch()

func is_end_of_dialog() -> bool:
	return tree.get_num_speech_options() == 0 && tree.get_num_option_branches() == 0

func dialog_continues() -> bool:
	return tree.get_num_speech_options() == 0 && tree.get_num_option_branches() == 1

func has_conditional_option_script() -> bool:
	return tree.has_conditional_option_script()

func has_speech_options() -> bool:
	return tree.get_num_speech_options() > 0

func play_cards():
	if(player_ref.get_deck().size() > 0):
		playing_cards = true
		_DialogBubble.visible = false
		_ResponseBubble.visible = false
		var player_deck = player_ref.get_deck()
		var opponent_deck = tree.get_deck()
		var catch_chances = tree.get_catch_chances()
		var game = baseball_game.instantiate()
		player_ref.get_parent().add_child(game)
		game.global_position = player_ref.get_camera_ref().get_screen_center_position()
		game.set_callback_node(self)
		game.initiate_card_game(player_deck,opponent_deck,catch_chances)
	else:
		game_end(0)

func game_end(player_won : int):
	playing_cards = false
	if(player_won == 0):
		tree.take_speech_option(0) #player doesn't have any cards
		play_current_branch()
	elif(player_won == 1):
		tree.take_speech_option(1)
		play_current_branch()
	else: #player lost
		tree.take_speech_option(2)
		play_current_branch()

func end_dialog():
	tree.reset()
	if(tree.tree_does_not_return_control()): #start text scroll tree does not give control back
		var control_stays_frozen : bool = true
		player_ref.exit_dialog(control_stays_frozen) 
	else:
		player_ref.exit_dialog()
	if(waited_ware != null):
		waited_ware.buy_item()
		waited_ware = null
	clean_up()

func handle_input():
	if(responding):
		if(shop_deciding && !ware_commenting):
			_ResponseBubble.visible = true
			_DialogBubble.visible = false
			if(dialog_choice_index == 0):
				_ResponseBubble.set_label("Yes.")
				shop_buy_decision = true
			else:
				_ResponseBubble.set_label("No.")
				shop_buy_decision = false
		elif(!sold_out && tree.get_shows_wares() && shop != null): #display available wares
			if(shop.get_staged_wares().size() > 0):
				shopping = true
				if(dialog_choice_index == 0):
					_ResponseBubble.set_label("Nevermind.")
				else:
					var ware_name = shop.get_staged_wares()[dialog_choice_index-1].get_ware_name()
					var ware_price : int = shop.get_staged_wares()[dialog_choice_index-1].get_cost()
					var price_string : String = str(" for $",ware_price)
					_ResponseBubble.set_label(str(ware_name,price_string))
			elif(!sold_out):
				var sold_out_comment = shop.get_sold_out_comment()
				sold_out = true
				play_text(sold_out_comment,shop.get_comment_voice())
		else:
			_ResponseBubble.set_label(tree.get_speech_option(dialog_choice_index))
			
		if(Input.is_action_just_pressed("menu_left") && !ware_commenting):
			_AudioStreamPlayer.stream = load("res://audio/soundFX/maracca.ogg")
			_AudioStreamPlayer.play()
			if(dialog_choice_index == 0):
				if(!shopping):
					dialog_choice_index = tree.get_num_speech_options() - 1
				else:
					if(shop_deciding):#do you want to buy this?
						dialog_choice_index = 1
					else:
						dialog_choice_index = shop.get_staged_wares().size()
			else:
				dialog_choice_index = dialog_choice_index - 1
		
		if(Input.is_action_just_pressed("menu_right") && !ware_commenting):
			_AudioStreamPlayer.stream = load("res://audio/soundFX/maracca.ogg")
			_AudioStreamPlayer.play()
			if(!shopping):
				if(dialog_choice_index == tree.get_num_speech_options() - 1):
					dialog_choice_index = 0
				else:
					dialog_choice_index = dialog_choice_index + 1
			else:
				if(shop_deciding): #do you want to buy this?
					if(dialog_choice_index == 0):
						dialog_choice_index = 1
					else:
						dialog_choice_index = 0
				elif(dialog_choice_index == shop.get_staged_wares().size()):
					dialog_choice_index = 0
				else:
					dialog_choice_index = dialog_choice_index + 1
		
	if(Input.is_action_just_pressed("menu_select")):
		#no options or next nodes = dialog is over
		if(queued_script != null):
			queued_script.run_script()
			queued_script = null
		if(is_end_of_dialog() || sold_out):
			end_dialog()
		elif(dialog_continues()):
			tree.take_speech_option(0)
			play_current_branch()
		elif(has_conditional_option_script()):
			var script_node = tree.get_conditional_option_script()
			var choice = script_node.run_conditional() #returns integer
			tree.take_speech_option(choice)
			play_current_branch()
		elif(has_speech_options() && !responding):
			_DialogBubble.visible = false
			_ResponseBubble.set_label("")
			_ResponseBubble.visible = true
			responding = true
		elif(has_speech_options() && responding):
			if(!shopping):
				tree.take_speech_option(dialog_choice_index)
				dialog_choice_index = 0
				play_current_branch()
			else:
				if(!shop_deciding && !ware_commenting):
					shop_pick_index = dialog_choice_index
				var player_money = player_ref.get_money()
				var ware = shop.get_staged_wares()[shop_pick_index-1]
				var has_comment 
				if(!shop_deciding && dialog_choice_index == 0):
					nevermind()
				elif(player_money >= ware.get_cost()):
					if(!ware_commenting && !shop_deciding):
						ware_commenting = true
						var comment = shop.get_ware_comment(ware)
						var voice = shop.get_comment_voice()
						play_text(comment, voice)
					elif(ware_commenting && !shop_deciding):
						var comment = shop.get_are_you_sure_comment()
						var voice = shop.get_comment_voice()
						play_text(comment, voice)
						shop_deciding = true
					elif(ware_commenting && shop_deciding):
						ware_commenting = false
					elif(shop_deciding && !ware_commenting):
						if(shop_buy_decision == true):
							if(ware.waits_until_dialog_ends()):
								waited_ware = ware
							else:
								shop.buy_given_ware(ware)
							tree.take_speech_option(1)
							play_current_branch()
						else:
							nevermind()
						ware_commenting = false
						shop_deciding = false
				elif(player_money < ware.get_cost()):
					tree.take_speech_option(2) #"not enough money" don't buy anything
					play_current_branch()
					ware_commenting = false
					shop_deciding = false


func nevermind():
	tree.take_speech_option(0) #"nevermind" don't buy anything
	play_current_branch()
	ware_commenting = false
	shop_deciding = false

func clean_up():
	var parent_npc = get_parent()
	if(parent_npc.is_in_group("npc")):
		parent_npc.out_of_dialog()
	var children = get_children()
	for child in children:
		child.queue_free()
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(dialog_started):
		if(player_ref.global_position.distance_to(speaker_node.global_position) > 300 &&
		!tree.bypass_distance_check()):
			end_dialog()
		else:
			_DialogBubble.global_position = speaker_node.global_position + Vector2(-48,-96)
			if(speaker_node.dialog_offset != null):
				_DialogBubble.global_position = _DialogBubble.global_position + speaker_node.dialog_offset
			_ResponseBubble.global_position = player_ref.global_position + Vector2(-48,-96)
			if(_DialogBubble.is_text_done_playing()):
				handle_input()

func set_dialog_tree(in_tree : dialog_tree):
	tree = in_tree
