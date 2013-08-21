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
  void fire();
  void draw_flash();
  void draw_logo();

  float pixel_alpha;
  int whiteness;

  int gameMode;
  const int _mode_whiteRising = 1;
  const int _mode_pixelReveal = 2;
  const int _mode_selecting = 3;

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
      break;
    }
  }

  void game_draw() {
    draw_all(0,0,0);
    switch (gameMode) {
      case _mode_whiteRising:
        draw_flash();
      break;
      case _mode_pixelReveal:
        draw_logo();
        pixellate(pixel_alpha);
        if (whiteness > 0) {draw_flash();}
      break;
      case _mode_selecting:
        draw_logo();
        draw_square(2,2,150,0,0);
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
          change = random(0,10);
          if (change > 5) {
              r = random(0,intensity);
              g = random(0,int(r/2));
              set_pixel(i,j,r,g,0);
            }
        }
      }
  }

}
