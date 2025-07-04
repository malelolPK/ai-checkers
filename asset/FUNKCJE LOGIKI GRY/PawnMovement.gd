extends Node

var main_script = load("res://main.gd").new()

var old_grid_pos: Vector2i
#var isEnemyOppomentJump

func all_possible_move_types_pawn(_TYPE_PAWN: String, _board: Array):
	var return_all_move_pawn = {}
	for i in range(8):
		for j in range(8):
			var pawn_inf = main_script.get_pawn_info(_board[i][j],true,false)
			if pawn_inf.begins_with(_TYPE_PAWN):
				if pawn_inf.ends_with("King"):
					if possible_move_pawn_king(_board[i][j],_board) != []:
						return_all_move_pawn[_board[i][j]] = possible_move_pawn_king(_board[i][j],_board)
				else:
					if posibble_move_pawn(_board[i][j],_board) != []:
						return_all_move_pawn[_board[i][j]] = posibble_move_pawn(_board[i][j],_board)
	return return_all_move_pawn

func find_pawn_position(pawn,_board: Array):
	for i in range(8):
		for j in range(8):
			if main_script.get_pawn_info(_board[i][j],false,true) == pawn:
				return Vector2i(j, i)
	return null

func posibble_move_pawn(pawn, _board: Array):
	if main_script.get_pawn_info(pawn,true,false).ends_with("King"):
		return
	#print("Z PAWNmOVEMNT pawn: ",pawn)
	var local_possible_move = []

	#print("&&&&&&&&&&&&&&&&old_grid_pos ",old_grid_pos)
	var _pawn_type = main_script.get_pawn_info(pawn,true,false)
	#print("_pawn_type, ", _pawn_type)
	old_grid_pos = find_pawn_position(main_script.get_pawn_info(pawn,false,true),_board)
	#print("&&&&&&&&&&&&&&&&old_grid_pos ",old_grid_pos)
	var directionRow = null
	var directionColLeft = -1
	var directionColright = 1
	
	var left_col = old_grid_pos.x - 1
	var right_col = old_grid_pos.x + 1
	var row = old_grid_pos.y
	if _pawn_type == "white":
		directionRow = -1
	elif _pawn_type == "black":
		directionRow = 1
	row += directionRow

	if GlobalVariables.is_attack == false:
		if possible_diagonal_move(row, left_col,_board) == true:
			local_possible_move.append([row,left_col])
		if possible_diagonal_move(row, right_col,_board) == true:
			local_possible_move.append([row,right_col])
	if GlobalVariables.is_attack == true:
		if possible_diagonal_jump(row, left_col, directionRow, directionColLeft,_board) == true:
			local_possible_move.append([row + directionRow,left_col + directionColLeft])
		if possible_diagonal_jump(row, right_col,directionRow,directionColright,_board) == true:
			local_possible_move.append([row + directionRow,right_col + directionColright])
		# Sprawdzanie ataku do tyłu
		row -= 2*directionRow
		if possible_diagonal_jump(row, left_col,-directionRow,directionColLeft,_board) == true:
			local_possible_move.append([row - directionRow,left_col + directionColLeft])
		if possible_diagonal_jump(row, right_col,-directionRow,directionColright,_board) == true:
			local_possible_move.append([row - directionRow,right_col + directionColright])
	return local_possible_move

func possible_diagonal_move(_row: int, _col: int,_board: Array) -> bool:
	if _row < _board.size() and _col < _board[_row].size() and _row >= 0 and _col >= 0:
		if _board[_row][_col] == null:
			return true
	return false

func possible_diagonal_jump(_row: int, _col: int, directionRow: int, directionCol: int,_board: Array):
	var isInBoard: bool = _col >= 0 and _col < 8 and _row >= 0 and _row < 8
	var same
	if isInBoard and main_script.get_pawn_info(_board[_row][_col],true,false) == "whiteKing":
		same = "white"
	elif isInBoard and main_script.get_pawn_info(_board[_row][_col],true,false) == "blackKing":
		same = "black"
		
	var isOpponentColor: bool = isInBoard and main_script.get_pawn_info(_board[old_grid_pos.y][old_grid_pos.x],true,false) != main_script.get_pawn_info(_board[_row][_col],true,false) and  _board[_row][_col] != null
	var isJumpInBoard: bool = _row+directionRow >= 0 and _row+directionRow < 8 and _col + directionCol >= 0 and _col + directionCol < 8
	var isJumpPossible: bool = isJumpInBoard and _board[_row + directionRow][_col + directionCol] == null
	if main_script.get_pawn_info(_board[old_grid_pos.y][old_grid_pos.x],true,false) == same:
		return false
	elif  isInBoard and isOpponentColor and isJumpInBoard and isJumpPossible:
		return true
	return false

