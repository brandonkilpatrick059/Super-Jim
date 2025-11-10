extends Node

#operator function which, given a path to a
#valid save file, restores a playable gamestate
func start_game_from_save_file(file_path : String):
	pass

#jsonify the game
func save_game() -> String: 
	return ""
	#TODO: haha implement this

func save_game_to_file(file_path : String):
	pass

#parse game from json
func load_game(json_strong : String):
	pass

func load_game_from_file(file_path : String):
	pass

#converts player node into json string
func save_player(player: Node) -> String:
	return ""

#loads player node info from json strong
func load_player(json_string : String) -> Node:
	return null
	
