import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:exp_no_sense_snek_14/snakeStartBloc.dart';
// import 'package:sensors/sensors.dart';
import 'main.dart';
// import 'snakeState.dart';
import 'score.dart';

import 'snakeStartBloc.dart';
import 'siBlocBase.dart';
import 'dart:ui' as ui;

Timer snake_game_timer;

// delay for main timer in milliseconds
final int sg_main_time_delay = 888;


final math.Random random = math.Random();

const int rows = 33;
const int columns = 33;

double cellSize = 20.0;
// var cellSize = 0.0;

class Snake extends StatefulWidget {
  Snake(
      {

this.state
      }) {
    assert(10 <= rows);
    assert(10 <= columns);
    // assert(5.0 <= cellSize);
  }

  SnakeStartBloc state;

  State<StatefulWidget> createState() => SnakeState(

      );
}



class SnakeState extends State<Snake> {

  math.Point oldDirection;


  @override
  void dispose() {
    super.dispose();
   // print("DISPOSE SNAKE STATE");
    if (snake_game_timer != null) {
      snake_game_timer.cancel();
    }
  }

  onWidgetDidUpdate(Widget oldWidget){
    if (oldWidget != widget){
      //print("Snake Step State widget update Event Fire ~~ ");
    }
  }

  @override
  Widget build(BuildContext context) {
      //print(" Custom board panter builder parent build ~~");

    final SnakeStartBloc ss_bloc_inst =
    siBlocProvider.of<SnakeStartBloc>(context);

      void _step() {
        //print("Game step ~~ STEP ~~");
        if (ss_bloc_inst.game_over == true){
          //print("GAME OVER in _step ~~ return ");
          snake_game_timer.cancel();
          return;
        }

        //print("step input setting :: " + input_setting.toString());
// Reset both inputs to false anc check from state
        var ss_bloc_inst_left = false;
        var ss_bloc_inst_right = false;

// Look for values from stream to override everything else
        if (ss_bloc_inst.sub_val != null) {
          if (ss_bloc_inst.sub_val == "RPress") {
            ss_bloc_inst_right = true;
          }

          if (ss_bloc_inst.sub_val == "LPress") {
            ss_bloc_inst_left = true;
          }
        }

        //print("pass input calc");

        ///#################################3
        if (input_setting == "Touch") {
          if (ss_bloc_inst_left == true) {
            //print("ss_bloc_inst right true set");
            ss_bloc_inst.newDirection = oldDirection == null
                ? math.Point(0, 1)
                : oldDirection == math.Point(-1, 0)
                ? math.Point(0, 1)
                : oldDirection == math.Point(0, 1)
                ? math.Point(1, 0)
                : oldDirection == math.Point(1, 0)
                ? math.Point(0, -1)
                : oldDirection == math.Point(0, -1)
                ? math.Point(-1, 0)
                : math.Point(0, 1);
          } else if (ss_bloc_inst_right == true) {
            //print("ss_bloc_inst left true set");
            ss_bloc_inst.newDirection = oldDirection == null
                ? math.Point(0, 1)
                : oldDirection == math.Point(-1, 0)
                ? math.Point(0, -1)
                : oldDirection == math.Point(0, 1)
                ? math.Point(-1, 0)
                : oldDirection == math.Point(1, 0)
                ? math.Point(0, 1)
                : oldDirection == math.Point(0, -1)
                ? math.Point(1, 0)
                : math.Point(0, 1);
          }
          // Initial Direction,  vertical (0,1) or (0 ,-1)
          // Horizontal (1,0) or (-1, 0)
          // Diagonal top left  -> bottom right math.Point(1, 1) or math.Point(-1, -1)
          // Diagonal top right  -> bottom left math.Point(1, -1) or math.Point(-1, 1)
          else if (ss_bloc_inst_right == false && ss_bloc_inst_left == false) {
            ss_bloc_inst.newDirection = oldDirection == null ? math.Point(1 , 0)
                : oldDirection;
          }
        }
        setState(() {
          ss_bloc_inst.sub_val = null;
        });

        oldDirection = ss_bloc_inst.newDirection;

        ss_bloc_inst_stepper() {

          setState(() {
            _step();
          });

        }
        ss_bloc_inst.step(ss_bloc_inst.newDirection, ss_bloc_inst_stepper);
        if (
        // ss_bloc_inst.head_pt.x < 0 ||
        // ss_bloc_inst.head_pt.y < 0 ||

// Infinite snek mode, go through walls
         ss_bloc_inst.head_pt.x == columns  || ss_bloc_inst.head_pt.y == rows ) {
      // ss_bloc_inst.head_pt.x == columns - 1  || ss_bloc_inst.head_pt.y == rows -1) {
          //print("GAME OVER Resetting ss_bloc_inst ... ");
          ss_bloc_inst.game_over = true;

          var snek_score_final = ss_bloc_inst.score();


          if (snake_game_timer != null) {
            //print("cancel game timer");
            snake_game_timer.cancel();
          }
          Navigator.push(context,
              MaterialPageRoute(builder: (context) =>
                  siBlocProvider<SnakeStartBloc>(
              bloc: ss_bloc_inst,
              child:  SnekScore(snek_score_final))));

        }
      }

      if (ss_bloc_inst == null){
        //print("state null, have to wait for state to build paint ...");
        }else{
        //print("return sdp_board painter");

        return
          siBlocProvider<SnakeStartBloc>(
            bloc: ss_bloc_inst,
            child:
            SDP_Bloc_W(
              stepf: _step,
              sdp_state: ss_bloc_inst,
            )
          );
      }
      print("skip new ssb ret container");
    return Container();
  }

}

