import 'dart:html';

import 'package:chess_app/components/square.dart';
import 'package:chess_app/helper/helper_methods.dart';
import 'package:chess_app/values/colors.dart';
import 'package:flutter/material.dart';
import '../components/piece.dart';
import 'components/dead_piece.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  //a 2 dimensional list representing the chessboard
  //with each position posiibly containing a chess piece

  late List<List<ChessPiece?>> board;

  //the currently selected piece on the chessboard
  //if no piece is selected this is null
  ChessPiece? selectedPiece;

  //the row index of the selected piece
  //default value -1 indicate than no piece is selected
  int selectedRow = -1;

  //the col index of the selected piece
  //default value -1 indicate than no piece is selected
  int selectedCol = -1;

  //a list of valid moves for the currently selected piece
  // each move is represented as a list with 2 elements : row & col
  List<List<int>> valiseMoves = [];

  //a list of white pieces that have been taken by the black player
  List<ChessPiece> whitePiecesTaken =[];

    //a list of black pieces that have been taken by the white player
  List<ChessPiece> blackPiecesTaken =[];

// booleon to indicate whose turn it is
bool isWhiteTurn = true;

//initial place of kings (keep track of this to make it easier later to see if king is in ch)
List<int> whiteKingPosition = [7, 4];
List<int> blackKingPosition = [0, 4];
bool checkStatus = false;

  @override
  void initState() {
    //todo: implement initState
    super.initState();
    _initializeBoard();
  }

  //INITIALIZE BOARD
  void _initializeBoard() {
    //initialized with nulls, meaning no pieces in those positions

    List<List<ChessPiece?>> newBoard =
        List.generate(8, (index) => List.generate(8, (index) => null));

    //place random piece in middle to test
    newBoard[3][3] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: true,
        imagePath: 'lib/images/rook.png');

    //place pawns
    for (int i = 0; i < 8; i++) {
      newBoard[1][i] = ChessPiece(
          type: ChessPieceType.pawn,
          isWhite: false,
          imagePath: 'lib/images/pawn.png');

      newBoard[6][i] = ChessPiece(
          type: ChessPieceType.pawn,
          isWhite: false,
          imagePath: 'lib/images/pawn.png');
    }

    //place rooks
    newBoard[0][0] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: false,
        imagePath: 'lib/images/rook.png');

    newBoard[0][7] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: false,
        imagePath: 'lib/images/rook.png');

    newBoard[7][0] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: true,
        imagePath: 'lib/images/rook.png');
    newBoard[7][7] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: true,
        imagePath: 'lib/images/rook.png');

    //place knights

    newBoard[0][0] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: false,
        imagePath: 'lib/images/knight.png');
    newBoard[0][6] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: false,
        imagePath: 'lib/images/knight.png');
    newBoard[7][1] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: true,
        imagePath: 'lib/images/knight.png');
    newBoard[7][6] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: true,
        imagePath: 'lib/images/knight.png');

    //place bishops
    newBoard[0][2] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: false,
        imagePath: 'lib/images/bishop.png');
    newBoard[0][5] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: false,
        imagePath: 'lib/images/bishop.png');
    newBoard[7][2] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: true,
        imagePath: 'lib/images/bishop.png');
    newBoard[7][5] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: true,
        imagePath: 'lib/images/bishop.png');
    //place queens
    newBoard[0][3] = ChessPiece(
        type: ChessPieceType.queen,
        isWhite: false,
        imagePath: 'lib/images/queen.png');
    newBoard[7][4] = ChessPiece(
        type: ChessPieceType.queen,
        isWhite: true,
        imagePath: 'lib/images/queen.png');

    //place kings
    newBoard[0][4] = ChessPiece(
        type: ChessPieceType.king,
        isWhite: false,
        imagePath: 'lib/images/king.png');
    newBoard[7][3] = ChessPiece(
        type: ChessPieceType.king,
        isWhite: true,
        imagePath: 'lib/images/king.png');

    board = newBoard;
  }

  // user selected a piece
  void pieceSelected(int row, int col) {
    setState(() {
      //no piece has been selected yet this is the first selection 
      if (selectedPiece == null && board[row][col] != null) {
        if(board[row][col]!.isWhite == isWhiteTurn){
          selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;

        }
      }

      //there is a piece already selected but user can select another one of their pieces
      else if (board[row][col] != null && board[row][col]!.isWhite == selectedPiece!.isWhite) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;        
      }

        //if there is a piece selected and user taps on a square that is a valid move, move there
        else if (selectedPiece != null && validMoves.any((Element) => Element.[0] == row && 
        element[1] == col)){
          movePiece(row, col);

  }
        // if a piece is selected, calculate it's a valid moves
        validMoves = calculateRowValidMoves(selectedRow, selectedCol, selectedPiece);
      });
  }

  

  //calculate raw valid moves
  List<List<int>> calculateRowValidMoves(
      int row, int colm, ChessPiece? selectedPiece) {
    List<List<int>> candidateMoves = [];

    if (piece == null) {
      return [];

    }

    //different directions based on their color
    int direction = piece.isWhite ? -1 : 1;


    switch (piece.type) {
      case ChessPieceType.pawn:
        //pawn can move forward if the square is not occupied
        if (isInBoard(row + direction, col) &&
            board[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);
        }

        //pawns can move 2 squares forward if they are at their initials positions
        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          if (isInBoard(row + 2 * direction, col) &&
              board[row + 2 * direction][col] == null &&
              board[row + direction][col] == null) {
            candidateMoves.add([row + 2 * direction, col]);
          }
        }

        // pawns can kill diagonally
        if (isInBoard(row + direction, col - 1) &&
            board[row + direction][col - 1] != null &&
            board[row + direction][col - 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col - 1]);
        }
        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            board[row + direction][col + 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col + 1]);
        }

        break;
      case ChessPieceType.rook:
        //horizontal and vertical directions
        var directions = [
          [-1, 0], //up
          [1, 0], //down
          [0, -1], //left
          [0, 1], //right
        ];
        for (var direction in directions) {
          var i = 0;
          while (true) {
            var newRow = row + 1 * direction[0];
            var newCol = col + 1 * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); //kill
              }
              break; //bloacked
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.knight:
        // all eight possible L shapes the knight can move
        var knightMoves = [
          [-2, -1], //up 2 left 1
          [-2, 1], //up 2 right 1
          [-1, -2], //up 1 left 1
          [-1, 2], //up 1 right 1
          [1, -2], //down 1 left 1
          [1, -2], //down 1 right 1
          [2, -1], //down 2 left 1
          [2, 1], //down 2 right 1
        ];
        for (var move in knightMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];
          if (isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]); //capture
            }
            continue; //blocked
          }
          candidateMoves.add([newRow, newCol]);
        }
        break;
      case ChessPieceType.bishop:
        // diagonal directions
        var directions = [
          [-1, -1], //up left
          [-1, 1], //up right
          [1, -1], //down left
          [1, 1], //down right
        ];
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + 1 * direction[0];
            var newCol = col + 1 * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); //capture
              }
              break; //bloacked
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }

        break;
      case ChessPieceType.queen:
        // all eight directions: up, down, left, right, and 4 diagonals
        var directions = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], // left
          [0, 1], // right
          [-1, -1], // up left
          [-1, 1], // up  right
          [1, -1], // down left
          [1, 1], // down right
        ];
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); //capture
              }
              break; //blocked
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;

      case ChessPieceType.king:
        //all eight directions
        var directions = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], // left
          [0, 1], // right
          [-1, -1], // up left
          [-1, 1], // up  right
          [1, -1], // down left
          [1, 1], // down right
        ];

        for (var direction in directions) {
          while (true) {
            var newRow = row + direction[0];
            var newCol = col + direction[1];
            if (!isInBoard(newRow, newCol)) {
              continue;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); //capture
              }
              continue; //blocked
            }
            candidateMoves.add([newRow, newCol]);
          }
        }
        break;
      default:
    }
    return candidateMoves;
  }

  // CALCULATE REAL VALID MOVES
  List<List<int>> calculateRealValidMoves (int row, int col, ChessPiece? piece, bool checkSimulation) {
  List<List<int>> realValidMoves = [];
  List<List<int>> candidateMoves = calculateRealValidMoves(row, col, piece);

  //after generating all candidate moves filter out any that would result in a check 
  if(checkSimulation){
    for (var move in candidateMoves) {
      int endRow = move[0];
      int endCol = move[1];
      if(simulatedMoveIsSafe()) {
        realValidMoves.add(move);
      }
    } 
    }
    else {

    }

  
  }

  
   
  // MOVE PIECE 
  void movePiece(int newRow, int newCol) {
 // if the new spot has an enemy piece 
 if (board[newRow][newCol] != null) {
   // add the captured piece to the appropriate list
   var capturedPiece = board[newRow][newCol];
   if(capturedPiece!.isWhite) {
    whitePiecesTaken.add(capturedPiece);
   } else {
    blackPiecesTaken.add(capturedPiece);
   }
 }
  // check if the piece is being moved in a king
  if(selectedPiece!.type == ChessPieceType.king){
    //update the appropriate king pos
    if(selectedPiece!.isWhite) {
      whiteKingPosition = [newRow, newCol];

    } else {
      whiteKingPosition = [newRow, newCol]; 
    }
  }

    //move the piece and clear the old spot
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;
     // see if any kings are under attack
     if(isKingInCheck(!isWhiteTurn)){
      checkStatus = true;

     } else {
            checkStatus = false;
     }

    //clear selection 
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      valiseMoves = [];
      }  );
 
  //change turns
  isWhiteTurn = !isWhiteTurn;
 }

 //is king in check
 bool isKingInCheck (bool isWhiteKing) {
  // get the position of the king 
  List<int> kingPosition = isWhiteKing ? whiteKingPosition : blackKingPosition;
  for (int i = 0; i < 8 ; i++){
    for (int j = 0; j < 8 ; j++) {
      // skip empty squares and pieces of the same color as the king
      if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing) {
        continue;

      }
      List<List<int>> pieceValidMoves = calculateRowValidMoves(i, j, board[i][j]);
      //check if king's position is in this place's valid moves
      if (pieceValidMoves.any((move) => move[0] == kingPosition[0] && move[1] == kingPosition[1])){
return true;
      }
    }

  }
  return false;
 }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
       children: [

        // WHITE PIECES TAKEN 
        Expanded(

          child: GridView.builder(
            itemCount: whitePiecesTaken.length,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8), 
          itemBuilder: (context, index) => DeadPiece(
            imagePath: whitePiecesTaken[index].imagePath,
            isWhite: true,
          ),
          ),
        ),

        // GAME STATUS
        Text(checkStatus ? "CHECK!" : ""),
         
        // CHESS BOARD

          Expanded(
            flex: 3,
            child: GridView.builder(
              itemCount: 8 * 8,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
              itemBuilder: (context, index) {
                // get the row and col position of this square
          
                int row = index ~/ 8;
                int col = index % 8;
          
                //check if this square is selected
                bool isSelected = selectedRow == row && selectedCol == col;
          
                //check is this square is a valid move
                bool isValidMove = false;
                for (var position in validMoves) {
                  //compare row and
                  if (position[0] == row && position[1] == col) {
                    isValidMove = true;
                  }
                }
                return Square(
                  isWhite: isWhite(index),
                  piece: board[row][col],
                  isSelected: isSelected,
                  isValidMove: isValidMove,
                  onTap: () => pieceSelected(row, col),
                );
              },
            ),
          ),
          // BLACK PIECES TAKEN
                  Expanded(
          child: GridView.builder(
            itemCount: blackPiecesTaken.length,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8), 
          itemBuilder: (context, index) => DeadPiece(
            imagePath: blackPiecesTaken[index].imagePath,
            isWhite: false,
          ),
          ),
        ),
        ],
      ),
    );
  }
}
