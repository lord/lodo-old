#include <SPI.h>
#include <TCL.h>
#include <math.h>

const boolean debug = 0;
const boolean outputSensors = 0;
const boolean _functionDebug = 0;
const boolean _stateMDebug = 0;
const boolean _checkBoard = 0;

// width of the whole board in pixels, minus one since it's the outer bound
const int _boardWidth = 19; 
const int squares = 16;

const int _sensorThreshold = 800;

const unsigned long _lodo_updatePoll = 33;
const unsigned long _lodo_drawPoll = 10;

const byte _up = 0;
const byte _down = 1;
const byte _pressed = 2;
const byte _released = 3;

unsigned long displayTime = 0;
unsigned long currentTime = 0;
unsigned long lodo_updateTime = 0;
unsigned long lodo_lastPressureTime = 0; // the last time someone stepped on the board.
const unsigned long _lodo_lastPressureTimeout = 10000;  // how soon to start the screen saver

byte state[4][4];
byte stateLast[4][4];

int sensors[2][16];
byte pallette[20][20][3];

const byte _gameSelector = 0;
const byte _simonGame = 1;
const byte _pongGame = 2;
const byte _dance = 3;
byte currentGame = _gameSelector;

// 
// updates the board
//
void updateBoard(){
  for (int i=0; i<4; i++){
    for (int j=0; j<4; j++){
      stateLast[i][j]=state[i][j];
    }
  }
  updateSensors();
  if (sensors[0][14] > _sensorThreshold || sensors[0][15] > _sensorThreshold) { state[0][0]=_down; } else { state[0][0] = _up; }
  if (sensors[0][10] > _sensorThreshold || sensors[0][11] > _sensorThreshold ) { state[0][1]=_down; } else { state[0][1] = _up; }
  if (sensors[0][6] > _sensorThreshold || sensors[0][7] > _sensorThreshold )  { state[0][2]=_down; } else { state[0][2] = _up; }
  if (sensors[0][2] > _sensorThreshold || sensors[0][3] > _sensorThreshold )  { state[0][3]=_down; } else { state[0][3] = _up; }

  if (sensors[0][0] > _sensorThreshold || sensors[0][1] > _sensorThreshold ) { state[1][0]=_down; } else { state[1][0] = _up; }
  if (sensors[0][4] > _sensorThreshold || sensors[0][5] > _sensorThreshold ) { state[1][1]=_down; } else { state[1][1] = _up; }
  if (sensors[0][8] > _sensorThreshold || sensors[0][9] > _sensorThreshold ) { state[1][2]=_down; } else { state[1][2] = _up; }
  if (sensors[0][12] > _sensorThreshold || sensors[0][13] > _sensorThreshold ) { state[1][3]=_down; } else { state[1][3] = _up; }

  if (sensors[1][14] > _sensorThreshold || sensors[1][15] > _sensorThreshold ) { state[2][0]=_down; } else { state[2][0] = _up; } 
  if (sensors[1][10] > _sensorThreshold || sensors[1][11] > _sensorThreshold ) { state[2][1]=_down; } else { state[2][1] = _up; }
  if (sensors[1][6] > _sensorThreshold || sensors[1][7] > _sensorThreshold ) { state[2][2]=_down; } else { state[2][2] = _up; }
  if (sensors[1][2] > _sensorThreshold || sensors[1][3] > _sensorThreshold ) { state[2][3]=_down; } else { state[2][3] = _up; }

  if (sensors[1][0] > _sensorThreshold || sensors[1][1] > _sensorThreshold ) { state[3][0]=_down; } else { state[3][0] = _up; }
  if (sensors[1][4] > _sensorThreshold || sensors[1][5] > _sensorThreshold ) { state[3][1]=_down; } else { state[3][1] = _up; }
  if (sensors[1][8] > _sensorThreshold || sensors[1][9] > _sensorThreshold ) { state[3][2]=_down; } else { state[3][2] = _up; }
  if (sensors[1][12] > _sensorThreshold || sensors[1][13] > _sensorThreshold ) { state[3][3]=_down; } else { state[3][3] = _up; }   
  for (int i=0; i<4; i++){
    for (int j=0; j<4; j++){
      if (state[i][j] == _down && (stateLast[i][j] == _up || stateLast[i][j]==_released)) { state[i][j]=_pressed; }
      if (state[i][j] == _up && (stateLast[i][j] == _down || stateLast[i][j]==_pressed)) { state[i][j]=_released; }
    }
  }
  if (numberSquaresDownOrPressed()>0){
    lodo_lastPressureTime = currentTime;
  }  
}

