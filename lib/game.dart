import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/* =========================================================
                        APP
========================================================= */

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LudoGame(),
    );
  }
}

/* =========================================================
                    FULL LUDO GAME
========================================================= */

class LudoGame extends StatefulWidget {
  const LudoGame({super.key});

  @override
  State<LudoGame> createState() => _LudoGameState();
}

class _LudoGameState extends State<LudoGame> {
  final random = Random();

  int dice = 1;
  int currentPlayer = 0;
  bool rolling = false;

  /// -1 home, 0–51 board
  List<List<int>> players = List.generate(4, (_) => [-1, -1, -1, -1]);

  final safeCells = [0, 8, 13, 21, 26, 34, 39, 47];

  final colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
  ];

  /* =========================================================
                      DICE ROLL
  ========================================================= */

  Future<void> rollDice() async {
    if (rolling) return;

    rolling = true;

    /// dice animation
    for (int i = 0; i < 8; i++) {
      setState(() => dice = random.nextInt(6) + 1);
      await Future.delayed(const Duration(milliseconds: 80));
    }

    dice = random.nextInt(6) + 1;

    rolling = false;

    /// bot auto play
    if (currentPlayer != 0) {
      await Future.delayed(const Duration(milliseconds: 500));
      botMove();
    }
  }

  /* =========================================================
                      PLAYER MOVE
  ========================================================= */

  Future<void> moveToken(int index) async {
    if (currentPlayer != 0) return;

    await _moveLogic(index);
  }

  Future<void> _moveLogic(int index) async {
    List<int> me = players[currentPlayer];

    int pos = me[index];

    /// enter board
    if (pos == -1) {
      if (dice != 6) return;
      me[index] = 0;
    } else {
      me[index] += dice;

      if (me[index] > 51) me[index] = 51;
    }

    killOthers(me[index]);

    if (checkWin()) return;

    if (dice != 6) nextTurn();

    setState(() {});
  }

  /* =========================================================
                        BOT AI
  ========================================================= */

  void botMove() {
    List<int> me = players[currentPlayer];

    for (int i = 0; i < 4; i++) {
      if (me[i] != -1 || dice == 6) {
        _moveLogic(i);
        break;
      }
    }
  }

  /* =========================================================
                        KILL RULE
  ========================================================= */

  void killOthers(int pos) {
    if (safeCells.contains(pos)) return;

    for (int p = 0; p < players.length; p++) {
      if (p == currentPlayer) continue;

      for (int i = 0; i < 4; i++) {
        if (players[p][i] == pos) {
          players[p][i] = -1;
        }
      }
    }
  }

  /* =========================================================
                        TURN
  ========================================================= */

  void nextTurn() {
    currentPlayer = (currentPlayer + 1) % 4;

    if (currentPlayer != 0) {
      rollDice();
    }
  }

  /* =========================================================
                        WIN
  ========================================================= */

  bool checkWin() {
    if (players[currentPlayer].every((e) => e >= 51)) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Player ${currentPlayer + 1} Wins 🎉"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                resetGame();
              },
              child: const Text("Restart"),
            )
          ],
        ),
      );
      return true;
    }
    return false;
  }

  void resetGame() {
    players = List.generate(4, (_) => [-1, -1, -1, -1]);
    currentPlayer = 0;
    setState(() {});
  }

  /* =========================================================
                          UI
  ========================================================= */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        title: Text("Ludo • Player ${currentPlayer + 1}"),
      ),
      body: Column(
        children: [

          /// BOARD
          Expanded(child: buildBoard()),

          /// TOKENS
          Wrap(
            spacing: 12,
            children: List.generate(4, (i) {
              return GestureDetector(
                onTap: () => moveToken(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colors[currentPlayer],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black),
                  ),
                  child: Center(child: Text("$i")),
                ),
              );
            }),
          ),

          const SizedBox(height: 10),

          /// DICE
          GestureDetector(
            onTap: rollDice,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: rolling ? Colors.grey : Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "🎲 $dice",
                style: const TextStyle(fontSize: 26),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /* =========================================================
                      BOARD DESIGN
  ========================================================= */

  Widget buildBoard() {
    return GridView.builder(
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 15),
      itemCount: 225,
      itemBuilder: (_, index) {
        int row = index ~/ 15;
        int col = index % 15;

        Color color = Colors.white;

        if (row < 6 && col < 6) color = Colors.red.shade300;
        if (row < 6 && col > 8) color = Colors.green.shade300;
        if (row > 8 && col < 6) color = Colors.blue.shade300;
        if (row > 8 && col > 8) color = Colors.yellow.shade300;

        if ((row >= 6 && row <= 8) || (col >= 6 && col <= 8)) {
          color = Colors.grey.shade200;
        }

        return Container(
          margin: const EdgeInsets.all(0.5),
          color: color,
        );
      },
    );
  }
}
