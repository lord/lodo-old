#include "lodo.h"
#include <SPI.h>
#include <TCL.h>
 
const boolean debug = 0;
const boolean outputSensors = 0;
const boolean _printState = 0;
const boolean _functionDebug = 0;
const boolean _stepDebug = 0;
const boolean _sequenceDebug = 0;
const boolean _arrowDebug = 0;
const boolean _stateMDebug = 1;
 
const int displayWidth = 15;
const int displayWidth1 = 15;
const int squares = 16;
const int sensorThreshold = 800;
 
const long pressurePoll = 10;
 
unsigned long displayTime = 0;
unsigned long currentTime = 0;
 
int board[4][4];
int arrow[4][4];
const int _arrow_none      = 0;
const int _arrow_right     = 1;
const int _arrow_up        = 2;
const int _arrow_left      = 3;
const int _arrow_down      = 4;
const int _arrow_hLine     = 5;
const int _arrow_vLine     = 6;
const int _arrow_square    = 7;
 
int state[4][4];
int stateLast[4][4];
const int _up = 0;
const int _down = 1;
const int _pressed = 2;
const int _released = 3;
 
int sensors[2][16];
 
byte pallette[20][20];
byte ePallette[20][20];
const int _drawBoard = 0;
const int _drawPallette = 1;
const int _drawArrow = 2;
int drawMode = _drawBoard;
 
void setup() {
  TCL.begin();
  for (int i=0; i<4; i++){
    for (int j=0; j<4; j++){
      board[i][j] = _black;
      state[i][j] = _up;
    }
  }
  pinMode(A0, INPUT);
  pinMode(A1, INPUT);
  pinMode(2, OUTPUT);
  pinMode(3, OUTPUT);
  pinMode(4, OUTPUT);
  digitalWrite(4,LOW);
  pinMode(5, OUTPUT);
  pinMode(6, OUTPUT);
  Serial.begin(9600);
randomSeed(analogRead(4)); // setup for a different stating point for the random number
 init_intro();
}
 
void loop() {
  currentTime = millis();
  if (currentTime >= displayTime) {
    draw();
    displayTime = currentTime + 10;
  }
  if (currentTime >= sim_updateTime) {
    update();
    sim_updateTime = currentTime + _sim_updatePoll;
  }
}
 
void update(){
  updateBoard();
  switch (sim_state) {
    case _simState_intro: // Play Introduction
      if (_stateMDebug){ Serial.println("Intro"); }
      process_intro();
       break;
    case _simState_seq: // Play Sequence
      if (_stateMDebug){ Serial.println("Intro"); }
      process_seq();
      break;
    case _simState_wait: // Wait for first step
      if (_stateMDebug){ Serial.println("Wait"); }
      process_wait();
      break;
    case _simState_uGood: // Assume good step & validate & move forward in game
      if (_stateMDebug){ Serial.println("U Good"); }
      process_uGood();
      break;
    case _simState_uBad: // User makes a bad step
      if (_stateMDebug){ Serial.println("U Bad"); }
      process_uBad();
      break;
    case _simState_wSeq: // Play the winning sequence
      if (_stateMDebug){ Serial.println("Win Seq"); }
      process_wSeq();
      break;
    case _simState_wGame: // Play the winning game sequence
      if (_stateMDebug){ Serial.println("Win Game"); }
      process_wGame();
      break;
    case _simState_lGame: // Play the losing game sequence
      if (_stateMDebug){ Serial.println("Lose Game"); }
      process_lGame();
      break;
  }
}
 
void init_intro(){
  if (_functionDebug) { Serial.println("Enter Init_intro"); }
  sim_state=_simState_intro;
  simTime_intro = currentTime + _simTimeout_intro;
  sim_currentUserStep = 0;
  sim_roundStep = 0;
  sim_misses = 0;
  generate_sequence();
  drawMode = _drawPallette; // draw from the pallette, not from the board
}
 
