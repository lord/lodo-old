///////////////
// GAME CODE //
///////////////

#include <SPI.h>
#include <TCL.h>
#include <math.h>

namespace pongGame {

  void game_boot();
  void game_update(int);
  void game_draw(int);
  void draw_background();
  void draw_players();
  void update_ball();
  void draw_sensor_test();
  void update_players();
  void draw_ball(float, float, int, int, int);
  void draw_paddle(float, float, int, int, int);
  void reset_ball();
  void reset_game();
  float get_ball_bounce_dir(float,bool);
  float get_paddle_speed(float);

  float player1_y;
  float player2_y;
  float ball_x;
  float ball_y;
  float ball_vel;
  float ball_dir;

  int gameMode;
  const int _playingMode = 1;
  const int _player1WinMode = 2;
  const int _player2WinMode = 3;

  const float _paddle_speed_power = 0.8; 
  const float _paddle_speed_multiplier = 0.2;
  const int _paddle_height = 5;

  //distance between paddle and side
  const int _player_distance = 2;

  const float _ball_start_speed = 0.13;
  const float _ball_speedup = 0.04;

  void game_boot() {
    reset_game();
  }

  void game_update(int time) {
    // if (gameMode == _playingMode) {
      update_players();
      update_ball();
    // } else if ()
  }

  void game_draw(int time) {
    draw_background();
    draw_players();
    draw_ball(ball_x, ball_y,0,255,0);
  }

  void draw_background() {
    for (int i=0; i<20; i++){
      for (int j=0; j<20; j++){
        set_pixel(i,j,0,0,0);
      }
    }
  }

  void draw_players() {
    //player 1
    draw_paddle(_player_distance, player1_y, 255,0,0);

    //player 2
    draw_paddle(_boardWidth - _player_distance - 1, player2_y, 0,0,255);
  }

  void draw_ball(float x, float y, int r, int g, int b) {
    int drawx = (int) (x);
    int drawy = (int) (y);
    float extrax = x-drawx;
    float extray = y-drawy;
    set_pixel_alpha(drawx,drawy,r,g,b,1 - point_distance(0,0,extrax,extray));
    set_pixel_alpha(drawx+1,drawy,r,g,b,1 - point_distance(1,0,extrax,extray));
    set_pixel_alpha(drawx,drawy+1,r,g,b,1 - point_distance(0,1,extrax,extray));
    set_pixel_alpha(drawx+1,drawy+1,r,g,b,1 - point_distance(1,1,extrax,extray));
  }

  // gets the ball bounce direction
  // relative_y is the distance from the top of the paddle
  float get_ball_bounce_dir(float relative_y, bool player2) {
    if (player2 == false) {
      return ((0 + relative_y / _paddle_height) * 2.0/3.0*_pi) + 1.0/6.0*_pi - _pi/2;
    } else {
      return ((1 - relative_y / _paddle_height) * 2.0/3.0*_pi) + 1.0/6.0*_pi + _pi/2;
    }
  }

  float get_paddle_speed(float distance) {
    return pow(abs(distance), _paddle_speed_power) * _paddle_speed_multiplier;
  }

  void update_players() {
    float count = 0.0;
    float total = 0.0;
    float paddle_speed;
    for(int i=0; i<4; i++) {
      if (state[0][i] == _pressed or state[0][i] == _down) {
        count += 1.0;
        total += i*5.0;
      }
    }

    if (count > 0.0) {
      total = total / count;

      paddle_speed = get_paddle_speed(player1_y-total);

      if (player1_y - paddle_speed > total) {
        player1_y -= paddle_speed;
      } else if (player1_y + paddle_speed < total) {
        player1_y += paddle_speed;
      } else {
        player1_y = total;
      }
    }

    count = 0.0;
    total = 0.0;
    for(int i=0; i<4; i++) {
      if (state[3][i] == _pressed or state[3][i] == _down) {
        count += 1.0;
        total += i*5.0;
      }
    }

    if (count > 0.0) {
      total = total / count;

      paddle_speed = get_paddle_speed(player2_y-total);

      if (player2_y - paddle_speed > total) {
        player2_y -= paddle_speed;
      } else if (player2_y + paddle_speed < total) {
        player2_y += paddle_speed;
      } else {
        player2_y = total;
      }
    }
  }

  void reset_ball() {
    ball_x = 9;
    ball_y = 9;
    ball_vel = _ball_start_speed;
    ball_dir = _pi/4 + (_pi*random(0,1));
  }

  void reset_game() {
    player1_y = 7.5;
    player2_y = 7.5;
    gameMode = _playingMode;
    reset_ball();
  }

  void update_ball() {
    // move the ball
    ball_x += cos(ball_dir) * ball_vel;
    ball_y += sin(ball_dir) * ball_vel;

    // reset if behind a player
    if (ball_x < 0) {
      gameMode = _player2WinMode;
    } else if (ball_x > _boardWidth) {
      gameMode = _player1WinMode;
    }

    // bounce off walls
    if (ball_y < 0) {
      ball_y = 0;
      ball_dir *= -1;
    } else if (ball_y > _boardWidth) {
      ball_y = _boardWidth;
      ball_dir *= -1;
    }

    // bounce off player 1 paddle
    if (point_in_box(2,player1_y,1,_paddle_height,ball_x, ball_y)) {
      ball_x = 3.1;
      ball_dir = get_ball_bounce_dir(ball_y - player1_y,false);
      ball_vel += _ball_speedup;
    }

    // bounce off player 2 paddle
    if (point_in_box(_boardWidth-3,player2_y,1,_paddle_height,ball_x, ball_y)) {
      ball_x = _boardWidth - 3.1;
      ball_dir = get_ball_bounce_dir(ball_y - player2_y,true);
      ball_vel += _ball_speedup;
    }
  }

  void draw_paddle(float x, float y, int r, int g, int b) {
    // TODO CHANGE THIS TO USE DRAW_RECTANGLE
    int drawy = (int) (y);
    float extra = fmod(y,1.0);
    set_pixel_alpha(x,0+drawy,r,g,b,1-extra);
    set_pixel(x,1+drawy,r,g,b);
    set_pixel(x,2+drawy,r,g,b);
    set_pixel(x,3+drawy,r,g,b);
    set_pixel(x,4+drawy,r,g,b);
    set_pixel_alpha(x,5+drawy,r,g,b,extra);
    set_pixel_alpha(x+1,0+drawy,r,g,b,1-extra);
    set_pixel(x+1,1+drawy,r,g,b);
    set_pixel(x+1,2+drawy,r,g,b);
    set_pixel(x+1,3+drawy,r,g,b);
    set_pixel(x+1,4+drawy,r,g,b);
    set_pixel_alpha(x+1,5+drawy,r,g,b,extra);
  }

  void draw_random() {
    for (int i=0; i<20; i++){
      for (int j=0; j<20; j++){
        pallette[i][j][0] = random(0,40);
        pallette[i][j][1] = random(0,40);
        pallette[i][j][2] = random(0,40);
      }
    }
  }

  void draw_sensor_test() {
    for (int i=0; i<4; i++){
      for (int j=0; j<4; j++){
        if (state[i][j] == _down or state[i][j] == _pressed) {
          draw_square(i, j, 255,255,255);
        }
      }
    }
  }

}
