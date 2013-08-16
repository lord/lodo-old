////////////////////////////
// LODO SUPPORT FUNCTIONS //
////////////////////////////

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


// draws a filled rectangle somewhere on the pixel grid
void draw_rectangle(float x1, float y1, float x2, float y2, int r, int g, int b) {
  // implement this
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
  if (x2 > x1 and x2 < x1+w1 and y2 > y1 and y2 < y1+h1) {
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
  if (x <= _boardWidth and y <= _boardWidth and x >= 0 and y >= 0) {
    pallette[x][y][0] = r;
    pallette[x][y][1] = g;
    pallette[x][y][2] = b;
  }
}

void set_pixel_alpha(int x, int y, int r, int g, int b, float alpha) {
  if (x <= _boardWidth and y <= _boardWidth and x >= 0 and y >= 0 and alpha > 0) {
    if (alpha > 1) {alpha = 1;}
    pallette[x][y][0] += (int) ((r - pallette[x][y][0]) * alpha);
    pallette[x][y][1] += (int) ((g - pallette[x][y][1]) * alpha);
    pallette[x][y][2] += (int) ((b - pallette[x][y][2]) * alpha);
  }
}

int mrandom(int low, int high){
  int num = random(-10,10);
  while (num>high || num <low){ num = random(-10,10); }
  return num;
}