void process_intro(){
  int progress = int(currentTime - (simTime_intro - _simTimeout_intro)); // currenttime - start of state
  draw_intro(progress);
  if (currentTime >= simTime_intro && numberSquaresPressed()>0){ // wait until someone touches it
    drawMode = _drawBoard; // reset to draw the board
    init_wait();
  }
}
 
void draw_intro(int raw_progress){
  raw_progress = raw_progress/10;  // 1 light every 10 ms
  int progress = raw_progress % 400; // 400 lights
  int mround = raw_progress / 400; // change color each time
  int color = _red0;
  int pastColor = _black;
 
  mround = mround % 5;
  switch (mround) {
    case 0: color=_red0;     pastColor=_black; break;
    case 1: color=_green0;   pastColor=_red0; break;
    case 2: color=_pink0;  pastColor=_green0; break;
    case 3: color=_turq0;    pastColor=_pink0; break;
    case 4: color=_blue0;   pastColor=_turq0; break;
  }
 
  for (int i=0; i<20; i++){
    for (int j=0; j<20; j++){
      pallette[i][j] = pastColor;
    }
  }
//  Serial.println();
//  Serial.print("Progress = ");
//  Serial.println(progress);
  int dir = 2;  // 1 left; 2 up; 3 right; 4 down
  int row = -1; int col = 0;
  int layer = 0; // layer pixel to the center
  for (int p=0; p<=progress; p++){ 
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
    pallette[row][col] = color;
//    Serial.print(row); Serial.print(" "); Serial.println(col);
 
  }
}
 
void generate_sequence(){
  randomSeed(long(currentTime));
  int row = int(mrandom(0,3));
  int col = int(mrandom(0,3));
  sim_seq[0][0] = row; sim_seq[0][1] = col;
  for (int i=1; i<16; i++){
    if (row <= 0) {
      row += int(mrandom(0,1));
    } else if (row == 3) {
      row += int(mrandom(-1,0));
    } else {
      row += int(mrandom(-1,1));
    }
    if (col <=0) {
      col += int(mrandom(0,1));
    } else if (col >= 3) {
      col += int(mrandom(-1,0));
    } else {
      col += int(mrandom(-1,1));
    }
    sim_seq[i][0] = row; sim_seq[i][1] = col;
  }
}
 
int mrandom(int low, int high){
  int num = random(-10,10);
  while (num>high || num <low){ num = random(-10,10); }
  return num;
}
   
void init_seq(){
  if (_functionDebug) { Serial.println("Enter init_seq"); }
  drawMode = _drawBoard;
  sim_state=_simState_seq;
  simTime_seq = currentTime + _simTimeout_seq;
  sim_displayStep = 0;
}
 
void process_seq(){
  setBoardToColor(_darkblue);
  setSequence();
  if (currentTime >= simTime_seq){
    simTime_seq = currentTime + _simTimeout_seq;
    if (sim_displayStep++ >= sim_roundStep){
      init_wait();
    }
  }
}
 
void setSequence(){
  int i = sim_displayStep;
  int colorIndex = 0;
  while (i>=1 && (sim_seq[i][0] == sim_seq[i-1][0]) && (sim_seq[i][1] == sim_seq[i-1][1])) {
    i--;
    colorIndex++;
  }
  int row = sim_seq[sim_displayStep][0];
  int col = sim_seq[sim_displayStep][1];
  board[row][col] = seq_color[colorIndex];
}
 
// Wait starts with a clear board (noone on it) and waits for the first step.
// It will timeout, but not implemented yet.
void init_wait(){
  if (_functionDebug) {  Serial.println("Enter init_wait"); }
  sim_state=_simState_wait;
  simTime_wait = currentTime + _simTimeout_wait;
  drawMode = _drawArrow;
}
 