# ============================================================ POSSIBLE MOVE KING ====================================================

func possible_move_pawn_king(pawn,_board: Array):
	if !main_script.get_pawn_info(pawn,true,false).ends_with("King"):
		return
	#isEnemyOppomentJump = []
	var pawn_type_to_find = main_script.get_pawn_info(pawn,false,true)
	old_grid_pos = find_pawn_position(pawn_type_to_find,_board)
	var local_possible_move_king = []
	var directionRow = null
	var directionColLeft = -1
	var directionColRight = 1
	
	var left_col = old_grid_pos.x - 1
	var right_col = old_grid_pos.x + 1
	var row = old_grid_pos.y
	var pawn_type = main_script.get_pawn_info(_board[old_grid_pos.y][old_grid_pos.x],true,false)
	if pawn_type == "whiteKing":
		directionRow = -1
	if pawn_type == "blackKing":
		directionRow = 1

	if GlobalVariables.is_attack == false:
		var moves = possible_diagonal_move_king(row + directionRow, left_col , directionRow, directionColLeft, pawn_type,false,_board)
		if moves != []:
			for move in moves:
				local_possible_move_king.append(move)
		moves = possible_diagonal_move_king(row + directionRow, right_col , directionRow, directionColRight, pawn_type,false,_board)
		if moves != []:
			for move in moves:
				local_possible_move_king.append(move)
		# sprawdź ataki do tyłu
		moves = possible_diagonal_move_king(row - directionRow, left_col , -directionRow, directionColLeft, pawn_type,false,_board)
		if moves != []:
			for move in moves:
				local_possible_move_king.append(move)
		moves = possible_diagonal_move_king(row - directionRow, right_col, -directionRow, directionColRight, pawn_type,false,_board)
		if moves != []:
			for move in moves:
				local_possible_move_king.append(move)
	else:
		var moves = possible_diagonal_move_king(row + directionRow, left_col , directionRow, directionColLeft, pawn_type,true,_board)
		if moves != []:
			for move in moves:
				local_possible_move_king.append(move)
		moves = possible_diagonal_move_king(row + directionRow, right_col , directionRow, directionColRight, pawn_type,true,_board)
		if moves != []:
			for move in moves:
				local_possible_move_king.append(move)
		# sprawdź ataki do tyłu
		moves = possible_diagonal_move_king(row - directionRow, left_col , -directionRow, directionColLeft, pawn_type,true,_board)
		if moves != []:
			for move in moves:
				local_possible_move_king.append(move)
		moves = possible_diagonal_move_king(row - directionRow, right_col, -directionRow, directionColRight, pawn_type,true,_board)
		if moves != []:
			for move in moves:
				local_possible_move_king.append(move)
	return local_possible_move_king

func possible_diagonal_move_king(_row: int, _col: int, row_step: int, col_step: int, pawn_type: String, isAttak: bool,_board):
	var empty_cells = []
	var attack_cells = []
	
	var isEnemy: bool = false
	var consecutiveEnemies: int = 0
	var check_pawn_type = []
	var check_pawn_type_white = ["white","whiteKing"]
	var check_pawn_type_black = ["black","blackKing"]

	if pawn_type == "whiteKing":
		check_pawn_type = check_pawn_type_white
	elif pawn_type == "blackKing":
		check_pawn_type = check_pawn_type_black

	while _row >= 0 and _row < 8 and _col >= 0 and _col < 8:
		var cell_info = main_script.get_pawn_info(_board[_row][_col],true,false)
		if cell_info in check_pawn_type:
			break
		if cell_info in check_pawn_type_white or cell_info in check_pawn_type_black:
			consecutiveEnemies += 1
			if _row + row_step >= 0 and _row + row_step < 8 and _col + col_step >= 0 and _col + col_step < 8 and _board[_row + row_step][_col + col_step] == null:
				isEnemy = true
				#isEnemyOppomentJump.append([_row,_col])
		elif _board[_row][_col] == null and isEnemy and consecutiveEnemies < 2:
			if _row - row_step >= 0 and _row - row_step < 8 and _col - col_step >= 0 and _col - col_step < 8 and (_board[_row - row_step][_col - col_step] in check_pawn_type_white or _board[_row - row_step][_col - col_step] in check_pawn_type_black):
				break
			empty_cells.append([_row, _col])
			if isAttak:
				attack_cells.append([_row, _col])
		elif GlobalVariables.board[_row][_col] == null and !isEnemy and consecutiveEnemies < 2:
			if !isAttak:
				empty_cells.append([_row, _col])
		_row += row_step
		_col += col_step
	return empty_cells if not isAttak else attack_cells

