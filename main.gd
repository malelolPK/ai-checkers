extends TileMap
# ctrl + k komentarz
# crtl + I automatyczne wcięcia

var ai_script_mini_max: Node
var PawnMovement: Node
var AttackMoves: Node
var ai_script_alpha_beta: Node

@export var white_scene: PackedScene
@export var black_scene: PackedScene
@export var white_king_scene: PackedScene
@export var black_king_scene: PackedScene
@export var pawn_move_scene: PackedScene

var GRIDSIZE: int = 8
var help_board: Array = []
var stard_board: Array

var is_attack: bool = false
var number_white: int  = 0
var number_black: int = 0
var player_play_turn: bool = false

var current_piece = null
var grid_size: Vector2 = Vector2(800, 800)
var cell_size: Vector2 = Vector2(100, 100)
var possible_move: Array = []
var possible_attack: Array = []

var old_grid_pos: Vector2i
var position_old: Vector2i
	
var new_grid_pos: Vector2i
var position_new: Vector2i

var whiteKing_name: int = 1
var blackKing_name: int = 1

var SHOW_possible_move_pawn: Array = []

var possible_move_king: Array = []
var SHOW_possible_move_pawn_king: Array = []
var isEnemyOppomentJump: Array = []

var isPlayerTurn: bool = true
var isAITurn: bool = false

var HELP_VALUE: int  = 1
var previousTurnWasAttack: bool = false
var gameEnded: bool = false

var updated_position: Vector2i
var Pawn_type: String = ""

var previousTurn: String
var what_pawn_was: String

var number_white_king: int = 0
var number_black_king: int = 0
var isAnimationRunning = false

var nonCaptureMoveCount = 0

var pawn_full_name
var label_number_player:int  = 0
var label_number_ai:int  = 0
var is_promote_to_king = false

# ======================================================================================================================
# ==================================== Initialization and game development =============================================
# ======================================================================================================================

func _ready():
	initialize_game_state()
var pawn_full_name_attack
func initialize_game_state():
	# Loading Classes as resources
	PawnMovement = load("res://asset/FUNKCJE LOGIKI GRY/PawnMovement.gd").new()
	AttackMoves = load("res://asset/FUNKCJE LOGIKI GRY/AttackMoves.gd").new()
	ai_script_mini_max = load("res://asset/AI/AIMiniMax.gd").new()
	ai_script_alpha_beta = load("res://asset/AI/AIAlphaBeta.gd").new()
	new_game_board()
	create_empty_board()
	setup_initial_board_state()
	GlobalVariables.set_board(help_board)

func new_game_board():
	stard_board = [
		[0,-1,0,-1,0,-1,0,-1],
		[-1,0,-1,0,-1,0,-1,0],
		[0,-1,0,-1,0,-1,0,-1],
		[0,0,0,0,0,0,0,0],
		[0,0,0,0,0,0,0,0],
		[1,0,1,0,1,0,1,0],
		[0,1,0,1,0,1,0,1],
		[1,0,1,0,1,0,1,0],
	]

func create_empty_board():
	for i in range(8):
		var kolumna : Array = []
		for j in range(8):
			kolumna.append(null)
		help_board.append(kolumna)

	for x in GRIDSIZE:
		for y in GRIDSIZE:
			if (x+y) % 2 == 0:
				set_cell(0,Vector2(x,y),1,Vector2(1,1),0)
			else:
				set_cell(0,Vector2(x,y),2,Vector2(1,1),0)

