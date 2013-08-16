#include <SPI.h>
#include <TCL.h>
#include <math.h>

const boolean debug = 0;
const boolean outputSensors = 0;
const boolean _functionDebug = 0;
const boolean _stepDebug = 0;
const boolean _sequenceDebug = 0;
const boolean _arrowDebug = 0;
const boolean _stateMDebug = 0;
const boolean _checkBoard = 0;

const int squares = 16;

// width of the whole board in pixels, minus one since it's the outer bound
const int _boardWidth = 19; 

const int sensorThreshold = 800;

unsigned long displayTime = 0;
unsigned long currentTime = 0;
const unsigned long _sim_updatePoll = 33;
const unsigned long _sim_drawPoll = 10;
unsigned long sim_updateTime = 0;

int state[4][4];
int stateLast[4][4];
const int _up = 0;
const int _down = 1;
const int _pressed = 2;
const int _released = 3;

int sensors[2][16];

byte pallette[20][20][3];

int bConfig[16][3]={
  {0,0,0},
  {0,1,0},
  {0,2,0},
  {0,3,0},
  {1,3,0},
  {1,2,0},
  {1,1,0},
  {1,0,0},
  {2,0,0},
  {2,1,0},
  {2,2,1},
  {2,3,0},
  {3,3,0},
  {3,2,0},
  {3,1,0},
  {3,0,0}
};

unsigned long simTime_updatePoll = 0;

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
  if (sensors[0][14] > sensorThreshold || sensors[0][15] > sensorThreshold) { state[0][0]=_down; } else { state[0][0] = _up; }
  if (sensors[0][10] > sensorThreshold || sensors[0][11] > sensorThreshold ) { state[0][1]=_down; } else { state[0][1] = _up; }
  if (sensors[0][6] > sensorThreshold || sensors[0][7] > sensorThreshold ) { state[0][2]=_down; } else { state[0][2] = _up; }
  if (sensors[0][2] > sensorThreshold || sensors[0][3] > sensorThreshold ) { state[0][3]=_down; } else { state[0][3] = _up; }

  if (sensors[0][0] > sensorThreshold || sensors[0][1] > sensorThreshold ) { state[1][0]=_down; } else { state[1][0] = _up; }
  if (sensors[0][4] > sensorThreshold || sensors[0][5] > sensorThreshold ) { state[1][1]=_down; } else { state[1][1] = _up; }
  if (sensors[0][8] > sensorThreshold || sensors[0][9] > sensorThreshold ) { state[1][2]=_down; } else { state[1][2] = _up; }
  if (sensors[0][12] > sensorThreshold || sensors[0][13] > sensorThreshold ) { state[1][3]=_down; } else { state[1][3] = _up; }

  if (sensors[1][14] > sensorThreshold || sensors[1][15] > sensorThreshold ) { state[2][0]=_down; } else { state[2][0] = _up; } 
  if (sensors[1][10] > sensorThreshold || sensors[1][11] > sensorThreshold ) { state[2][1]=_down; } else { state[2][1] = _up; }
  if (sensors[1][6] > sensorThreshold || sensors[1][7] > sensorThreshold ) { state[2][2]=_down; } else { state[2][2] = _up; }
  if (sensors[1][2] > sensorThreshold || sensors[1][3] > sensorThreshold ) { state[2][3]=_down; } else { state[2][3] = _up; }

  if (sensors[1][0] > sensorThreshold || sensors[1][1] > sensorThreshold ) { state[3][0]=_down; } else { state[3][0] = _up; }
  if (sensors[1][4] > sensorThreshold || sensors[1][5] > sensorThreshold ) { state[3][1]=_down; } else { state[3][1] = _up; }
  if (sensors[1][8] > sensorThreshold || sensors[1][9] > sensorThreshold ) { state[3][2]=_down; } else { state[3][2] = _up; }
  if (sensors[1][12] > sensorThreshold || sensors[1][13] > sensorThreshold ) { state[3][3]=_down; } else { state[3][3] = _up; }   
  for (int i=0; i<4; i++){
    for (int j=0; j<4; j++){
      if (state[i][j] == _down && (stateLast[i][j] == _up || stateLast[i][j]==_released)) { state[i][j]=_pressed; }
      if (state[i][j] == _up && (stateLast[i][j] == _down || stateLast[i][j]==_pressed)) { state[i][j]=_released; }
    }
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
  for (int square = 0; square<16; square++){
    int row = bConfig[square][0];
    int col = bConfig[square][1];
    int type = bConfig[square][2];
    if (type == 0) {
      printSquare0(row, col);
    } else {
      printSquare1(row, col);
    }
  }
  TCL.sendEmptyFrame();
}

void printSquare0(int row, int col){
  for (int l=0;l<5;l++) {printPixel(row*5+0,col*5+l);}
  for (int l=4;l>=0;l--){printPixel(row*5+1,col*5+l);}
  for (int l=0;l<5;l++) {printPixel(row*5+2,col*5+l);}
  for (int l=4;l>=0;l--){printPixel(row*5+3,col*5+l);}
  for (int l=0;l<5;l++) {printPixel(row*5+4,col*5+l);}
}
  
void printSquare1(int row, int col){
  for (int l=4;l>=0;l--) {printPixel(row*5+l,col*5+0);}
  for (int l=0;l<5;l++)  {printPixel(row*5+l,col*5+1);}
  for (int l=4;l>=0;l--) {printPixel(row*5+l,col*5+2);}
  for (int l=0;l<5;l++)  {printPixel(row*5+l,col*5+3);}
  for (int l=4;l>=0;l--) {printPixel(row*5+l,col*5+4);}
}

void printPixel(int pRow, int pCol){
//  if (debug) { Serial.println("Entering printPixel"); }

  int r = pallette[pRow][pCol][0];
  int g = pallette[pRow][pCol][1];
  int b = pallette[pRow][pCol][2];
//  if (debug) {     Serial.print(r); Serial.print('\t'); Serial.print(g); Serial.print('\t'); Serial.println(b);  }

  TCL.sendColor(r,g,b);
}


