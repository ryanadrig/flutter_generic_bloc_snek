import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'main.dart';

math.Random random = math.Random();

class Snake extends StatefulWidget {
  Snake({this.rows = 40, this.columns = 40, this.cellSize = 10.0}) {
    assert(10 <= rows);
    assert(10 <= columns);
    assert(5.0 <= cellSize);
  }

  final int rows;
  final int columns;
  final double cellSize;

  @override
  State<StatefulWidget> createState() => SnakeState(rows, columns, cellSize);
}

class SnakeBoardPainter extends CustomPainter {
  SnakeBoardPainter(this.state, this.cellSize);

  GameState state;
  double cellSize;

  void paint(Canvas canvas, Size size) {
    final Paint blackLine = Paint()..color = Colors.white;
    final Paint blackFilled = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromPoints(Offset.zero, size.bottomLeft(Offset.zero)),
      blackLine,
    );

    /// Draw snek body from state.body
    for (math.Point<int> p in state.body) {
      final Offset a = Offset(cellSize * p.x, cellSize * p.y);
      final Offset b = Offset(cellSize * (p.x + 1), cellSize * (p.y + 1));

      canvas.drawRect(Rect.fromPoints(a, b), blackFilled);
    }

    /// Draw food if it needs
    if(state.food_pt.x != 0 ) {
      final Offset a =
      Offset(cellSize * state.food_pt.x,
          cellSize * state.food_pt.y);

      final Offset b = Offset(cellSize * (state.food_pt.x + 1),
          cellSize * (state.food_pt.y + 1));

      canvas.drawRect(Rect.fromPoints(a, b), blackFilled);
    }
  }


  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

Timer snake_game_timer;

class SnakeState extends State<Snake> {
  SnakeState(int rows, int columns, this.cellSize) {
    state = GameState(rows, columns);
  }

  double cellSize;
  GameState state;
  AccelerometerEvent acceleration;
  StreamSubscription<AccelerometerEvent> _streamSubscription;


  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: SnakeBoardPainter(state, cellSize));
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscription.cancel();
    snake_game_timer.cancel();
  }

  @override
  void initState() {
    super.initState();
    _streamSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
          setState(() {
            acceleration = event;
          });
        });

    snake_game_timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      setState(() {
        _step();
      });
    });
  }



  void _step() {
    final math.Point<int> newDirection = acceleration == null
        ? null
        : acceleration.x.abs() < 1.0 && acceleration.y.abs() < 1.0
        ? null
        : (acceleration.x.abs() < acceleration.y.abs())
        ? math.Point<int>(0, acceleration.y.sign.toInt())
        : math.Point<int>(-acceleration.x.sign.toInt(), 0);
    state.step(newDirection);

    print("state step");
    print(state.head_pt.x.toString());
    print(state.head_pt.y.toString());
    if (state.head_pt.x < 0 ||
        state.head_pt.y < 0 ||
    state.head_pt.x >= state.columns -1 ||
    state.head_pt.y >= state.rows -1

    ){
      print("GAMEEE OVERRRRR MEERRRROOOOWWWWWWWWWWWWW");

      snake_game_timer.cancel();

      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>
              SnakeStart()
          )
      );

    }
  }
}

class GameState {
  GameState(this.rows, this.columns) {
    snakeLength = math.min(rows, columns) - 10;
  }

  int step_count = 0;
  int rows;
  int columns;
  int snakeLength;

  math.Point food_pt = math.Point(0,0);
  math.Point head_pt = math.Point(0,0);

  List<math.Point<int>> body = <math.Point<int>>[const math.Point<int>(0, 0)];

  math.Point<int> direction = const math.Point<int>(1, 0);

  void step(math.Point<int> newDirection) {

    math.Point<int> next = body.last + direction;
    next = math.Point<int>(next.x % columns, next.y % rows);
      head_pt = math.Point(next.x,next.y);
    body.add(next);
    if (body.length > snakeLength) body.removeAt(0);
    direction = newDirection ?? direction;

    if (step_count % 37 == 0 ){
      print("food set:: ");

      int food_pt_x = random.nextInt(columns);
      int food_pt_y = random.nextInt(rows);
      print("x: " + food_pt_x.toString() + " y: " + food_pt_y.toString());
      food_pt = math.Point(food_pt_x, food_pt_y);
    }

    if (head_pt.x == food_pt.x &&
          head_pt.y == food_pt.y
    ){
      print("GOT FOOD WINRAR");
      snakeLength +=1;
    }
    step_count += 1;
  }
}