func setup_initial_board_state():
	var white_name = 1
	var black_name = 1
	blackKing_name = 1
	number_white_king = 1
	for i in range(8):
		for j in range(8):
			var grid_pos = Vector2i(j,i)
			var position = grid_pos * 100 + Vector2i(100 / 2, 100 / 2)
			if(stard_board[i][j] == 1):
				help_board[i][j] = instantiate_pawn(position, white_scene, white_name)
				white_name += 1
				number_white += 1
			if(stard_board[i][j] == -1):
				help_board[i][j] = instantiate_pawn(position, black_scene, black_name)
				black_name += 1
				number_black += 1
			if(stard_board[i][j] == 2):
				help_board[i][j] = instantiate_pawn(position, white_king_scene, whiteKing_name)
				whiteKing_name += 1
				number_white_king += 1
			if(stard_board[i][j] == -2):
				help_board[i][j] = instantiate_pawn(position, black_king_scene, blackKing_name)
				blackKing_name += 1
				number_black_king += 1

func promote_to_king():
	for i in range(8):
		if get_pawn_info(GlobalVariables.board[0][i],true,false) == "white":
			is_promote_to_king = true
			var grid_pos = Vector2i(i,0)
			var position = grid_pos * 100 + Vector2i(100 / 2, 100 / 2)
			GlobalVariables.board[0][i].queue_free()
			GlobalVariables.board[0][i] = spawn_king_pawn(position, white_king_scene, whiteKing_name)
			whiteKing_name += 1
			number_white_king += 1
		
		elif get_pawn_info(GlobalVariables.board[7][i],true,false) == "black":
			is_promote_to_king = true
			var grid_pos = Vector2i(i,7)
			var position = grid_pos * 100 + Vector2i(100 / 2, 100 / 2)
			GlobalVariables.board[7][i].queue_free()
			GlobalVariables.board[7][i] = spawn_king_pawn(position, black_king_scene, blackKing_name)
			blackKing_name += 1
			number_black_king += 1

func instantiate_pawn(pawn_position : Vector2, prefab_scene : PackedScene, pawn_name: int) -> Node:
	var new_pawn = prefab_scene.instantiate()
	
	match prefab_scene:
		white_scene:
			new_pawn.name = "white " + str(pawn_name)
		black_scene:
			new_pawn.name = "black " + str(pawn_name)
		white_king_scene:
			new_pawn.name = "whiteKing " + str(pawn_name)
		black_king_scene:
			new_pawn.name = "blackKing " + str(pawn_name)

	new_pawn.position = pawn_position
	new_pawn.add_to_group("pawns")
	add_child(new_pawn)
	return new_pawn

func spawn_king_pawn(position : Vector2, prefab_scene : PackedScene, name: int) -> Node:
	var new_pionek = prefab_scene.instantiate()
	if prefab_scene == white_king_scene:
		new_pionek.name = "whiteKing " + str(name)
	if prefab_scene == black_king_scene:
		new_pionek.name = "blackKing " + str(name)
	new_pionek.position = position
	new_pionek.add_to_group("pawns")
	add_child(new_pionek)
	return new_pionek



# ======================================================================================================================
# ========================================== User Interaction and Events ===============================================
# ======================================================================================================================

func _input(event):
	if isPlayerTurn:
		if event is InputEventMouseButton:
			if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				var mouse_pos = get_global_mouse_position()
				for child in get_children():
					var isWhite = child.name.begins_with("white")
					if child.global_position.distance_to(mouse_pos) < 50 and isWhite:
						current_piece = child
						break
				if current_piece:
					old_grid_pos = local_to_map(get_global_mouse_position())
					var pawn_name_player = get_pawn_info(current_piece,true,false)
					AttackMoves.search_if_is_attack(pawn_name_player,GlobalVariables.board)
					what_pawn_was = pawn_name_player
							
					position_old = (old_grid_pos * 100) + Vector2i(100 / 2, 100 / 2)
					var isKing = get_pawn_info(current_piece,true,false).ends_with("King")
					if isKing:
						possible_move_king = PawnMovement.possible_move_pawn_king(current_piece,GlobalVariables.board)
						show_pawn_moves("King")
					else:
						possible_move = PawnMovement.posibble_move_pawn(current_piece,GlobalVariables.board)
						show_pawn_moves("Pawn")

			elif not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				if current_piece:
					new_grid_pos = Vector2i(event.global_position / 100)
					position_new = (new_grid_pos * 100) + Vector2i(100 / 2, 100 / 2)
					updated_position = move_piece(current_piece,position_old,position_new)
					current_piece.global_position = updated_position
					if updated_position != position_old:
						
						player_play_turn = true
						
					else:
						$"../info/Panel2/text_legal_move".visible = true
						player_play_turn = false
				current_piece = null
				hide_pawn_moves()
						
				if player_play_turn:
					$"../info/Panel2/text_legal_move".visible = false
					game_turn()
				else:
					return
		elif event is InputEventMouseMotion and current_piece:
			current_piece.global_position += event.relative
	else:
		return
	
