/*****************************************************************************
 * lodo.ino
 *
 ****************************************************************************/
#include <SPI.h>
#include <TCL.h>
#include <math.h>

namespace dance {

  byte dist[4][4] = {{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0}};
  byte color[4][4] = {{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0}};

  void game_boot();
  void game_update();
  void game_draw();
  void draw_sqr(byte x, byte y, byte size, byte r, byte g, byte b);

  void game_boot() {
  }

  void game_update() {
    for (int i=0; i<4; i++){
      for (int j=0; j<4;j++){
        if (state[i][j] = _pressed){
          dist[i][j]=1;
          color[i][j] = mrandom(0,2);
        } else {
          if (dist[i][j]>0) {
            dist[i][j]++;
          }
          if (dist[i][j]>60){dist[i][j]=0;}
        }
      }
    }
  }

  void game_draw(){
    draw_all(0,0,0);
    set_border(5,0,5);
    for (int i=0; i<4; i++){
      for (int j=0; j<4;j++){
        if (dist[i][j] > 0){
          switch(color[i][j]){
            case 0: draw_sqr(i*5+2,j*5+2,dist[i][j],50,0,0); break;
            case 1: draw_sqr(i*5+2,j*5+2,dist[i][j],0,50,0); break;
            case 2: draw_sqr(i*5+2,j*5+2,dist[i][j],0,0,50); break;
            default: draw_sqr(i*5+2,j*5+2,dist[i][j],10,10,0); break;
          }
        }
      }
    }
  }

  void draw_sqr(byte x, byte y, byte size, byte r, byte g, byte b){
    for (int i=max(0,x-size/2); i<=min(x+size/2,19); i++){
      for (int j=max(0,y-size/2); j<=min(y+size/2,19); j++){
        r = min(255,r+pallette[i][j][0]);
        g = min(255,g+pallette[i][j][1]);
        b = min(255,b+pallette[i][j][2]);
        set_pixel(i,j,r,g,b);
      }
    }
  }
}