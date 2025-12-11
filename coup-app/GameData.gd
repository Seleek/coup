extends Node

const MAX_INFLUENCE = 2
const START_COINS = 2
const INFLUENCE_TYPES = ["Duque", "Asesino", "Capitan", "Embajador", "Condesa"]
const ACTION_COSTS = {"Asesinar" : 3, "Coup" : 7}

enum GameState{
	WAITING_FOR_ACTION,
	WAITING_FOR_CHALLENGE,
	WAITING_FOR_BLOCK,
	RESOLVING_CHALLENGE,
	RESOLVING_BLOCK_CHALLENGE,
	EXECUTING_ACTION,
	INFLUENCE_LOSS
}

var players = []
var deck = []
var treasury = 50
var currently_player_index = 0
var current_game_state = GameState.WAITING_FOR_ACTION

var active_action = {}
signal game_state_changed
signal log_message(message)
signal action_requested(player_index, options)

#iniciar juego
func init_game (player_names : Array):
	deck.clear()
	for type in INFLUENCE_TYPES:
		for i in range(3):
			deck.append(type)
	deck.shuffle()
	
	#iniciar jugadores
	players.clear()
	for name in player_names:
		var new_player = {
			"name": name,
			"coins": START_COINS,
			"influence": [draw_card(), draw_card()],
			"revealed_influence":[],
			"is_out": false
		}
		players.append(new_player)
	currently_player_index=0
	current_game_state = GameState.WAITING_FOR_ACTION
	emit_signal("game_state_changed")
	emit_signal("log_message", "El juego ha comenzado. Empieza %s." % get_current_player().name)

func draw_card():
	if deck.size()>0:
		return deck.pop_back()
	return null

func get_player(index):
	return players[index]

func get_current_player():
	return players[currently_player_index]
	
#///////////////////////////
#BOTONES DE ACCIÓN  AAAAAAAAAAAAAAA
#////////////////////////////

func announce_action(action_name: String, target_index: int = -1):
	var actor = get_current_player()
	if ACTION_COSTS.has(action_name) and actor.coins < ACTION_COSTS[action_name]:
		emit_signal("log_message", "%s no tiene suficientes monedas para %s." % [actor.name, action_name])
		return
		
	var claimed_char = "N/A"
	if action_name == "Impuestos": claimed_char = "Duque"
	if action_name == "Asesinar": claimed_char = "Asesino"
	if action_name == "Robar": claimed_char = "Capitan"
	if action_name == "Intercambio": claimed_char = "Embajador"
	
	active_action = {
		"name": action_name,
		"actor_index": currently_player_index,
		"target_index": target_index,
		"claimed_character": claimed_char
	}
	
	emit_signal ("log_message", "%s anuncia la acción: %s (personaje: %s)." % [actor.name, action_name, claimed_char])
	
	if action_name == "Ingresos" or (action_name == "Coup" and actor.xoins >=7):
		current_game_state = GameState.EXECUTING_ACTION
		execute_action(active_action)
		return
		
	if action_name == "Ayuda Externa":
		current_game_state = GameState.WAITING_FOR_BLOCK
		for i in range(players.size()):
			if i != currently_player_index and not players[i].is_out:
				emit_signal("action_requested", i, {"type": "BLOCK", "action_name": action_name, "block_char": "Duque"})
				
	else:
		current_game_state = GameState.WAITING_FOR_CHALLENGE
		for i in range(players.size()):
			if i != currently_player_index and not players[i].is_out:
				emit_signal("action_requested", i, {"type": "CHALLENGE", "action_name": action_name})
	emit_signal("game_state_changed")
	
#//////////////
#Llamadas a la interfaz de usuario
#///////////////
func player_response(responder_index: int, response_type: String, block_character: String = ""):
	var action = active_action.name
	var actor = get_player(active_action.actor_index)
	var responder = get_player(responder_index)
	
	if response_type == "CHALLENGE":
		emit_signal("log_message", "%s DESAFÍA la acción de %s." % [responder.name, actor.name])
		current_game_state = GameState.RESOLVING_CHALLENGE
		resolve_challenge(responder_index)
		return

	elif response_type == "PASS":
		pass
	
	emit_signal("game_state_changed")