func get_pawn_info(pawn, what_color: bool, include_id: bool) -> String:
	if pawn != null:
		var name_parts
		if pawn is String:
			name_parts  = pawn.split(" ")
		else:
			name_parts  = pawn.name.split(" ")
		if what_color and name_parts[0] in ["white","whiteKing", "black","blackKing"]:
			return name_parts[0]
		elif include_id and name_parts[0] in ["white","whiteKing", "black","blackKing"]:
			return name_parts[0] + " " + name_parts[1]
	return "Nic"


func animate_piece_movement(to_position,found_pawn):
	await get_tree().create_timer(0.2).timeout
	if to_position.x == null or to_position.y == null or found_pawn == null:
		return
	var tween = get_tree().create_tween()
	var to_position_float = Vector2(to_position.x, to_position.y)
	if GlobalVariables.is_attack:
		$"../Audio_attack".play()
	else:
		$"../Audio_pawn_move".play()
	tween.tween_property(found_pawn, "position", to_position_float, 0.6)
	tween.connect("finished", Callable(self, "_on_tween_all_completed"))
	isAnimationRunning = true
	
	await tween.finished 

func _on_tween_all_completed():
	isAnimationRunning = false
	if !isAnimationRunning:
		game_turn()

# ======================================================================================================================
# ==================================================== Logic games =====================================================
# ======================================================================================================================


func player_game_ai():
	await get_tree().create_timer(0.5).timeout
	if isPlayerTurn:
		var bestMoveAI
		possible_move = []
		AttackMoves.is_attack_move_available_for_type("white",GlobalVariables.board)
		if previousTurnWasAttack and GlobalVariables.is_attack and previousTurn == "Player":
			bestMoveAI = [GlobalVariables.board[new_grid_pos.y][new_grid_pos.x]]
			var BestMoveAI_move = PawnMovement.possible_move_pawn_king(GlobalVariables.board[new_grid_pos.y][new_grid_pos.x],GlobalVariables.board) if get_pawn_info(GlobalVariables.board[new_grid_pos.y][new_grid_pos.x],true,false).ends_with("King") else PawnMovement.posibble_move_pawn(GlobalVariables.board[new_grid_pos.y][new_grid_pos.x],GlobalVariables.board)
			if BestMoveAI_move.size() > 1: # jeżeli jest więcej niż 1 możliwy ruch znajdź najlepszy ruch
				bestMoveAI = ai_script_alpha_beta.find_best_move(GlobalVariables.board,4, "white",previousTurnWasAttack,pawn_full_name)
			else:
				bestMoveAI.append(BestMoveAI_move[0])
		else:
			bestMoveAI = ai_script_alpha_beta.find_best_move(GlobalVariables.board,4, "white",previousTurnWasAttack,pawn_full_name)
		if bestMoveAI == [null,null]:
			isPlayerTurn = true
			isAITurn = false
			return
		var selected_pawn = bestMoveAI[0]
		var target_position = Vector2i(bestMoveAI[1][1], bestMoveAI[1][0])
		old_grid_pos = Vector2i(selected_pawn.position / cell_size)
		new_grid_pos = target_position
		
		var old_world_position = (old_grid_pos * 100) + Vector2i(100 / 2, 100 / 2)
		var new_world_position = (new_grid_pos * 100) + Vector2i(100 / 2, 100 / 2)
		
		var pawns = get_tree().get_nodes_in_group("pawns")
		var found_pawn = null
		for pawn in pawns:
			if pawn == selected_pawn:
				found_pawn = pawn
		if found_pawn == null:
			print("wchodzi return przy found pawn")
			return
			
		var pawn_name = get_pawn_info(selected_pawn, true, false)
		pawn_full_name = selected_pawn
		what_pawn_was = pawn_name
		AttackMoves.is_attack_move_available_for_type(pawn_name,GlobalVariables.board)
		
		found_pawn.z_index = 1000
		if pawn_name.ends_with("King"):
			possible_move_king.append(Vector2i(target_position[1], target_position[0]))
			await animate_piece_movement(new_world_position, found_pawn)
			var new_position =await move_piece(selected_pawn, old_world_position, new_world_position)
			if new_position == null:
				print("wchodzi return przy new_position")
				return
		else:
			possible_move.append(Vector2i(target_position[1], target_position[0]))
			await animate_piece_movement(new_world_position, found_pawn)
			var new_position = await move_piece(selected_pawn, old_world_position, new_world_position)
			
			if new_position == null:
				print("wchodzi return przy new_position")
				return
		found_pawn.z_index = 0

		return
	else:
		return