void process_wait(){
  if (currentTime > simTime_wait){
    badCol=sim_seq[0][0]; badRow=sim_seq[0][1]; // set the red to the first square
    init_uBad();
    return;
  }
  if ((numberSquaresDown()==1) && (state[sim_seq[0][0]][sim_seq[0][1]] == _down)){
    drawMode = _drawBoard;
    init_uGood();
    return;
  }
  for (int i=0; i<4; i++){
    for (int j=0; j<4; j++){
      arrow[i][j]=_arrow_none;
    }
  }   
  int sqr_row = sim_seq[0][0];
  int sqr_col = sim_seq[0][1];
  switch (sqr_col) {
    case 0:
      arrow[sqr_row][0]=_arrow_square;
      arrow[sqr_row][1]=_arrow_left;
      arrow[sqr_row][2]=_arrow_hLine;
      arrow[sqr_row][3]=_arrow_hLine;
      break;
    case 1:
      arrow[sqr_row][0]=_arrow_right;
      arrow[sqr_row][1]=_arrow_square;
      arrow[sqr_row][2]=_arrow_left;
      arrow[sqr_row][3]=_arrow_hLine;
      break;
    case 2:
      arrow[sqr_row][0]=_arrow_hLine;
      arrow[sqr_row][1]=_arrow_right;
      arrow[sqr_row][2]=_arrow_square;
      arrow[sqr_row][3]=_arrow_left;
      break;
    case 3:
      arrow[sqr_row][0]=_arrow_hLine;
      arrow[sqr_row][1]=_arrow_hLine;
      arrow[sqr_row][2]=_arrow_right;
      arrow[sqr_row][3]=_arrow_square;
      break;
  }
  switch (sqr_row) {
    case 0:
      arrow[0][sqr_col]=_arrow_square;
      arrow[1][sqr_col]=_arrow_up;
      arrow[2][sqr_col]=_arrow_vLine;
      arrow[3][sqr_col]=_arrow_vLine;
      break;
    case 1:
      arrow[0][sqr_col]=_arrow_down;
      arrow[1][sqr_col]=_arrow_square;
      arrow[2][sqr_col]=_arrow_up;
      arrow[3][sqr_col]=_arrow_vLine;
      break;
    case 2:
      arrow[0][sqr_col]=_arrow_vLine;
      arrow[1][sqr_col]=_arrow_down;
      arrow[2][sqr_col]=_arrow_square;
      arrow[3][sqr_col]=_arrow_up;
      break;
    case 3:
      arrow[0][sqr_col]=_arrow_vLine;
      arrow[1][sqr_col]=_arrow_vLine;
      arrow[2][sqr_col]=_arrow_down;
      arrow[3][sqr_col]=_arrow_square;
      break;
  }
  if (_arrowDebug) { printArrow(); }
  return;
}
 
 
void printArrow(){
  const char rs[] = {'.','>','^','<','_','-','|','X'};
  Serial.println("");
  Serial.print("Arrow"); Serial.println();
  Serial.print(rs[arrow[0][0]]);
  Serial.print(rs[arrow[0][1]]);
  Serial.print(rs[arrow[0][2]]);
  Serial.print(rs[arrow[0][3]]);Serial.println();
 
  Serial.print(rs[arrow[1][0]]);
  Serial.print(rs[arrow[1][1]]);
  Serial.print(rs[arrow[1][2]]);
  Serial.print(rs[arrow[1][3]]);Serial.println();
 
  Serial.print(rs[arrow[2][0]]);
  Serial.print(rs[arrow[2][1]]);
  Serial.print(rs[arrow[2][2]]);
  Serial.print(rs[arrow[2][3]]);Serial.println();
 
  Serial.print(rs[arrow[3][0]]);
  Serial.print(rs[arrow[3][1]]);
  Serial.print(rs[arrow[3][2]]);
  Serial.print(rs[arrow[3][3]]);Serial.println();
}
 