#///////////////
#Ahora si pa resolver los challenge aaaaaaaaa
#//////////////
func resolve_challenge (challenger_index:int):
	var actor = get_player(active_action.actor_index)
	var challenger = get_player(challenger_index)
	var claimed_char = active_action.claimed_character
	
	var has_card = actor.influence.has(claimed_char)
	
	if has_card:
		emit_signal("log_message", "Resultado del Desafío: %s muestra el %s. Desafío fallido." % [actor.name, claimed_char])
		
		actor.influence.erase(claimed_char)
		actor.influence.append(draw_card())
		deck.append(claimed_char)
		deck.shuffle()
		
		request_influence_loss(challenger_index, "por desafio fallido")
		
		active_action.must_execute = true
		
	else:
		emit_signal("log_message", "Resultado del Desafío: %s MIENTE. Desafío exitoso." % actor.name)
		request_influence_loss(active_action.actor_index, "por desafio exitoso")
		active_action.must_execute = false

func resolve_block_challenge(challenger_index: int):
	var blocker = get_player(active_action.blocker_index)
	var challenger = get_player(challenger_index)
	var claimed_char = active_action.block_claimed_char
	
	var has_card = blocker.influence.has(claimed_char)
	
	if has_card:
		emit_signal("log_message", "Resultado: Bloqueador (%s) muestra el %s. Desafío fallido." % [blocker.name, claimed_char])
		blocker.influence.erase(claimed_char)
		blocker.infljuence.append(draw_card())
		deck.append(claimed_char)
		deck.shuffle()
		
		request_influence_loss(challenger_index,"por desafio de bloqueo fallido")
		
		active_action.must_execute = false
	else:
		emit_signal("log_message", "Resultado: Bloqueador MIENTE. Desafio al bloqueo exitoso.")
		request_influence_loss(active_action.blocker_index, "por desafio exitoso")
		active_action.must_execute = true

#//////////////////////////////
#EJECUTAR LA ACCION Y FIN DE TURNO
#//////////////////////////////
func execute_action(action_data:Dictionary):
	var action_name = action_data.name
	var actor = get_player(action_data.actor_index)
	var target = get_player(action_data.target_index) if action_data.target_index != -1 else null
	
	match action_name:
		"Ingresos":
			actor.coins += 1
		"Ayuda exterior":
			actor.coins += 2
		"Impuestos":
			actor.coins +- 3
		"Robar":
			var stolen = min(target.coins,2) if target else 0
			actor.coins += stolen
			target.coins -= stolen
		"Intercambio":
			var card1 = draw_card()
			var card2 = draw_card()
			deck.append(actor.influence.pop_front())
			deck.append(actor.influence.pop_front())
			actor.influence.append(card1)
			actor.influence.append(card2)
			deck.shuffle()
		"Asesinar":
			actor.coins -= 3
			if target:
				request_influence_loss(action_data.target_index, "por Asesinato")
				return
		"Coup":
			actor.coins -=7
			if target:
				request_influence_loss(action_data.target_index, "por Coup")
				return
	emit_signal("log_message", "Accion %s ejecutada exitosamente." % action_name)
	next_turn()
		
		
func request_influence_loss(player_index: int, reason: String):
	current_game_state = GameState.INFLUENCE_LOSS
	emit_signal("log_message", "%s debe perder una influencia %s. ¡Debe elegir una carta!" % [get_player(player_index).name, reason])
	emit_signal("action_requested", player_index, {"type": "LOSE_INFLUENCE", "reason": reason})
	
func process_influence_loss(player_index: int, card_to_lose: String):
	var player = get_player(player_index)
	if player.influence.has(card_to_lose):
		player.influence.erase(card_to_lose)
		player.revealed_influence.append(card_to_lose)
		emit_signal("log_message", "%s perdió su carta %s." % [player.name, card_to_lose])
		
		if check_for_game_over(player):
			return
		
		if active_action.has("must_execute") and active_action.must_execute:
			active_action.must_execute = false
			current_game_state = GameState.EXECUTING_ACTION
			execute_action(active_action)
		else:
			next_turn()
			
func check_for_game_over(player: Dictionary):
	if player.influence.size() == 0:
		player.is_out = true
		emit_signal("log_message", "%s ha sido eliminado." % player.name)
	
	var active_players = 0
	var winner = null
	for p in players:
		if not p.is_out:
			active_players += 1
			winner = p
			
	if active_players <=1:
		current_game_state = GameState.IDLE 
		emit_signal("log_message", "¡Juego Terminado! El ganador es %s." % winner.name)
		return true
	return false

func next_turn():
	active_action = {}
	
	var next_index = (currently_player_index + 1) % players.size()
	while players[next_index].is_out:
		next_index = (next_index + 1) % players.size()
		
	currently_player_index = next_index
	current_game_state = GameState.WAITING_FOR_ACTION
	
	emit_signal("log_message", "\n--- Es el turno de %s. Monedas: %d. ---" % [get_current_player().name, get_current_player().coins])
	emit_signal("game_state_changed")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
