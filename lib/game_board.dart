import 'dart:html';

import 'package:chess_app/components/square.dart';
import 'package:chess_app/helper/helper_methods.dart';
import 'package:chess_app/values/colors.dart';
import 'package:flutter/material.dart';
import '../components/piece.dart';

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

  // use selected a piece
  void pieceSelected(int row, int col) {
    setState(() {
      //selected a piece if there is a piece in that position
      if (board[row][col] != null) {
        selectedPiece = board[row][col];
        selectedCol = col;
        selectedRow = row;
      }
      // if a piece is selected, calculate it's valid moves
      valiseMoves =
          calculateRowValidMoves(selectedRow, selectedCol, selectedPiece);
    });
  }

  //calculate raw valid moves
  List<List<int>> calculateRowValidMoves(
      int row, int colm, ChessPiece? selectedPiece) {
    List<List<int>> candidateMoves = [];

    //different directions based on their color
    int direction = piece!.isWhite ? -1 : 1;

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
            board[row + direction][col - 1] !.isWhite 
            ) {
          candidateMoves.add([row + direction, col - 1]);
        }
        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            board[row + direction][col + 1] !.isWhite 
            ) {
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
      for ( var direction in directions) {
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
      
        break;
      case ChessPieceType.bishop:
        break;
      case ChessPieceType.queen:
        break;
      case ChessPieceType.king:
        break;
      default:
    }
    return candidateMoves;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: GridView.builder(
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
          for(var position in validMoves) {
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
    );
  }
}