void init_uGood(){
  if (_functionDebug) { Serial.println("Enter init_uGood"); }
  sim_state=_simState_uGood;
  simTime_uGood = currentTime + _simTimeout_uGood;
  sim_currentUserStep = -1;
  process_uGood();  // needed to keep from losing the first press
 drawMode = _drawBoard;
}
 
// Check if the ones pressed are good
void process_uGood(){
  if (_functionDebug) { Serial.println("Enter uGood");}
  if (_stepDebug) { Serial.print("CUS: "); Serial.println(sim_currentUserStep); } 
  if (currentTime > simTime_uGood) {
    badRow=sim_seq[0][0]; badCol=sim_seq[0][1]; // set the red to the first square
    init_uBad();
    return;
  }
  if (sim_currentUserStep == -1) { // convert the _down to a _press for the first step as they are on the right square
    state[sim_seq[0][0]][sim_seq[0][1]] = _pressed;
  }
  setBoardToColor(_darkblue);
 
  if (numberSquaresPressed()>1){
    setBadSquare();
    init_uBad();
    return;
  }
  // check to see if pressed advances pointer
  if (numberSquaresPressed()==1) {
    if (_stepDebug){ Serial.print("pressed "); }
    sim_currentUserStep++;
    int row0 = sim_seq[sim_currentUserStep][0];
    int col0 = sim_seq[sim_currentUserStep][1];
    if (state[row0][col0] == _pressed){
      if (_stepDebug) { Serial.println("Pressed Correct"); }
      if (sim_currentUserStep >= sim_roundStep) {
        init_wSeq();
        return;
      } 
    } else {
      if (_stepDebug){ Serial.println("Pressed Wrong"); }
      setBadSquare();
      init_uBad();
      return;
    }
  }
 
  int state0 = state[sim_seq[max(0, sim_currentUserStep - 0)][0]][sim_seq[max(0, sim_currentUserStep - 0)][1]];
  int state1 = state[sim_seq[max(0, sim_currentUserStep - 1)][0]][sim_seq[max(0, sim_currentUserStep - 1)][1]];
//  Serial.print(state0);  Serial.print(" ");
//  Serial.print(state1);Serial.print("\n");
 
  int squares = numberSquaresDownOrPressed();
  if (squares==0) {
    if (_stepDebug){ Serial.println("Inside 0 sq"); }
    return;
  } else if (squares==1) {
    if (_stepDebug) { Serial.println("Inside 1 sq"); }
    if (state0 == _pressed || state0 == _down) {
      if (_stepDebug) { Serial.println("1 Down: Good"); }
    } else {
      if (_stepDebug) { Serial.println("1 Down: Bad"); }
      setBadSquare();
      init_uBad();
      return;
    }
  } else if (squares==2) {
    if (_stepDebug) { Serial.println("Inside 2 sq"); }
    if ((state0 == _pressed || state0 == _down) && (state1 == _down)){
      if (_stepDebug) { Serial.println("2 Down: Good"); }
    } else {
      if (_stepDebug) { Serial.println("2 Down: Bad"); }
      setBadSquare();
      init_uBad();
      return;
    }
  } else {
    if (_stepDebug) { Serial.println("Default clause - >2 squares"); }
    setBadSquare();
    init_uBad();
    return;
  }
   
  for (int i=0; i<4; i++){
    for (int j=0; j<4; j++){
      if (state[i][j] == _pressed || state[i][j] == _down){
        board[i][j] = _green0;
      }
    }
  }
  return;
}
 
 
// Sets the first found pressed square to badrow/badcol
void setBadSquare(){
  for (int i=0; i<4; i++){
    for (int j=0; j<4; j++){
      if (state[i][j] == _pressed){
        badRow = i;
        badCol = j;
        return;
      }
    }
  }
}
 
