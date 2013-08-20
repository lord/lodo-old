#include <SPI.h>
#include <TCL.h>
#include <math.h>

void drawFire(){
	int color = 0; int change = 0;
	int r=0; int g=0; int b=0;
	for (int i=0; i<20; i++){
	    for (int j=0; j<20; j++){
		    change = random(0,10);
		    if (change > 5) {
		        r = random(0,255);
		        g = random(0,r);
		        set_pixel(i,j,r,g,0);
	        }
	    }
  	}
}

//
  // Assign the board random colors
  //
  void step(){
    if (_functionDebug) { Serial.println("Entering Step"); }
    for (int row=0; row<4; row++){
      for (int col=0; col<4; col++){
        int r = random(300);
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


void pixelate(){
if (_functionDebug) { Serial.println("Entering Pixelate"); }
	for (int row=0; row<19; row++){
		for (int col=0; col<19; col++){
		    int r = random(300);
		    int g = random(300);
		    int b = random(300);
		    if (r < 255){
				set_pixel(row*5+i, col*5+j,r,g,b);
			} else {
				set_pixel(row*5+i, col*5+j,0,0,0);
			}
		}
	}
}


  void d_wrap(int dist, int fg, int bg){
/*    d_square(0,0,20,bg);
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
      d_setPixel(row,col,fg);
    }*/
  }