class SDP_Bloc_W extends StatefulWidget {
            SDP_Bloc_W( {this.stepf, this.sdp_state});
            Function stepf;
            SnakeStartBloc sdp_state;
  @override
  _SDP_Bloc_WState createState() => _SDP_Bloc_WState();
}

class _SDP_Bloc_WState extends State<SDP_Bloc_W> {

  initState(){
    if (snake_game_timer == null){
      //print("snake game timer null  ");
      if (widget.sdp_state != null){
       // print("init state  set timer ... ");
        snake_game_timer = 
        Timer.periodic(Duration(milliseconds: sg_main_time_delay), (_) {

         print("MSG Step");
          if (mounted) {
            // call to check streams for values from input set in state
            // make step look at streams
            if (widget.sdp_state.game_over == true) {
             print("CGAME OVER cancel snake game timer");
              snake_game_timer.cancel();

              return;
            }
            // stop_exp();
            setState(() {
              widget.stepf();
            });

            // exp testing
            // setState(() {
            //   widget.sdp_state.show_food_exp = true;
            // });
          }
        });
        
        }
    
    }
  }

  dispose(){
    print("sdp bloc wstate call dispose");

    snake_game_timer.cancel();
  super.dispose();
  }


  @override
  Widget build(BuildContext context) {
   SnakeStartBloc ss_bloc_inst =
    siBlocProvider.of<SnakeStartBloc>(context);

   if (ss_bloc_inst == null){
    // print("ss bloc inst null before board painter,, ret cont");
     return  Container();
       }

  // print("pre board painter state check ~~ ");
 //   print( "state theme color ~"+ ss_bloc_inst.g_theme_color.toString());
    // return siBlocProvider<SnakeStartBloc>(
    // bloc: ss_bloc_inst,
    // child:
  // return  CustomPaint(painter: SnakeBoardPainter(cellSize, ss_bloc_inst));
    // );

    return SnakeBoard(state: ss_bloc_inst);
  }
}

class SnakeBoard extends StatelessWidget {
  SnakeBoard({this.state});

  double cellSize;
  SnakeStartBloc state;

  @override
  Widget build(BuildContext context) {
  return CustomPaint(painter:   SnakeBoardPainter( state: state));

  }
}

class SnakeBoardPainter extends CustomPainter {
  SnakeBoardPainter( {this.state});