# ============================================================ ALL POSSIBLE MOVE ====================================================

func all_possible_moves(type_pawn: String,_board:Array) -> bool:
	var allPossibleMoves = []
	#var isKing = type_pawn.ends_with("King")
	for i in range(8):
		for j in range(8):
			if main_script.get_pawn_info(_board[i][j],true,false).begins_with(type_pawn):
				var directionRow = null
				var directionColLeft = -1
				var directionColRight = 1
				old_grid_pos = find_pawn_position(main_script.get_pawn_info(_board[i][j],false,true),_board)
				var left_col = j - 1
				var right_col = j + 1
				var row = i
				
				if type_pawn.begins_with("white"):
					directionRow = -1
				else:
					directionRow = 1
				var isKing = main_script.get_pawn_info(_board[i][j],true,false).ends_with("King")
				var moves = []
				if isKing:
					
					moves = possible_diagonal_move_king(row + directionRow, left_col , directionRow, directionColLeft, type_pawn,false,_board)
					if moves != []:
						for move in moves:
							allPossibleMoves.append(move)
					moves = possible_diagonal_move_king(row + directionRow, right_col , directionRow, directionColRight, type_pawn,false,_board)
					if moves != []:
						for move in moves:
							allPossibleMoves.append(move)
					# sprawdź ataki do tyłu
					moves = possible_diagonal_move_king(row - directionRow, left_col , -directionRow, directionColLeft, type_pawn,false,_board)
					if moves != []:
						for move in moves:
							allPossibleMoves.append(move)
					moves = possible_diagonal_move_king(row - directionRow, right_col, -directionRow, directionColRight, type_pawn,false,_board)
					if moves != []:
						for move in moves:
							allPossibleMoves.append(move)
					# Gdy jest atak
					moves = possible_diagonal_move_king(row + directionRow, left_col , directionRow, directionColLeft, type_pawn,true,_board)
					if moves != []:
						for move in moves:
							allPossibleMoves.append(move)
					moves = possible_diagonal_move_king(row + directionRow, right_col , directionRow, directionColRight, type_pawn,true,_board)
					if moves != []:
						for move in moves:
							allPossibleMoves.append(move)
					# sprawdź ataki do tyłu
					moves = possible_diagonal_move_king(row - directionRow, left_col , -directionRow, directionColLeft, type_pawn,true,_board)
					if moves != []:
						for move in moves:
							allPossibleMoves.append(move)
					moves = possible_diagonal_move_king(row - directionRow, right_col, -directionRow, directionColRight, type_pawn,true,_board)
					if moves != []:
						for move in moves:
							allPossibleMoves.append(move)
				else:
					row += directionRow
					if possible_diagonal_move(row, left_col,_board) == true:
						allPossibleMoves.append([row,left_col])
					if possible_diagonal_move(row, right_col,_board) == true:
						allPossibleMoves.append([row,right_col])
					if possible_diagonal_jump(row, left_col,directionRow,directionColLeft,_board) == true:
						allPossibleMoves.append([row + directionRow,left_col + directionColLeft])
					if possible_diagonal_jump(row, right_col,directionRow,directionColRight,_board) == true:
						allPossibleMoves.append([row + directionRow,right_col + directionColRight])
					# Sprawdzanie ataku do tyłu
					row -= 2*directionRow
					if possible_diagonal_jump(row, left_col,-directionRow,directionColLeft,_board) == true:
						allPossibleMoves.append([row - directionRow,left_col + directionColLeft])
					if possible_diagonal_jump(row, right_col,-directionRow,directionColRight,_board) == true:
						allPossibleMoves.append([row - directionRow,right_col + directionColRight])

	return allPossibleMoves.size() == 0 


# Przygotować dla ai posible ruchy itd
