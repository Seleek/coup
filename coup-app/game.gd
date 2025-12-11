extends Control

const PLAYER_SCENE = preload("res://Player.tscn")
var player_ui_nodes = []


func _ready():
	GameData.connect("game_state_changed", Callable(self, "update_ui"))
	GameData.connect("log_message", Callable(self, "append_to_log"))
	GameData.connect("action_requested", Callable(self, "handle_action_request"))
	var names = ["Alice", "Bob", "Charlie"]
	GameData.init_game(names)
	
	for i in range(names.size()):
		var player_ui = PLAYER_SCENE.instance()
		$PlayerContainer.add_child(player_ui)
		player_ui_nodes.append(player_ui)
	
	update_ui()
	
func update_ui():
	var current_player = GameData.get_current_player()
		
	var player_ui_nodes = $listaJugadores.get_children()
	for i in range (GameData.players.size()):
		var player_data = GameData.players[i]
		var player_ui = player_ui_nodes[i]
			
		player_ui.get_node("nombreJugador").text = "%s (%s)" % ["**" + player_data.name + "**" if i == GameData.current_player_index else player_data.name, "Turno Actual" if i == GameData.current_player_index else ""]
		player_ui.get_node("monedas").text = "Monedas: %d" % player_data.coins
			
		var card_container = player_ui.get_node("cartasInfluencia")
		for j in range(GameData.MAX_INFLUENCE):
			var card_node = card_container.get_child(j)
				
			if j < player_data.influence.size():
				if i == GameData.current_player_index:
					card_node.get_node("Label").text = player_data.indluence[j]
				else:
					card_node.get_node("Label").text = "Influencia"
			else:
				card_node.get_node("Label").text = "PERDIDA"
	
	#BOTONES
	
	
	
		
func _process(delta: float) -> void:
	pass