void updateSensors(){
//  if (debug) { Serial.println("Entering updateSensors"); }
  sensors[0][0]=readSensorA(LOW , LOW , LOW , LOW ); sensors[1][0]=readSensorB(LOW , LOW , LOW , LOW );
  sensors[0][1]=readSensorA(LOW , LOW , LOW , HIGH); sensors[1][1]=readSensorB(LOW , LOW , LOW , HIGH);
  sensors[0][2]=readSensorA(LOW , LOW , HIGH, LOW ); sensors[1][2]=readSensorB(LOW , LOW , HIGH, LOW );
  sensors[0][3]=readSensorA(LOW , LOW , HIGH, HIGH); sensors[1][3]=readSensorB(LOW , LOW , HIGH, HIGH);

  sensors[0][4]=readSensorA(LOW , HIGH, LOW , LOW ); sensors[1][4]=readSensorB(LOW , HIGH, LOW , LOW );
  sensors[0][5]=readSensorA(LOW , HIGH, LOW , HIGH); sensors[1][5]=readSensorB(LOW , HIGH, LOW , HIGH);
  sensors[0][6]=readSensorA(LOW , HIGH, HIGH, LOW ); sensors[1][6]=readSensorB(LOW , HIGH, HIGH, LOW );
  sensors[0][7]=readSensorA(LOW , HIGH, HIGH, HIGH); sensors[1][7]=readSensorB(LOW , HIGH, HIGH, HIGH);

  sensors[0][8]=readSensorA(HIGH, LOW , LOW , LOW ); sensors[1][8]=readSensorB(HIGH, LOW , LOW , LOW );
  sensors[0][9]=readSensorA(HIGH, LOW , LOW , HIGH); sensors[1][9]=readSensorB(HIGH, LOW , LOW , HIGH);
  sensors[0][10]=readSensorA(HIGH, LOW , HIGH, LOW ); sensors[1][10]=readSensorB(HIGH, LOW , HIGH, LOW );
  sensors[0][11]=readSensorA(HIGH, LOW , HIGH, HIGH); sensors[1][11]=readSensorB(HIGH, LOW , HIGH, HIGH);

  sensors[0][12]=readSensorA(HIGH, HIGH, LOW , LOW ); sensors[1][12]=readSensorB(HIGH, HIGH, LOW , LOW );
  sensors[0][13]=readSensorA(HIGH, HIGH, LOW , HIGH); sensors[1][13]=readSensorB(HIGH, HIGH, LOW , HIGH);
  sensors[0][14]=readSensorA(HIGH, HIGH, HIGH, LOW ); sensors[1][14]=readSensorB(HIGH, HIGH, HIGH, LOW );
  sensors[0][15]=readSensorA(HIGH, HIGH, HIGH, HIGH); sensors[1][15]=readSensorB(HIGH, HIGH, HIGH, HIGH);
  if (outputSensors) { printSensors(); }
}  

void printSensors(){
  for (int i=0; i<16; i++){
    Serial.print(i);
    Serial.print('\t');
  }
  Serial.println();
  for (int i=0; i<16; i++){
    Serial.print(sensors[0][i]);
    Serial.print('\t');
  }
  Serial.println();
  for (int i=0; i<16; i++){
    Serial.print(sensors[1][i]);
    Serial.print('\t');
  }
  Serial.println();
  Serial.println();
}


int readSensorA(byte p3, byte p2, byte p1, byte p0){
    digitalWrite(2,p0);digitalWrite(3,p1);digitalWrite(4,p2);digitalWrite(5,p3); 
    analogRead(A0); 
    analogRead(A0); 
    analogRead(A0); 
    analogRead(A0); 
    return analogRead(A0); 
}

int readSensorB(byte p3, byte p2, byte p1, byte p0){
    digitalWrite(2,p0);digitalWrite(3,p1);digitalWrite(4,p2);digitalWrite(5,p3); 
    analogRead(A1); 
    analogRead(A1); 
    analogRead(A1); 
    analogRead(A1); 
    return analogRead(A1); 
}

void printLights(){
//  if (debug) { Serial.println("Entering printLights"); }
  TCL.sendEmptyFrame();
  int row = 0; int col=0;
  for (int square = 0; square<16; square++){
    row = square/4;
    col = square % 4;
    if (row == 1 or row==3){ // rows 1 & 3 go backwards
      col = 3 - col;
    }
    printSquare(row, col);
  }
  TCL.sendEmptyFrame();
}

void printSquare(int row, int col){
  if (row==2 and col==2) { // accommodate bad wiring on 2,2
    for (int l=4;l>=0;l--) {printPixel(row*5+l,col*5+0);}
    for (int l=0;l<5;l++)  {printPixel(row*5+l,col*5+1);}
    for (int l=4;l>=0;l--) {printPixel(row*5+l,col*5+2);}
    for (int l=0;l<5;l++)  {printPixel(row*5+l,col*5+3);}
    for (int l=4;l>=0;l--) {printPixel(row*5+l,col*5+4);}
  } else {
    for (int l=0;l<5;l++) {printPixel(row*5+0,col*5+l);}
    for (int l=4;l>=0;l--){printPixel(row*5+1,col*5+l);}
    for (int l=0;l<5;l++) {printPixel(row*5+2,col*5+l);}
    for (int l=4;l>=0;l--){printPixel(row*5+3,col*5+l);}
    for (int l=0;l<5;l++) {printPixel(row*5+4,col*5+l);}
  }
}

void printPixel(int pRow, int pCol){
  TCL.sendColor(pallette[pRow][pCol][0],
                pallette[pRow][pCol][1],
                pallette[pRow][pCol][2]);
}