void init_uBad(){
  if (_functionDebug) { Serial.println("Enter init_uBad"); }
  sim_state=_simState_uBad;
  simTime_uBad = currentTime + _simTimeout_uBad;
  if (sim_misses >= _sim_maxMisses){
    // you lose!!
    init_lGame();
  } else {
    sim_misses++;
  }
  drawMode = _drawBoard;
}
 
void process_uBad(){
  setBoardToColor(_grey);
  board[badRow][badCol] = _red1;
  if (currentTime >= simTime_uBad){
    init_seq();
  }
}
 
void init_wSeq(){
  sim_state=_simState_wSeq;
  simTime_wSeq = currentTime + _simTimeout_wSeq;
 
  if (sim_roundStep >= sim_maxStep){
    init_wGame();
  } else {
    sim_roundStep++;
  }
  drawMode = _drawBoard;
}
 
void process_wSeq(){
    drawWinSeq();
    if (currentTime >= simTime_wSeq){
      init_seq();
    }
}
 
void init_wGame(){
  sim_state=_simState_wGame;
  simTime_wGame = currentTime + _simTimeout_wGame;
  drawMode = _drawBoard;
}
 
void process_wGame(){
  setBoardToChecker(_red0, _blue0);
  if (currentTime >= simTime_wGame){
    init_intro();
  }
}
 
void init_lGame(){
  sim_state=_simState_lGame;
  simTime_lGame = currentTime + _simTimeout_lGame;
}
 
void process_lGame(){
  setBoardToColor(_black);
  if (currentTime >= simTime_lGame){
    init_intro();
  }
}
 
//
// returns the number of squares that are pressed or down.
//
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
 
//
// Assign the board random colors
//
void step(){
  if (_functionDebug) { Serial.println("Entering Step"); }
  for (int row=0; row<4; row++){
    for (int col=0; col<4; col++){
      int newColor = random(300);
      if (newColor>0 && newColor <10){
     board[row][col]= newColor;
      }
    }
  }
}
 
void setBoardToColor(int color){
  for (int i=0; i<4; i++){
    for (int j=0; j<4; j++){
      board[i][j]=color;
    }
  }
}
 
void setBoardToChecker(int color1, int color2){
  for (int i=0; i<4; i++){
    for (int j=0; j<4; j++){
      if ((i+j)%2 == 0) {
         board[i][j]=color1;
      } else {
         board[i][j]=color2;
      }
    }
  }
}
 