func ai_move():
	if isAITurn:
		var bestMoveAI
		await get_tree().create_timer(0.5).timeout
		possible_move = []
		AttackMoves.is_attack_move_available_for_type("black",GlobalVariables.board)
		if previousTurnWasAttack and GlobalVariables.is_attack and previousTurn == "AI":
			bestMoveAI = [GlobalVariables.board[new_grid_pos.y][new_grid_pos.x]]
			var BestMoveAI_move = PawnMovement.possible_move_pawn_king(GlobalVariables.board[new_grid_pos.y][new_grid_pos.x],GlobalVariables.board) if get_pawn_info(GlobalVariables.board[new_grid_pos.y][new_grid_pos.x],true,false).ends_with("King") else PawnMovement.posibble_move_pawn(GlobalVariables.board[new_grid_pos.y][new_grid_pos.x],GlobalVariables.board)
			if BestMoveAI_move.size() > 1: # jeżeli jest więcej niż 1 możliwy ruch znajdź najlepszy ruch
				bestMoveAI = ai_script_alpha_beta.find_best_move(GlobalVariables.board,4, "black",previousTurnWasAttack,pawn_full_name)
			else:
				bestMoveAI.append(BestMoveAI_move[0])
		else:
			bestMoveAI = ai_script_alpha_beta.find_best_move(GlobalVariables.board,4, "black",previousTurnWasAttack,pawn_full_name)
		if bestMoveAI == [null,null]:
			isPlayerTurn = true
			isAITurn = false
			return
		var selected_pawn = bestMoveAI[0]
		var target_position = Vector2i(bestMoveAI[1][1], bestMoveAI[1][0])
		old_grid_pos = Vector2i(selected_pawn.position / cell_size)
		new_grid_pos = target_position
		
		var old_world_position = (old_grid_pos * 100) + Vector2i(100 / 2, 100 / 2)
		var new_world_position = (new_grid_pos * 100) + Vector2i(100 / 2, 100 / 2)
		
		var pawns = get_tree().get_nodes_in_group("pawns")
		var found_pawn = null
		for pawn in pawns:
			if pawn == selected_pawn:
				found_pawn = pawn
		if found_pawn == null:
			print("wchodzi return przy found pawn")
			return
		var pawn_name = get_pawn_info(selected_pawn, true, false)
		what_pawn_was = pawn_name
		pawn_full_name = selected_pawn
		AttackMoves.is_attack_move_available_for_type(pawn_name,GlobalVariables.board)
		found_pawn.z_index = 1000
		if pawn_name.ends_with("King"):
			possible_move_king.append(Vector2i(target_position[1], target_position[0]))
			await animate_piece_movement(new_world_position, found_pawn)
			var new_position = move_piece(selected_pawn, old_world_position, new_world_position)
			if new_position == null:
				print("wchodzi return przy new_position")
				return
		else:
			possible_move.append(Vector2i(target_position[1], target_position[0]))
			await animate_piece_movement(new_world_position, found_pawn)
			var new_position = move_piece(selected_pawn, old_world_position, new_world_position)
			
			if new_position == null:
				print("wchodzi return przy new_position")
				return
		found_pawn.z_index = 0
		return
	else:
		return

