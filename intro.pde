#include <SPI.h>
#include <TCL.h>
#include <math.h>

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


void pixellate(){
if (_functionDebug) { Serial.println("Entering Pixelate"); }
	for (int row=0; row<20; row++){
		for (int col=0; col<20; col++){
		    int type = random(10);
		    switch (type){
		    	case 0: set_pixel(row,col,0,0,0); break;
		    	case 1: set_pixel(row,col,255,0,0); break;
		    	case 2: set_pixel(row,col,0,255,0); break;
		    	case 3: set_pixel(row,col,0,0,255); break;
		    	case 4: set_pixel(row,col,0,128,255); break;
		    	case 5: set_pixel(row,col,128,0,255); break;
		    	case 6: set_pixel(row,col,0,0,0); break;
		    	case 7: set_pixel(row,col,255,255,0); break;
		    	case 8: set_pixel(row,col,0,255,255); break;
		    	case 9: set_pixel(row,col,255,0,255); break;
		    	default: set_pixel(row,col,0,0,0); break;
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
      set_pixel(row,col,255,255,255);
    }
  }