void setBoardToSimonSeq(int displayStep){
  setBoardToColor(_darkblue);
  int row = sim_seq[displayStep][0];
  int col = sim_seq[displayStep][1];
  board[row][col] = _white;
}
 
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
  if (sensors[0][10] > sensorThreshold || sensors[0][10] > sensorThreshold) { state[0][0]=_down; } else { state[0][0] = _up; }
  if (sensors[0][1] > sensorThreshold || sensors[0][5] > sensorThreshold ) { state[0][1]=_down; } else { state[0][1] = _up; }
  if (sensors[1][6] > sensorThreshold || sensors[1][14] > sensorThreshold ) { state[0][2]=_down; } else { state[0][2] = _up; }
  if (sensors[1][1] > sensorThreshold || sensors[1][9] > sensorThreshold ) { state[0][3]=_down; } else { state[0][3] = _up; }
 
  if (sensors[0][2] > sensorThreshold || sensors[0][6] > sensorThreshold ) { state[1][0]=_down; } else { state[1][0] = _up; }
  if (sensors[0][9] > sensorThreshold || sensors[0][13] > sensorThreshold ) { state[1][1]=_down; } else { state[1][1] = _up; }
  if (sensors[1][2] > sensorThreshold || sensors[1][10] > sensorThreshold ) { state[1][2]=_down; } else { state[1][2] = _up; }
  if (sensors[1][5] > sensorThreshold || sensors[1][13] > sensorThreshold ) { state[1][3]=_down; } else { state[1][3] = _up; }
 
  if (sensors[0][8] > sensorThreshold || sensors[0][12] > sensorThreshold ) { state[2][0]=_down; } else { state[2][0] = _up; }
  if (sensors[0][3] > sensorThreshold || sensors[0][7] > sensorThreshold ) { state[2][1]=_down; } else { state[2][1] = _up; }
  if (sensors[1][4] > sensorThreshold || sensors[1][12] > sensorThreshold ) { state[2][2]=_down; } else { state[2][2] = _up; }
  if (sensors[1][3] > sensorThreshold || sensors[1][11] > sensorThreshold ) { state[2][3]=_down; } else { state[2][3] = _up; }
 
  if (sensors[0][0] > sensorThreshold || sensors[0][0] > sensorThreshold ) { state[3][0]=_down; } else { state[3][0] = _up; }
  if (sensors[0][11] > sensorThreshold || sensors[0][15] > sensorThreshold ) { state[3][1]=_down; } else { state[3][1] = _up; }
  if (sensors[1][0] > sensorThreshold || sensors[1][8] > sensorThreshold ) { state[3][2]=_down; } else { state[3][2] = _up; }
  if (sensors[1][15] > sensorThreshold || sensors[1][15] > sensorThreshold ) { state[3][3]=_down; } else { state[3][3] = _up; }  
  for (int i=0; i<4; i++){
    for (int j=0; j<4; j++){
      if (state[i][j] == _down && (stateLast[i][j] == _up || stateLast[i][j]==_released)) { state[i][j]=_pressed; }
      if (state[i][j] == _up && (stateLast[i][j] == _down || stateLast[i][j]==_pressed)) { state[i][j]=_released; }
    }
  } 
  if (_printState){
    printState();
  }
}
 