func move_piece(pawn, old_position: Vector2i, new_position: Vector2i):
	var pawn_info = get_pawn_info(pawn, true, false)
	var is_king = pawn_info == "whiteKing" or pawn_info == "blackKing"
	var position = old_position
	if is_king:
		if not GlobalVariables.is_attack:
			position = move_king_piece_diagonally(pawn, old_position, new_position)
			nonCaptureMoveCount += 1
		else:
			position = jump_diagonally_as_king(pawn, old_position, new_position)
			nonCaptureMoveCount = 0
			previousTurnWasAttack = true
	else:
		if not GlobalVariables.is_attack:
			position = move_piece_diagonal(pawn, old_position, new_position)
			nonCaptureMoveCount += 1
		else:
			position = make_jump_diagonally(pawn, old_position, new_position)
			nonCaptureMoveCount = 0
			previousTurnWasAttack = true
	return position

func move_piece_diagonal(pawn, old_position: Vector2i, new_position: Vector2i):
	for i in range(possible_move.size()):
		if ([new_grid_pos.y][0] == possible_move[i][0] and [new_grid_pos.x][0] == possible_move[i][1]):
			GlobalVariables.board[old_grid_pos.y][old_grid_pos.x] = null
			GlobalVariables.board[new_grid_pos.y][new_grid_pos.x] = pawn
			return new_position
	return old_position

func make_jump_diagonally(pawn, old_position: Vector2i, new_position: Vector2i):
	for i in range(possible_move.size()):
		if ([new_grid_pos.y][0] == possible_move[i][0] and [new_grid_pos.x][0] == possible_move[i][1]):
			var mid_x = (new_grid_pos.x + old_grid_pos.x) / 2
			var mid_y = (new_grid_pos.y + old_grid_pos.y) / 2
			if GlobalVariables.board[mid_y][mid_x] == null:
				print("wchodzi return przy make jump diagonal")
				return
			GlobalVariables.board[mid_y][mid_x].queue_free()
			
			GlobalVariables.board[mid_y][mid_x] = null
			GlobalVariables.board[old_grid_pos.y][old_grid_pos.x] = null
			GlobalVariables.board[new_grid_pos.y][new_grid_pos.x] = pawn
			GlobalVariables.is_attack = false
			delete_pawn_number(pawn)
			return new_position
	return old_position

func move_king_piece_diagonally(pawn, old_position: Vector2i, new_position: Vector2i):
	for i in range(possible_move_king.size()):
		if ([new_grid_pos.y][0] == possible_move_king[i][0] and [new_grid_pos.x][0] == possible_move_king[i][1]):
			GlobalVariables.board[old_grid_pos.y][old_grid_pos.x] = null
			GlobalVariables.board[new_grid_pos.y][new_grid_pos.x] = pawn
			return new_position
	return old_position

