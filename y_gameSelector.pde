///////////////
// GAME CODE //
///////////////

#include <SPI.h>
#include <TCL.h>
#include <math.h>

namespace gameSelector {

  void game_boot();
  void game_update();
  void game_draw();
  void draw_flash();
  void draw_logo();
  void fire();
  void pixellate(float pixel_alpha);
  void wrap();
  void step();


  float pixel_alpha;
  int whiteness;
  int saver = 0;
  boolean insane_saver = 0;

  int gameMode;
  const int _mode_whiteRising = 1;
  const int _mode_pixelReveal = 2;
  const int _mode_selecting = 3;
  const int _mode_saving = 4;

  void game_boot() {
    pixel_alpha = 0.5;
    whiteness = 255;
    gameMode = _mode_whiteRising;
  }

  void game_update() {
    switch (gameMode) {
      case _mode_whiteRising:

        whiteness+=17;
        if (whiteness>255) {
          whiteness = 255;
          gameMode = _mode_pixelReveal;
        }

      break;
      case _mode_pixelReveal:

        if (pixel_alpha > 0) {
          pixel_alpha-=0.01;
        } else {
          gameMode = _mode_selecting;
        }

        if (whiteness > 0) {
          whiteness -= 17;
        } else {
          whiteness = 0;
        }

      break;
      case _mode_selecting:
        if (state[2][2] == _down) {
          currentGame = _pongGame;
          pongGame::game_boot();
        }
        if (state[2][1] == _down) {
          currentGame = _simonGame;
          simon::game_boot();
        }
        if (state[2][3] == _down){
          currentGame = _dance;
          dance::game_boot();
        }
      break;
      case _mode_saving:
        if (numberSquaresDownOrPressed()>0){
          gameMode = _mode_selecting;
        }
        break;
    }
  }

  void start_saver(){
    if (currentGame!=_gameSelector ||  gameMode != _mode_saving) {
      saver = mrandom(0,4);
      currentGame = _gameSelector;
      if (saver == 5) { 
        insane_saver = 1;
      } else {
        insane_saver = 0;
      }
      gameMode = _mode_saving;
    } 
    if (insane_saver) { saver = mrandom(0,3); }
  }

  void game_draw() {
    switch (gameMode) {
      case _mode_whiteRising:
        draw_all(0,0,0);
        draw_flash();
      break;
      case _mode_pixelReveal:
        draw_all(0,0,0);
        draw_logo();
        pixellate(pixel_alpha);
        if (whiteness > 0) {draw_flash();}
      break;
      case _mode_selecting:
        draw_all(0,0,0);
        draw_logo();
        draw_square(2,2,150,0,0);
        draw_square(2,1,0,150,0);
        draw_square(2,3,150,150,0);        
      break;
      case _mode_saving:
        if (saver==0){step();}
        if (saver==1){pixellate(1);}
        if (saver==2){wrap();}
        if (saver==3){fire();}
      break;
    }
  }

  void draw_logo() {
    printChar(19,1,'L',150,150,150);
    printChar(19,6,'O',150,150,150);
    printChar(19,11,'D',150,150,150);
    printChar(19,16,'O',150,150,150);
  }

  void draw_flash() {
    draw_all(whiteness,whiteness,whiteness);
  }

  //
  // Assign the board random colors
  //
  void step(){
    if (_functionDebug) { Serial.println("Entering Step"); }
    for (int row=0; row<4; row++){
      for (int col=0; col<4; col++){
        int r = random(3000);
        int g = random(300);
        int b = random(300);
        if (r < 200){
      for (int i=0; i<5; i++){
        for (int j=0; j<5; j++){
          set_pixel(row*5+i, col*5+j,r,g,b);
        }
      }
        }
      }
    }
  }


void pixellate(float alpha){
  for (int row=0; row<20; row++){
    for (int col=0; col<20; col++){
        int type = random(10);
        switch (type){
          case 0:  set_pixel_alpha(row,col,0,0,0,alpha); break;
          case 1:  set_pixel_alpha(row,col,255,0,0,alpha); break;
          case 2:  set_pixel_alpha(row,col,0,255,0,alpha); break;
          case 3:  set_pixel_alpha(row,col,0,0,255,alpha); break;
          case 4:  set_pixel_alpha(row,col,0,128,255,alpha); break;
          case 5:  set_pixel_alpha(row,col,128,0,255,alpha); break;
          case 6:  set_pixel_alpha(row,col,0,0,0,alpha); break;
          case 7:  set_pixel_alpha(row,col,255,255,0,alpha); break;
          case 8:  set_pixel_alpha(row,col,0,255,255,alpha); break;
          case 9:  set_pixel_alpha(row,col,255,0,255,alpha); break;
          default: set_pixel_alpha(row,col,0,0,0,alpha); break;
        }
    }
  }
}


  void wrap(){
    int dist = (currentTime/6)%400;
    draw_all(0,0,0);
    int dir = 2;  // 1 left; 2 up; 3 right; 4 down
    int row = -1; int col = 0;
    int layer = 0; // layer pixel to the center 
    for (int p=0; p<=dist; p++){  
      if (dir == 2) {
        row++;
        if (row >= 19-layer) { dir=3; }
      } else if (dir == 3) {
        col++;
        if (col >= 19-layer) { dir=4; }
      } else if (dir == 4) {
        row--;
        if (row <= 0+layer) { dir=1; }
      } else { // dir = 1
        col--;
        if (col <= 1+layer) { dir=2; layer++; }
      }
      set_pixel(row,col,128,128,0);
    }
  }


  void fire(){
    int color = 0; int change = 0; 
    int time = currentTime%32000;
    int intensity;
    if (time<=20000) { 
      intensity = time/100;
    } else {
      intensity = (20000-time)/200;
    }
    intensity = max(10,intensity);
    int r=0; int g=0; int b=0;
    for (int i=0; i<20; i++){
        for (int j=0; j<20; j++){
          change = random(0,70);
          if (change > 5) {
              r = random(0,intensity);
              g = random(0,int(r/2));
              set_pixel(i,j,r,g,0);
            }
        }
      }
  }

}
