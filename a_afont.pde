
// printChar
//
// Prints the  character c with lower left first pixel at x,y
// Standard orientation is _orient_90.  Other orientations are _orient_0, 
//    _orient_180, _orient_270
// The character will be clipped to X0/X1 & Y0/Y1
// The background is not colored
//
void printChar(int x, int y, int x0, int y0, int x1, int y1, 
    char c,  int orient, int r, int g, int b){ 

  int charIndex = 0;
  if (c>='0' and c<='9'){
    charIndex = c - '0';
  } else if (c>='a' and c<='z'){
    charIndex = c - 'a' + 10; 
  } else if (c>='A' and c<='Z'){
    charIndex = c - 'A' + 36; 
  } else if (c==' ') { return;}
    for (int i=0; i<5; i++){  // each line of the font
      if (getfont(charIndex,i) & 8 ){ set_pixel(x-4+i,y,r,g,b); 
      }
      if (getfont(charIndex,i) & 4) { set_pixel(x-4+i,y+1,r,g,b); 
      }
      if (getfont(charIndex,i) & 2) { set_pixel(x-4+i,y+2,r,g,b); 
      }
  }
}

int getfont(int character, int row) {
  if (row == 0){
    switch (character){
      case 0: return 6;
      case 1: return 4;
      case 2: return 12;
      case 3: return 12;
      case 4: return 10;
      case 5: return 14;
      case 6: return 6;
      case 7: return 14;
      case 8: return 14;
      case 9: return 14;
      case 10: return 0;
      case 11: return 8;
      case 12: return 0;
      case 13: return 2;
      case 14: return 0;
      case 15: return 2;
      case 16: return 6;
      case 17: return 8;
      case 18: return 4;
      case 19: return 2;
      case 20: return 8;
      case 21: return 12;
      case 22: return 0;
      case 23: return 0;
      case 24: return 0;
      case 25: return 12;
      case 26: return 6;
      case 27: return 0;
      case 28: return 0;
      case 29: return 4;
      case 30: return 0;
      case 31: return 0;
      case 32: return 0;
      case 33: return 0;
      case 34: return 10;
      case 35: return 0;
      case 36: return 4;
      case 37: return 12;
      case 38: return 6;
      case 39: return 12;
      case 40: return 14;
      case 41: return 14;
      case 42: return 6;
      case 43: return 10;
      case 44: return 14;
      case 45: return 2;
      case 46: return 10;
      case 47: return 8;
      case 48: return 10;
      case 49: return 10;
      case 50: return 4;
      case 51: return 12;
      case 52: return 4;
      case 53: return 12;
      case 54: return 6;
      case 55: return 14;
      case 56: return 10;
      case 57: return 10;
      case 58: return 10;
      case 59: return 10;
      case 60: return 10;
      case 61: return 14;
    }
  }
  if (row == 1){
    switch (character){
      case 0: return 10;
      case 1: return 12;
      case 2: return 2;
      case 3: return 2;
      case 4: return 10;
      case 5: return 8;
      case 6: return 8;
      case 7: return 2;
      case 8: return 10;
      case 9: return 10;
      case 10: return 12;
      case 11: return 12;
      case 12: return 6;
      case 13: return 6;
      case 14: return 6;
      case 15: return 4;
      case 16: return 10;
      case 17: return 12;
      case 18: return 0;
      case 19: return 0;
      case 20: return 10;
      case 21: return 4;
      case 22: return 14;
      case 23: return 12;
      case 24: return 4;
      case 25: return 10;
      case 26: return 10;
      case 27: return 6;
      case 28: return 6;
      case 29: return 14;
      case 30: return 10;
      case 31: return 10;
      case 32: return 10;
      case 33: return 10;
      case 34: return 10;
      case 35: return 14;
      case 36: return 10;
      case 37: return 10;
      case 38: return 8;
      case 39: return 10;
      case 40: return 8;
      case 41: return 8;
      case 42: return 8;
      case 43: return 10;
      case 44: return 4;
      case 45: return 2;
      case 46: return 10;
      case 47: return 8;
      case 48: return 14;
      case 49: return 14;
      case 50: return 10;
      case 51: return 10;
      case 52: return 10;
      case 53: return 10;
      case 54: return 8;
      case 55: return 8;
      case 56: return 10;
      case 57: return 10;
      case 58: return 10;
      case 59: return 10;
      case 60: return 10;
      case 61: return 2;
    }
  }
  if (row == 2){
    switch (character){
      case 0: return 10;
      case 1: return 4;
      case 2: return 4;
      case 3: return 4;
      case 4: return 14;
      case 5: return 12;
      case 6: return 14;
      case 7: return 4;
      case 8: return 14;
      case 9: return 14;
      case 10: return 6;
      case 11: return 10;
      case 12: return 8;
      case 13: return 10;
      case 14: return 10;
      case 15: return 14;
      case 16: return 14;
      case 17: return 10;
      case 18: return 4;
      case 19: return 2;
      case 20: return 12;
      case 21: return 4;
      case 22: return 14;
      case 23: return 10;
      case 24: return 10;
      case 25: return 10;
      case 26: return 10;
      case 27: return 8;
      case 28: return 12;
      case 29: return 4;
      case 30: return 10;
      case 31: return 10;
      case 32: return 14;
      case 33: return 4;
      case 34: return 6;
      case 35: return 6;
      case 36: return 14;
      case 37: return 12;
      case 38: return 8;
      case 39: return 10;
      case 40: return 14;
      case 41: return 14;
      case 42: return 14;
      case 43: return 14;
      case 44: return 4;
      case 45: return 2;
      case 46: return 12;
      case 47: return 8;
      case 48: return 14;
      case 49: return 14;
      case 50: return 10;
      case 51: return 12;
      case 52: return 10;
      case 53: return 14;
      case 54: return 4;
      case 55: return 8;
      case 56: return 10;
      case 57: return 10;
      case 58: return 14;
      case 59: return 4;
      case 60: return 4;
      case 61: return 4;
    }
  }
  if (row == 3){
    switch (character){
      case 0: return 10;
      case 1: return 4;
      case 2: return 8;
      case 3: return 2;
      case 4: return 2;
      case 5: return 2;
      case 6: return 10;
      case 7: return 8;
      case 8: return 10;
      case 9: return 2;
      case 10: return 10;
      case 11: return 10;
      case 12: return 8;
      case 13: return 10;
      case 14: return 12;
      case 15: return 4;
      case 16: return 2;
      case 17: return 10;
      case 18: return 4;
      case 19: return 10;
      case 20: return 12;
      case 21: return 4;
      case 22: return 14;
      case 23: return 10;
      case 24: return 10;
      case 25: return 12;
      case 26: return 6;
      case 27: return 8;
      case 28: return 6;
      case 29: return 4;
      case 30: return 10;
      case 31: return 14;
      case 32: return 14;
      case 33: return 4;
      case 34: return 2;
      case 35: return 12;
      case 36: return 10;
      case 37: return 10;
      case 38: return 8;
      case 39: return 10;
      case 40: return 8;
      case 41: return 8;
      case 42: return 10;
      case 43: return 10;
      case 44: return 4;
      case 45: return 10;
      case 46: return 10;
      case 47: return 8;
      case 48: return 10;
      case 49: return 14;
      case 50: return 10;
      case 51: return 8;
      case 52: return 14;
      case 53: return 12;
      case 54: return 2;
      case 55: return 8;
      case 56: return 10;
      case 57: return 4;
      case 58: return 14;
      case 59: return 10;
      case 60: return 4;
      case 61: return 8;
    }
  }
  if (row == 4){
    switch (character){
      case 0: return 12;
      case 1: return 4;
      case 2: return 14;
      case 3: return 12;
      case 4: return 2;
      case 5: return 12;
      case 6: return 14;
      case 7: return 8;
      case 8: return 14;
      case 9: return 4;
      case 10: return 14;
      case 11: return 14;
      case 12: return 6;
      case 13: return 6;
      case 14: return 6;
      case 15: return 4;
      case 16: return 4;
      case 17: return 10;
      case 18: return 4;
      case 19: return 4;
      case 20: return 10;
      case 21: return 14;
      case 22: return 10;
      case 23: return 10;
      case 24: return 4;
      case 25: return 8;
      case 26: return 2;
      case 27: return 8;
      case 28: return 12;
      case 29: return 6;
      case 30: return 6;
      case 31: return 4;
      case 32: return 14;
      case 33: return 10;
      case 34: return 4;
      case 35: return 14;
      case 36: return 10;
      case 37: return 12;
      case 38: return 6;
      case 39: return 12;
      case 40: return 14;
      case 41: return 8;
      case 42: return 6;
      case 43: return 10;
      case 44: return 14;
      case 45: return 4;
      case 46: return 10;
      case 47: return 14;
      case 48: return 10;
      case 49: return 10;
      case 50: return 4;
      case 51: return 8;
      case 52: return 6;
      case 53: return 10;
      case 54: return 12;
      case 55: return 8;
      case 56: return 6;
      case 57: return 4;
      case 58: return 10;
      case 59: return 10;
      case 60: return 4;
      case 61: return 14;
    }
  }
}