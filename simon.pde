/*****************************************************************************
 * lodo.ino
 *
 ****************************************************************************/
#include <SPI.h>
#include <TCL.h>
#include <math.h>

namespace simon {

  const int _simState_intro = 0;
  const int _simState_seq   = 1;
  const int _simState_clear = 2;
  const int _simState_cWait = 9;
  const int _simState_wait  = 3;
  const int _simState_uGood = 4;
  const int _simState_uBad  = 5;
  const int _simState_wSeq  = 6;
  const int _simState_wGame = 7;
  const int _simState_lGame = 8;

  //SIMON CONSTANTS 
  const unsigned long _simTimeout_intro = 1000;
  const unsigned long _simTimeout_seq  = 800;
  const unsigned long _simTimeout_wait  = 100000;
  const unsigned long _simTimeout_uGood = 50000;
  const unsigned long _simTimeout_uBad  = 5000;
  const unsigned long _simTimeout_uBad_step  = 2000;
  const unsigned long _simTimeout_wSeq  = 5000;
  const unsigned long _simTimeout_wSeq_step = 2000;
  const unsigned long _simTimeout_wGame = 15000;
  const unsigned long _simTimeout_lGame = 10000;
  const unsigned long _sim_updatePoll = 1000;
  
  //SIMON TIME VARIABLES
  unsigned long sim_startTime = 0;
  unsigned long sim_endTime = 0;
  const unsigned long _sim_seqStepDuration = 1000; // how long to display each sequare
  const unsigned long _sim_badSquareDuration = 3000; // how long to display a mistep
  const unsigned long _sim_winGameDuration = 15000;
  const unsigned long _sim_loseGameDuration = 6000;
  const unsigned long _sim_winSeqDuration = 1000;
  const unsigned long _sim_introDuration = 3000;

  //Simon Variables
  byte sim_seq[16][2]={{0,0},{0,1},{1,1},{2,1},{3,0},{3,1},{3,0},{2,1},{1,1},{1,2},{0,2},{1,2},{2,3},{3,3},{2,2},{1,1}};
  byte sim_roundStep = 0; // how many steps user has right for this round.

  byte sim_currentStep = 0;
  byte sim_maxStep = 8;
  byte sim_state = 0;
  byte sim_currentUserStep = 0;
  byte sim_misses = 0;
  const byte _sim_maxMisses = 3;
  byte badRow = 0;
  byte badCol = 0;


  void update();
  void generate_sequence();
  void init_intro();
  void process_intro();
  void setSequence();
  void init_seq();
  void process_seq();
  void init_wait();
  void process_wait();
  void printArrow();
  void init_uGood();
  void process_uGood();
  void process_uGood2();
  void drawBadSquare();
  void init_uBad();
  void process_uBad();
  void drawBadStep();
  void drawStrikes(byte strikeCount);
  void setCorners();
  void draw_X(int pRow, int pCol);
  void d_square(int x, int y, int side, int color);
  void d_rect(int x, int y, int dx, int dy, int color);
  void init_wSeq();
  void process_wSeq();
  void drawRightStep();
  void init_wGame();
  void process_wGame();
  void drawWin();
  void drawWinSeq();
  void init_lGame();
  void process_lGame();
  void drawLose();
  void draw();
  void setPalletteToArrow(int row, int col, int arrowType);
  void simon_reset();
  void step();

  const boolean _functionDebug = 0;
  const boolean _stateMDebug = 0;
  const boolean _stepDebug = 0;
  
  const byte _arrow_none      = 0;
  const byte _arrow_right     = 1;
  const byte _arrow_up        = 2;
  const byte _arrow_left      = 3;
  const byte _arrow_down      = 4;
  const byte _arrow_hLine     = 5;
  const byte _arrow_vLine     = 6;
  const byte _arrow_square    = 7;

  const byte _drawBoard = 0;
  const byte _drawPallette = 1;
  const byte _drawArrow = 2;

  void game_boot() {
    simon_reset();
  }