func jump_diagonally_as_king(pawn, old_position: Vector2i, new_position: Vector2i):
	# direction (1,1) (1,-1) (-1,1) (-1,-1)
	var direction = Vector2i(0, 0)
	if old_position != new_position:
		var difference:Vector2i = new_grid_pos - old_grid_pos
		var max_abs: int = max(abs(difference.x), abs(difference.y))
		direction = Vector2i(difference.x / max_abs, difference.y / max_abs)
	else:
		return old_position

	var current_position = old_grid_pos + direction
	while current_position != new_grid_pos:
		if current_position.y >= 0 and current_position.y < GlobalVariables.board.size() and current_position.x >= 0 and current_position.x < GlobalVariables.board[0].size():
			if GlobalVariables.board[current_position.y][current_position.x] != null and get_pawn_info(GlobalVariables.board[current_position.y][current_position.x],true,false) != get_pawn_info(pawn,true,false): # get_pawn_inf(pawn,true,false)
				GlobalVariables.board[current_position.y][current_position.x].queue_free()
				GlobalVariables.board[current_position.y][current_position.x] = null
				delete_pawn_number(pawn)
		current_position += direction
	GlobalVariables.board[old_grid_pos.y][old_grid_pos.x] = null
	GlobalVariables.board[new_grid_pos.y][new_grid_pos.x] = pawn
	GlobalVariables.is_attack = false
	return new_position

func show_pawn_moves(TYPE_PAWN: String):
	match TYPE_PAWN:
		"King":
			for i in range(possible_move_king.size()):
				var grid_pos = Vector2i(possible_move_king[i][1],possible_move_king[i][0])
				var position = grid_pos * 100 + Vector2i(100 / 2, 100 / 2)
				var possible_move_pawn_king = pawn_move_scene.instantiate()
				possible_move_pawn_king.position = position
				current_piece.get_parent().add_child(possible_move_pawn_king)
				current_piece.get_parent().move_child(current_piece, current_piece.get_parent().get_child_count() - 1)
				SHOW_possible_move_pawn_king.append(possible_move_pawn_king)
		"Pawn":
			for i in range(possible_move.size()):
				var grid_pos = Vector2i(possible_move[i][1],possible_move[i][0])
				var position = grid_pos * 100 + Vector2i(100 / 2, 100 / 2)
				var possible_move_pawn = pawn_move_scene.instantiate()
				possible_move_pawn.position = position
				current_piece.get_parent().add_child(possible_move_pawn)
				current_piece.get_parent().move_child(current_piece, current_piece.get_parent().get_child_count() - 1)
				SHOW_possible_move_pawn.append(possible_move_pawn)

func hide_pawn_moves():
	if SHOW_possible_move_pawn_king.size() > 0:
		for move in range(SHOW_possible_move_pawn_king.size()):
			remove_child(SHOW_possible_move_pawn_king[move])
		SHOW_possible_move_pawn_king.clear()
	if SHOW_possible_move_pawn.size() > 0:
		for move in range(SHOW_possible_move_pawn.size()):
			remove_child(SHOW_possible_move_pawn[move])
		SHOW_possible_move_pawn.clear()

func game_turn():
	await get_tree().create_timer(0.5).timeout
	promote_to_king()
	if game_end() or nonCaptureMoveCount >= 50 :
		$"../game_over".show()
		return
	if is_promote_to_king == true:
		handle_normal_turn()
		is_promote_to_king = false
		return
	AttackMoves.search_if_is_attack(what_pawn_was,GlobalVariables.board)
	if GlobalVariables.is_attack:
		handle_attack_turn()
	else:
		handle_normal_turn()

func handle_attack_turn():
	if isPlayerTurn:
		handle_player_attack_turn()
	elif isAITurn:
		handle_ai_attack_turn()

func handle_normal_turn():
	previousTurnWasAttack = false
	switch_turn()

