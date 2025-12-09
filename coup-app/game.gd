extends Control


func _ready():
	GameData.init_game(["Jugador A", "Jugador B", "Jugador C"])
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
			
func _process(delta: float) -> void:
	pass