void printState(){
  const char rs[4] = {'U', 'D', 'P', 'R'};
  Serial.println();
  Serial.print("States"); Serial.println(sim_state);
  Serial.print(rs[state[0][0]]);Serial.print(" ");
  Serial.print(rs[state[0][1]]);Serial.print(" ");
  Serial.print(rs[state[0][2]]);Serial.print(" ");
  Serial.print(rs[state[0][3]]);Serial.println();
 
  Serial.print(rs[state[1][0]]);Serial.print(" ");
  Serial.print(rs[state[1][1]]);Serial.print(" ");
  Serial.print(rs[state[1][2]]);Serial.print(" ");
  Serial.print(rs[state[1][3]]);Serial.println();
 
  Serial.print(rs[state[2][0]]);Serial.print(" ");
  Serial.print(rs[state[2][1]]);Serial.print(" ");
  Serial.print(rs[state[2][2]]);Serial.print(" ");
  Serial.print(rs[state[2][3]]);Serial.println();
 
  Serial.print(rs[state[3][0]]);Serial.print(" ");
  Serial.print(rs[state[3][1]]);Serial.print(" ");
 Serial.print(rs[state[3][2]]);Serial.print(" ");
  Serial.print(rs[state[3][3]]);Serial.println();
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
 
 
int readSensorA(byte p0, byte p1, byte p2, byte p3){
    digitalWrite(2,p0);digitalWrite(3,p1);digitalWrite(5,p2);digitalWrite(6,p3);
    analogRead(A0);
    analogRead(A0);
//    analogRead(A0);
//    analogRead(A0);
    return analogRead(A0);
}
 
int readSensorB(byte p0, byte p1, byte p2, byte p3){
    digitalWrite(2,p0);digitalWrite(3,p1);digitalWrite(5,p2);digitalWrite(6,p3);
    analogRead(A1);
    analogRead(A1);
//    analogRead(A1);
//    analogRead(A1);
    return analogRead(A1);
}
 
//
// Draws the pattern for win sequence
//
void drawWinSeq(){
  setBoardToColor(_yellow0); 
  for (int i=0; i<4; i++){ board[0][i]=_green0; board[i][0]=_green0; board[3][i]=_green0; board[i][3]=_green0; };
}
 
// ___________ draw
//
// outputs the board based upon the board color variable or pallette based on it
//
void draw(){
  if (_functionDebug) { Serial.print("Entering Draw\ndm = "); Serial.println(drawMode); }
  if (drawMode == _drawBoard) {
    for (int i=0;i<4;i++){
      for (int j=0;j<4;j++){
        setPalletteToColor(i,j,board[i][j]);
      }
    }
  } else if (drawMode == _drawArrow) {
    for (int i=0;i<4;i++){
      for (int j=0;j<4;j++){
        setPalletteToArrow(i,j,arrow[i][j]);
      }
    }
  }
  printLights();
}
 
// __________ setPalletteToColor
//
// for a given row/col will set the pallette grid to a single color
//
void setPalletteToColor(int row, int col, int color){
  for (int i=0; i<5; i++){
    for (int j=0; j<5; j++){
      pallette[row*5+i][col*5+j] = color;
    }
  }
}
 
void setPalletteToArrow(int row, int col, int arrowType){
  int fg = _green1;
  int p[5][5] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
  for (int i=0; i<5; i++){
    for (int j=0; j<5; j++){
      p[i][j] = _black;
    }
  }
  switch (arrowType){
    case _arrow_up:
      p[0][2]=fg;
      p[1][1]=fg;p[1][2]=fg;p[1][3]=fg;
      p[2][0]=fg;p[2][2]=fg;p[2][4]=fg;
      p[3][2]=fg;
      p[4][2]=fg;
      break;
    case _arrow_down:
      p[0][2]=fg;
      p[1][2]=fg;
      p[2][0]=fg;p[2][2]=fg;p[2][4]=fg;
      p[3][1]=fg;p[3][2]=fg;p[3][3]=fg;
      p[4][2]=fg;
      break;
    case _arrow_vLine:
      p[0][2]=fg;
      p[1][2]=fg;
      p[2][2]=fg;
      p[3][2]=fg;
      p[4][2]=fg;
      break;
    case _arrow_left:
      p[2][0]=fg;
      p[1][1]=fg;p[2][1]=fg;p[3][1]=fg;
      p[0][2]=fg;p[2][2]=fg;p[4][2]=fg;
      p[2][3]=fg;
      p[2][4]=fg;
      break;
    case _arrow_right:
      p[2][0]=fg;
      p[2][1]=fg;
      p[0][2]=fg;p[2][2]=fg;p[4][2]=fg;
      p[1][3]=fg;p[2][3]=fg;p[3][3]=fg;
      p[2][4]=fg;
      break;
    case _arrow_hLine:
      p[2][0]=fg;
      p[2][1]=fg;
      p[2][2]=fg;
      p[2][3]=fg;
      p[2][4]=fg;
      break;
    case _arrow_square:
      p[0][0]=fg;p[0][1]=fg;p[0][2]=fg;p[0][3]=fg;p[0][4]=fg;
      p[1][0]=fg;p[1][4]=fg;
      p[2][0]=fg;p[2][4]=fg;
      p[3][0]=fg;p[3][4]=fg;
      p[4][0]=fg;p[4][1]=fg;p[4][2]=fg;p[4][3]=fg;p[4][4]=fg;
      break;
  }
  for (int i=0; i<5; i++){
    for (int j=0; j<5; j++){
      pallette[row*5+i][col*5+j] = p[i][j];
    }
  } 
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
 
  int color = pallette[pRow][pCol];
  int impact = 0;
  int r = min(255,colorArray[color][0]+impact);
  int g = min(255,colorArray[color][1]+impact);
  int b = min(255,colorArray[color][2]+impact);
//  if (debug) {     Serial.print(r); Serial.print('\t'); Serial.print(g); Serial.print('\t'); Serial.println(b);  }
 
  TCL.sendColor(r,g,b);
}
