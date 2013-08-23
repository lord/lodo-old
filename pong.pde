///////////////
// GAME CODE //
///////////////

#include <SPI.h>
#include <TCL.h>
#include <math.h>

namespace pongGame {

  void game_boot();
  void game_update();
  void game_draw();
  void draw_background();
  void draw_players();
  void update_ball();
  void draw_sensor_test();
  void update_players();
  void draw_ball(float, float, int, int, int);
  void draw_paddle(float, float, int, int, int);
  void reset_ball();
  void reset_game();
  void draw_score();
  void draw_flash();
  void draw_win();
  float get_ball_bounce_dir(float,bool);
  float get_paddle_speed(float);

  float player1_y;
  float player2_y;
  float ball_x;
  float ball_y;
  float ball_vel;
  float ball_dir;
  int player1_score;
  int player2_score;
  float player1_flash;
  float player2_flash;
  int gameTimer;

  int gameMode;
  const int _playingMode = 1;
  const int _scoreMode = 2;
  const int _winMode = 3;

  const float _paddle_speed_power = 0.8; 
  const float _paddle_speed_multiplier = 0.2;
  const int _paddle_height = 5;

  //distance between paddle and side
  const int _player_distance = 2;

  const float _ball_start_speed = 0.13;
  const float _ball_speedup = 0.04;
  const int _winning_score = 5;
  const float _flash_speed = 0.05;

  void game_boot() {
    reset_game();
  }

  void game_update() {
    update_players();
    if (gameMode == _playingMode) {
      update_ball();
    }
    if (player1_flash > _flash_speed) {player1_flash -= _flash_speed;} else {player1_flash=0;}
    if (player2_flash > _flash_speed) {player2_flash -= _flash_speed;} else {player2_flash=0;}
    if (gameTimer > 0) {gameTimer--;}
    if (gameMode == _scoreMode and gameTimer == 0) {
      reset_ball();
      gameMode = _playingMode;
    }
    if (gameMode == _winMode and gameTimer == 0) {
      reset_game();
    }
  }

  void game_draw() {
    if (gameMode == _winMode) {
      if (gameTimer % 10 == 0) {draw_win();}
    } else {
      draw_background();
      set_border(1,1,1);
      draw_score();
      draw_players();
      if (gameMode == _playingMode) {
        draw_ball(ball_x, ball_y,0,255,0);
      }
      draw_flash();
    }
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

  void draw_score() {
    draw_rectangle(0,0,1,(_boardWidth+1)/_winning_score*player1_score,255,0,0);
    draw_rectangle(_boardWidth,0,1,(_boardWidth+1)/_winning_score*player2_score,0,0,255);
  }

  void draw_flash() {
    if (player1_flash > 0) {
      draw_square_alpha(0,0,0,0,255,player1_flash);
      draw_square_alpha(0,1,0,0,255,player1_flash);
      draw_square_alpha(0,2,0,0,255,player1_flash);
      draw_square_alpha(0,3,0,0,255,player1_flash);
      draw_square_alpha(1,0,0,0,255,player1_flash);
      draw_square_alpha(1,1,0,0,255,player1_flash);
      draw_square_alpha(1,2,0,0,255,player1_flash);
      draw_square_alpha(1,3,0,0,255,player1_flash);
    }
    if (player2_flash > 0) {
      draw_square_alpha(3,0,255,0,0,player2_flash);
      draw_square_alpha(3,1,255,0,0,player2_flash);
      draw_square_alpha(3,2,255,0,0,player2_flash);
      draw_square_alpha(3,3,255,0,0,player2_flash);
      draw_square_alpha(2,0,255,0,0,player2_flash);
      draw_square_alpha(2,1,255,0,0,player2_flash);
      draw_square_alpha(2,2,255,0,0,player2_flash);
      draw_square_alpha(2,3,255,0,0,player2_flash);
    }
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

  void draw_win() {
    if (player1_score > player2_score) {
      for (int i=0;i<4;i++) {
        for (int j=0;j<4;j++) {
          draw_square(i,j,random(0,255),random(0,1),random(0,1));
        }
      }
    } else {
      for (int i=0;i<4;i++) {
        for (int j=0;j<4;j++) {
          draw_square(i,j,random(0,1),random(0,1),random(0,255));
        }
      }
    }
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
    player1_score = 0;
    player2_score = 0;
    player1_flash = 0;
    player2_flash = 0;
    gameMode = _playingMode;
    gameTimer = 0;
    reset_ball();
  }

  void update_ball() {
    // move the ball
    ball_x += cos(ball_dir) * ball_vel;
    ball_y += sin(ball_dir) * ball_vel;

    // reset if behind a player
    if (ball_x < 0) {
      player2_score++;
      player1_flash = 1.0;
      gameMode = _scoreMode;
      gameTimer = 50;
      reset_ball();
    } else if (ball_x > _boardWidth) {
      player1_score++;
      player2_flash = 1.0;
      gameMode = _scoreMode;
      gameTimer = 50;
      reset_ball();
    }

    // did that score just win? enter win mode
    if (player1_score >= _winning_score or player2_score >= _winning_score) {
      gameMode = _winMode;
      gameTimer = 350;
    }

    // bounce off walls
    if (ball_y < 1) {
      ball_y = 1;
      ball_dir *= -1;
    } else if (ball_y > _boardWidth - 1) {
      ball_y = _boardWidth - 1;
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