func handle_player_attack_turn():
	if AttackMoves.is_attack_move_available_pawn(GlobalVariables.board[new_grid_pos.y][new_grid_pos.x],GlobalVariables.board) or AttackMoves.is_attack_move_available_pawn_king(GlobalVariables.board[new_grid_pos.y][new_grid_pos.x],GlobalVariables.board):
		if previousTurnWasAttack:
			isPlayerTurn = true
			isAITurn = false
			previousTurnWasAttack = true
			previousTurn = "Player"
			pawn_full_name_attack = GlobalVariables.board[new_grid_pos.y][new_grid_pos.x]
			#await player_game_ai()
		else:
			switch_turn()
	else:
		switch_turn()

func handle_ai_attack_turn():
	if AttackMoves.is_attack_move_available_pawn(GlobalVariables.board[new_grid_pos.y][new_grid_pos.x],GlobalVariables.board) or AttackMoves.is_attack_move_available_pawn_king(GlobalVariables.board[new_grid_pos.y][new_grid_pos.x],GlobalVariables.board):
		if previousTurnWasAttack:
			isPlayerTurn = false
			isAITurn = true
			previousTurnWasAttack = true
			previousTurn = "AI"
			pawn_full_name_attack = GlobalVariables.board[new_grid_pos.y][new_grid_pos.x]
			await ai_move()
		else:
			switch_turn()
	else:
		switch_turn()

func switch_turn():
	if isPlayerTurn:
		$"../info/Panel1/imagine_white_pawn".visible = false
		$"../info/Panel1/imagine_black_pawn".visible = true
		$"../info/Panel1/info_who_turn".text = "AI"
		isPlayerTurn = false
		isAITurn = true
		previousTurn = "Player"
		await ai_move()
		
	elif isAITurn:
		$"../info/Panel1/imagine_white_pawn".visible = true
		$"../info/Panel1/imagine_black_pawn".visible = false
		$"../info/Panel1/info_who_turn".text = "GRACZ"
		isAITurn = false
		isPlayerTurn = true
		previousTurn = "AI"
		#await player_game_ai()

func delete_pawn_number(PAWN):
	var PAWN_NAME = get_pawn_info(PAWN,true,false)
	if PAWN_NAME.begins_with("white"):
		number_black -= 1
		label_number_player += 1
		$"../player/Panel/info_gracz".text = str(label_number_player)
	if PAWN_NAME.begins_with("black"):
		number_white -= 1
		label_number_ai += 1
		$"../ai/Panel/info_komputer".text = str(label_number_ai)
		
# ======================================================================================================================
# ============================================================ END GAME ================================================
# ======================================================================================================================

func game_end():
	if is_inPossible_to_move("white") or are_all_pawns_taken("white"):
		print("GAME END sInPossibleToMove(black)", is_inPossible_to_move("white"), " are_all_pawns_taken(black) ",are_all_pawns_taken("white"))
		print("wygrał czarny")
		$"../game_over".get_node("who_win").text = "AI"
		$"../game_over".get_node("black").show()
		return true
	elif is_inPossible_to_move("black") or are_all_pawns_taken("black"):
		print("GAME END sInPossibleToMove(black)", is_inPossible_to_move("black"), " are_all_pawns_taken(black) ",are_all_pawns_taken("black"))
		print("wygrał biały")
		$"../game_over".get_node("who_win").text = "CZŁOWIEK"
		$"../game_over".get_node("white").show()
		return true
	return false

func is_inPossible_to_move(_type_pawn: String):
	if _type_pawn == "white":
		if PawnMovement.all_possible_moves("white", GlobalVariables.board):
			return true
	if _type_pawn == "black":
		if PawnMovement.all_possible_moves("black", GlobalVariables.board):
			return true
	return false

func are_all_pawns_taken(_type_pawn: String) -> bool:
	if _type_pawn == "white":
		return (number_white == 0 and number_white_king == 0)
	if _type_pawn == "black":
		return (number_black == 0 and number_black_king == 0)
	return false


func _on_game_over_restart():
	$"../game_over".hide()
	get_tree().reload_current_scene()
	get_tree().paused = false

func _on_game_over_exit():
	get_tree().quit()
