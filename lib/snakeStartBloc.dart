import 'package:flutter/material.dart';
import 'snekStateBase.dart';
import 'dart:async';
import 'dart:math' as math;
import 'snake.dart';

import 'dart:ui' as ui;
import 'package:image/image.dart' as image;

// delay for main timer in milliseconds
int sg_main_time_delay = 333;

class SnakeStartBloc implements snekStateBase {
  // Defaults, or Game over (creates new instance) ?
  SnakeStartBloc() {
    //print("Snake Start bloc Constructor called");
    sscreen_size;
    input_setting;
    g_theme_color;
    game_over;

    exp_pt = math.Point(0, 0);

    head_pt = math.Point(0, 0);
    food_pt = math.Point(random.nextInt(columns), random.nextInt(rows));

    body = <math.Point<int>>[const math.Point<int>(0, 0)];
    direction = const math.Point<int>(1, 0);

    // show_food_exp = false;
    show_food_exp = true;

    collisions_on = true;

    food_reset_interval;
    snake_length = 5;
    step_count = 0;
    show_food_exp_step = 0;

    foods_captured = 0;
    update_stream_has_listen = false;
    exp_stream_has_listen = false;
    show_food_exp = true;

    snake_game_timer = null;
    //  Timer.periodic(
    //     Duration(milliseconds: 555 - (30 * foods_captured)), (_) {
    //   print("null initsnake game timer runnning");
    //   // state_stepper();
    // });
  }

  Size sscreen_size;
  String input_setting = "Touch";
  Color g_theme_color = Colors.deepPurple;
  bool collisions_on;
  bool game_over = false;

  int food_reset_interval = 45;
  int snake_length = 5;

  math.Point exp_pt = math.Point(0, 0);
  math.Point head_pt = math.Point(0, 0);
  math.Point food_pt = math.Point(0, 4);
  List<math.Point<int>> body = <math.Point<int>>[const math.Point<int>(0, 0)];

  math.Point<int> direction;
  math.Point<int> newDirection;

  ui.Image paintExpImage;
  // pull submit val out from snakestate
  String sub_val;
  int step_count;
  // show explosion when get food
  bool show_food_exp = false;
  // need to cut off explosion animation after a few steps
  int show_food_exp_step;
  int exp_step_length_base = 6;
  int foods_captured;

  int sg_last_time_delay = sg_main_time_delay;

  Timer snake_game_timer;

  final math.Random random = math.Random();

  StreamController<Map> updateController = StreamController<Map>();
  StreamSink<Map> get update_sink => updateController.sink;
  Stream update_stream;
  bool update_stream_has_listen;

  Stream broadcast_update_stream() {
    Stream ic_bc_stream = updateController.stream.asBroadcastStream();
    update_stream = ic_bc_stream;
    return ic_bc_stream;
  }

  StreamController<bool> expController = StreamController<bool>();
  StreamSink<bool> get exp_sink => expController.sink;
  Stream exp_stream;
  bool exp_stream_has_listen = false;

  broadcast_exp_stream() {
    exp_stream = expController.stream.asBroadcastStream();
    return exp_stream;
  }

  void reset_food() {
    int food_pt_x = random.nextInt(columns);
    int food_pt_y = random.nextInt(rows);
    print("x: " + food_pt_x.toString() + " y: " + food_pt_y.toString());
    food_pt = math.Point(food_pt_x, food_pt_y);

    // for testing
    // food_pt = math.Point(1, 8);
  }

  int score() {
    return (step_count + foods_captured * 100);
  }

  step(math.Point<int> newDirection, Function state_stepper) {
    //print("step head pos ::: " + head_pt.x.toString() + ", " + head_pt.y.toString());
    //print("step food pos ::: " + food_pt.x.toString() + ", " + food_pt.y.toString());
    //print("step exp pos ::: " + exp_pt.x.toString() + ", " + exp_pt.y.toString());
    //print("Food pos ::: " + food_pt.toString());
    // print("step count ~ " + step_count.toString());
    // print("show food exp step ~ " + show_food_exp_step.toString());

    /// wait ten steps after showing explosion to turn off
    if ((step_count - show_food_exp_step >
            exp_step_length_base + (foods_captured * 2)) &&
        show_food_exp == true) {
      show_food_exp = false;
      exp_sink.add(false);
    }

    // print("Pre set body next direction :: " + direction.toString());
    math.Point<int> next = body.last + direction;
    next = math.Point<int>(next.x % columns, next.y % rows);
    head_pt = math.Point(next.x, next.y);
    body.add(next);
    if (body.length > snake_length) body.removeAt(0);
    direction = newDirection ?? direction;
    exp_pt = head_pt;

// reset food if step_count is at interval
    if ((step_count + (5 * foods_captured)) - food_reset_interval == 0 &&
        step_count != 0) {
      print("food set:: ");
      reset_food();
    }

    // init food at beginning only for testing
    // if (step_count == 0) {
    //   int food_pt_x = 3;
    //   int food_pt_y = 0;
    //   food_pt = math.Point(food_pt_x, food_pt_y);
    // }

    //Testing explosions
    // exp_sink.add(true);
    // exp_pt = head_pt;

    if (head_pt.x == food_pt.x && head_pt.y == food_pt.y) {
      print("WINRAR got food");
      show_food_exp = true;

      foods_captured += 1;

      // set exp point for animation before calling sink
      exp_pt = head_pt;
      show_food_exp_step = step_count;

      snake_length += 1;

      exp_sink.add(true);
      show_food_exp = true;
      reset_food();

      // speed snake
      if (snake_game_timer != null) {
        print("Reset game timer not null");
        snake_game_timer.cancel();
      }

      // print(
      //     "reset for level with foods captured ~ " + foods_captured.toString());
      snake_game_timer = null;
      sg_last_time_delay =
          (sg_last_time_delay - (80 * math.pow(.76, foods_captured))).toInt();

      snake_game_timer =
          Timer.periodic(Duration(milliseconds: sg_last_time_delay), (_) {
        // print("snake game timer runnning");
        state_stepper();
      });
    }

    step_count += 1;
  }

  void dispose() {
    if (snake_game_timer != null) {
      snake_game_timer.cancel();
    }
  }
}
