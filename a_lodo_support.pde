////////////////////////////
// LODO SUPPORT FUNCTIONS //
////////////////////////////
#include <stdio.h>
const float _pi = 3.1416;

void draw_square(int x, int y, int r, int g, int b) {
  for (int i=0; i<5; i++){
    for (int j=0; j<5; j++){
      pallette[5*x+i][5*y+j][0] = r;
      pallette[5*x+i][5*y+j][1] = g;
      pallette[5*x+i][5*y+j][2] = b;
    }
  }
}


void draw_square_alpha(int x, int y, int r, int g, int b, float alpha) {
  for (int i=0; i<5; i++){
    for (int j=0; j<5; j++){
      set_pixel_alpha(5*x+i,5*y+j,r,g,b,alpha);
    }
  }
}

// draws a non antialiased filled rect with upper left corner x, y & width w and height h
void draw_rectangle(int x, int y, int w, int h, int r, int g, int b) {
  for (int i=0; i<w; i++) {
    for (int j=0; j<h; j++) {
      set_pixel(x+i,y+j,r,g,b);
    }
  }
}

// floods the entire board with a color
void draw_all(int r, int g, int b) {
  for (int i=0; i<20; i++){
    for (int j=0; j<20; j++){
      set_pixel(i,j,r,g,b);
    }
  }
}

// measures distance between x1, y1 and x2, y2
float point_distance(float x1,float y1,float x2,float y2) {
  return sqrt(pow(x2-x1,2)+pow(y2-y1,2));
}

// checks if x2, y2 is in the box
bool point_in_box(float x1, float y1, float w1, float h1, float x2, float y2) {
  if (x2 > x1 && x2 < x1+w1 && y2 > y1 && y2 < y1+h1) {
    return true;
  } else {
    return false;
  }
}

// set a pixel, within the square with coords sq_x and sq_y.
// used for drawing stuff easily in a square
void set_pixel_square(int sq_x, int sq_y, int x, int y, int r, int g, int b) {
  set_pixel(sq_x*5+x,sq_y*5+y, r, g, b);
}

// set a pixel with the specified global x and y
void set_pixel(int x, int y, int r, int g, int b) {
  if (x <= _boardWidth && y <= _boardWidth && x >= 0 && y >= 0) {
    pallette[x][y][0] = r;
    pallette[x][y][1] = g;
    pallette[x][y][2] = b;
  }
}

void set_pixel_alpha(int x, int y, int r, int g, int b, float alpha) {
  if (x <= _boardWidth && y <= _boardWidth && x >= 0 && y >= 0 && alpha > 0) {
    if (alpha > 1) {alpha = 1;}
    pallette[x][y][0] += (int) ((r - pallette[x][y][0]) * alpha);
    pallette[x][y][1] += (int) ((g - pallette[x][y][1]) * alpha);
    pallette[x][y][2] += (int) ((b - pallette[x][y][2]) * alpha);
  }
}

void set_border(int r, int g, int b){
  for (int i=0; i<20; i++){
    set_pixel(0,i,r,g,b);
    set_pixel(19,i,r,g,b);
    set_pixel(i,0,r,g,b);
    set_pixel(i,19,r,g,b);
  }
}

void set_border2(int r, int g, int b){
  for (int i=0; i<20; i=i+2){
    set_pixel(0,i,r,g,b);
    set_pixel(19,i,r,g,b);
    set_pixel(i,0,r,g,b);
    set_pixel(i,19,r,g,b);
  }
}

int mrandom(int low, int high){
  int num = random(-10,10);
  while (num>high || num <low){ num = random(-10,10); }
  return num;
}

void printText(){
  char s[] = "Robert Lord pong master";
  unsigned long c1 = (currentTime/500) % 50;
  int offset = -int(c1);
  int i = 0;
  while (s[i] != 0){
    printChar(19,offset+i*4+20,s[i],255,255,255);  
    i++;
  }
}

int numberSquaresPressed(){
  int count=0;
  for (int i=0; i<4; i++){
    for (int j=0; j<4; j++){
       if (state[i][j] == _pressed) {
           count++;
       }
    }
  }
  return count; 
}

int numberSquaresDown(){
  int count=0;
  for (int i=0; i<4; i++){
    for (int j=0; j<4; j++){
       if (state[i][j] == _down) {
           count++;
       }
    }
  }
  return count; 
}

int numberSquaresDownOrPressed(){
    int count=0;
    for (int i=0; i<4; i++){
      for (int j=0; j<4; j++){
         if (state[i][j] == _down || state[i][j] == _pressed) {
             count++;
         }
      }
    }
    return count;
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
      set_pixel(row,col,255,255,255);
    }
  }