  void game_update(){

    switch (sim_state) {
     case _simState_intro: // Play Sequence
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

  void simon_reset(){
    if (_functionDebug) { Serial.println("Enter Init_intro"); }
    sim_state=_simState_intro;
    sim_currentUserStep = 0;
    sim_roundStep = 1;
    sim_misses = 0;
    generate_sequence();
    init_intro();
  }

  void generate_sequence(){
    if (_functionDebug) { Serial.println("Enter generate_sequence"); }
    randomSeed(long(currentTime));
    int row = int(mrandom(0,3));
    int col = int(mrandom(0,3));
    sim_seq[0][0] = row; sim_seq[0][1] = col;
    for (int i=1; i<16; i++){
      int dir = mrandom(1,8);
      switch (dir) {
        case 0: break;
        case 1: col++; break;
        case 2: col++; row++; break;
        case 3: row++; break;
        case 4: col--; row++; break; 
        case 5: col--; break; 
        case 6: col--; row--; break; 
        case 7: row--; break; 
        case 8: col--; row--; break; 
      }
      sim_seq[i][0] = row; sim_seq[i][1] = col;
      if (col<0 || col >3 || row<0 || row>3) { i--; row=sim_seq[i][0]; col=sim_seq[i][1];} // repeat if out of bounds
      if (i>1 and (sim_seq[i][0]==sim_seq[i-2][0] and sim_seq[i][1]==sim_seq[i-2][1])) {
        i--; row=sim_seq[i][0]; col=sim_seq[i][1];
      } // repeat if n-2 = n so that debouncing will work better.
    }
  }
      
  void init_intro(){
    if (_functionDebug) { Serial.println("Enter init_intro"); }
    sim_state = _simState_intro;
    sim_startTime = currentTime;
    sim_endTime = sim_startTime + _sim_introDuration;
  }

  void process_intro(){
    draw_all(0,0,0);
    char s[] = "Simon";
    unsigned long c1 = (currentTime/500) % 50;
    int offset = -int(c1);
    int i = 0;
    while (s[i] != 0){
      printChar(19,i*4+1,s[i],120,255,0);  
      i++;
    }
    if (currentTime > sim_endTime){
      init_seq();
    }
  }

  void init_seq(){
    if (_functionDebug) { Serial.println("Enter init_seq"); }
    sim_state = _simState_seq;
    sim_startTime = currentTime;
    sim_endTime = 0;
  }

  void process_seq(){
    if (_functionDebug) { Serial.println("Enter process_seq"); }
    draw_all(0,0,0);
    set_border(5,5,5);
    if (currentTime > sim_startTime + sim_roundStep*_sim_seqStepDuration) {
        init_wait();
      return; 
    }
    int step = (currentTime - sim_startTime) / _sim_seqStepDuration;
    draw_square(sim_seq[step][0],sim_seq[step][1],0,255,0);
  }

  // Wait starts with a clear board (noone on it) and waits for the first step.
  // It will timeout, but not implemented yet.
  void init_wait(){
    if (_functionDebug) {  Serial.println("Enter init_wait"); }
    sim_state=_simState_wait;
    sim_startTime = currentTime;
    sim_endTime = 0;
  }

  // this function will wait until the user is standing on the first square
  // 
  void process_wait(){
    if (_functionDebug) { Serial.println("Enter process_wait"); }
    draw_all(0,0,0);
    set_border(5,5,5);
    if ((numberSquaresDownOrPressed()==1) && (state[sim_seq[0][0]][sim_seq[0][1]] == _pressed)){
      draw_all(10,10,10);
      init_uGood();
      return;
    }
    int r = sim_seq[0][0];
    int c = sim_seq[0][1];
    int p = -1;
    int x = r*5; int y=c*5;
    int step = ((currentTime - sim_startTime) / 100) % 4;
    while (++p<16){
      if (p%4 == step){
        set_pixel(x,y,128,255,0);
      } else {
        set_pixel(x,y,0,0,255);
      }
      if (p < 4) {x++;}
      else if (p < 8) {y++;}
      else if (p < 12) {x--;}
      else {y--;}
    }
    return;
  }

  void init_uGood(){
    if (_functionDebug) { Serial.println("Enter init_uGood"); }
    sim_state=_simState_uGood;
    sim_startTime = currentTime;
    sim_endTime = 0;
    sim_currentUserStep = -1;
    process_uGood();  // needed to keep from losing the first press
  }

  // Check if the ones pressed are good
  void process_uGood(){
    if (_functionDebug) { Serial.println("Enter process uGood");}
    draw_all(0,0,0);
    set_border2(5,5,5);
    if (numberSquaresPressed()>1){
      drawBadSquare();
      init_uBad();
      return;
    }

    // check to see if pressed advances pointer
    if (numberSquaresPressed()==1){
      if (state[sim_seq[sim_currentUserStep][0]][sim_seq[sim_currentUserStep][1]]==_pressed){ // same square bouncing
        draw_square(sim_seq[sim_currentUserStep][0], sim_seq[sim_currentUserStep][1], 0, 255, 0);
        return;
      }
      if (sim_currentUserStep > 0 &&
          state[sim_seq[sim_currentUserStep-1][0]][sim_seq[sim_currentUserStep-1][1]]==_pressed){ // stepping to new square & bouncing on old
        draw_square(sim_seq[sim_currentUserStep][0],sim_seq[sim_currentUserStep][1],0,255,0);
        return;
      }
      sim_currentUserStep++;
      int row0 = sim_seq[sim_currentUserStep][0];
      int col0 = sim_seq[sim_currentUserStep][1];
      if (state[row0][col0] == _pressed){
        draw_square(row0,col0,0,255,0);
        if (sim_currentUserStep >= sim_roundStep-1) {
          init_wSeq();
          return;
        }           
      } else {
        if (_stepDebug){ Serial.println("Pressed Wrong"); }
        drawBadSquare();
        init_uBad();
        return;
      }
    } else {
      draw_square(sim_seq[sim_currentUserStep][0],
                  sim_seq[sim_currentUserStep][1],
                  0,255,0);
    }
    return;
  }

  // Sets the first found pressed square to badrow/badcol
  void drawBadSquare(){
    for (int i=0; i<4; i++){ 
      for (int j=0; j<4; j++){ 
        if (state[i][j] == _pressed){
          draw_square(i,j,255,0,0);
          badRow = i; badCol = j;
          return;
        }
      }
    }
  }

  void init_uBad(){
    if (_functionDebug) { Serial.println("Enter init_uBad"); }
    sim_state=_simState_uBad;
    sim_startTime = currentTime;
    sim_endTime = sim_startTime + _sim_badSquareDuration;
    sim_misses++;
  }

  void process_uBad(){
    draw_all(0,0,0);
    set_border(5,5,5);
    if (currentTime-sim_startTime < (sim_endTime-sim_startTime)/2) { 
      // show the last step
      draw_square(badRow,badCol,128,0,0);
    } else {
      drawStrikes(sim_misses);
    }
    if (currentTime >= sim_endTime){
      if (sim_misses >= _sim_maxMisses){
        init_lGame();
      } else {
        init_seq();
      }
    }
  }

  void drawStrikes(byte count){
      draw_square(3,0,0,0,0);
      draw_square(3,1,0,0,0);
      draw_square(3,2,0,0,0);
      if (count >= 1){ 
        draw_X(3,0);
      }
      if (count >= 2){ 
        draw_X(3,1);
      }
      if (count >= 3){ 
        draw_X(3,2);
      }
    }
  
    void draw_X(int row, int col){
      set_pixel(row*5+0, col*5+0, 255,0,0); set_pixel(row*5+0, col*5+4, 255,0,0);
      set_pixel(row*5+1, col*5+1, 255,0,0); set_pixel(row*5+1, col*5+3, 255,0,0);
      set_pixel(row*5+2, col*5+2, 255,0,0); 
      set_pixel(row*5+3, col*5+1, 255,0,0); set_pixel(row*5+3, col*5+3, 255,0,0);
      set_pixel(row*5+4, col*5+0, 255,0,0); set_pixel(row*5+4, col*5+4, 255,0,0);
    }
  
  void init_wSeq(){
    sim_state=_simState_wSeq;
    sim_startTime = currentTime;
    sim_endTime = sim_startTime + _sim_winSeqDuration;
    if (sim_roundStep >= sim_maxStep){
      init_wGame();
    } else {
      sim_roundStep++;
    }
  }

  void process_wSeq(){
      drawWinSeq();
      if (currentTime >= sim_endTime){
        init_seq();
      }
  }

  void drawWinSeq(){
    draw_all(0,100,100);
  }

  void init_wGame(){
    sim_state=_simState_wGame;
    sim_startTime = currentTime;
    sim_endTime = sim_startTime+_sim_winGameDuration;
  }

  void process_wGame(){
    drawWin();
    if (currentTime >= sim_endTime){
      game_boot();
    }
  }

  void drawWin(){
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

  void init_lGame(){
    sim_state=_simState_lGame;
    sim_startTime = currentTime;
    sim_endTime =sim_startTime + _sim_loseGameDuration;
  }

  void process_lGame(){
    draw_all(255,0,0);
    if (currentTime >= sim_endTime){
      game_boot();
    }
  }
}