  final SnakeStartBloc state;

  //cell size is size of snake body pieces in pxls
  final double cellSize = 10.0;

  void paint(Canvas canvas, Size size) {
    if (state == null){
     // print("SNAKE PAINT STATE null return temp");
      return;
    }

   // print("SNAKE PAINT FIRE ~~~  g theme color ~ "+ state.g_theme_color.toString() );

    // draw grid for testing alignments
    List<List<Offset>> grid_pts = [
      [Offset(0.0,cellSize * 1), Offset(columns * cellSize , cellSize * 1)],
      // [Offset(0.0,cellSize * 2), Offset(columns * cellSize,cellSize * 2)],
      // [Offset(0.0,cellSize * 3), Offset(columns * cellSize,cellSize * 3)],
      // [Offset(0.0,cellSize * 4), Offset(columns * cellSize,cellSize * 4)],
      // [Offset(0.0,cellSize * 5), Offset(columns * cellSize,cellSize * 5)],
      // [Offset(0.0,cellSize * 6), Offset(columns * cellSize,cellSize * 6)],
      // [Offset(0.0,cellSize * 7), Offset(columns * cellSize,cellSize * 7)],

      //vertical
      [Offset(cellSize * 1,0.0), Offset(cellSize * 1, rows * cellSize)],//leftmost
      
      // [Offset(cellSize * 2,0.0), Offset(cellSize * 2, rows * cellSize )],
      
      // [Offset(cellSize * 3,0.0), Offset(cellSize * 3,rows * cellSize )],
      // [Offset(cellSize * 4,0.0), Offset(cellSize * 4, rows * cellSize )],

    [Offset(cellSize * columns ,0.0), Offset( cellSize * columns - 5.0 , cellSize* columns )],
      // [Offset(590.0,0.0), Offset( (columns * cellSize) - 10.0 , columns * cellSize)],//rightmost
      // [Offset(cellSize * columns / 2, 600.0), Offset(cellSize * rows / 2, rows * cellSize)],//center

    ];
    final gridpaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    grid_pts.forEach((element) {
      canvas.drawLine(element[0], element[1], gridpaint);
    });


  

    // paint
    if (state != null) {
      final Paint blackLine = Paint()
        ..color = state.g_theme_color;
      final Paint blackFilled = Paint()
        ..color = state.g_theme_color
        ..style = PaintingStyle.fill;
      // canvas.drawRect(
      //   Rect.fromPoints(Offset.zero, size.bottomLeft(Offset.zero)),
      //   blackLine,
      // );

      /// Draw snek body from state.body
      /// Transport snek

// transport with hacky limits
      for (math.Point<int> p in state.body) {
        // if (cellSize == null){ cellSize = state.sscreen_size.width / 30; }
        final Offset a = Offset(cellSize * p.x, cellSize * p.y);
        final Offset b = Offset(cellSize * (p.x + 1), cellSize * (p.y + 1));

        // Snek Body modes
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        // Ghost mode Snek
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // final pointMode = ui.PointMode.points;
        //     final points = [
        //         Offset(a.dx, a.dy),
        //       Offset(a.dx +3, a.dy +3),
        //     ];
        // final paint = Paint()
        //   ..color = Colors.white24
        //   ..strokeWidth = 4
        //   ..strokeCap = StrokeCap.round;
        // canvas.drawPoints(pointMode, points, paint);

        // Regular snek
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        canvas.drawRect(Rect.fromPoints(a, b), blackFilled);
        // canvas.drawImage(Image.asset('assets/bod_up_1.jpg'), Offset(a.dx,a.dy), Paint());
      }

      // Draw food 
      // if (state.food_pt.x != 0) {
        final Offset a = Offset(
            cellSize * state.food_pt.x, cellSize * state.food_pt.y);

        final Offset b = Offset(cellSize * (state.food_pt.x + 1),
            cellSize * (state.food_pt.y + 1));

        canvas.drawRect(Rect.fromPoints(a, b), blackFilled);
      // }
    }
  }

  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

}