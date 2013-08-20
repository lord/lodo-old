/*****************************************************************************
 * lodo.ino
 *
 ****************************************************************************/
#include <SPI.h>
#include <TCL.h>
#include <math.h>


namespace simonGame {

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
  unsigned long simTime_intro = 0;
  unsigned long simTime_seq = 0;
  unsigned long simTime_wait  = 0;
  unsigned long simTime_clear  = 0;
  unsigned long simTime_cWait  = 0;
  unsigned long simTime_uGood = 0;
  unsigned long simTime_uBad  = 0;
  unsigned long simTime_uBad_step  = 0;
  unsigned long simTime_wSeq  = 0;
  unsigned long simTime_wSeq_step  = 0;
  unsigned long simTime_wGame = 0;
  unsigned long simTime_lGame = 0;

  //Simon Variables
  int sim_seq[16][2]={{0,0},{0,1},{1,1},{2,1},{3,0},{3,1},{3,0},{2,1},{1,1},{1,2},{0,2},{1,2},{2,3},{3,3},{2,2},{1,1}};
  int sim_currentStep = 0;
  int sim_displayStep = 0;
  int sim_maxStep = 8;
  unsigned long sim_updateTime = 0;
  int sim_state = 0;
  int sim_currentUserStep = 0;
  int sim_roundStep = 1;
  int sim_misses = 0;
  const int _sim_maxMisses = 3;
  int sim_introState = 0;
  int badRow = 0;
  int badCol = 0;
  int sim_intro_type = 0;

  void update();
  void init_intro();
  void process_intro();
  void draw_intro();
  void generate_sequence();
  void init_seq();
  void process_seq();
  void setSequence();
  void init_wait();
  void process_wait();
  void printArrow();
  void init_uGood();
  void process_uGood();
  void process_uGood2();
  void setBadSquare();
  void init_uBad();
  void process_uBad();
  void drawBadStep();
  void drawStrikes(int strikeCount);
  void setCorners();
  void d_X(int pRow, int pCol, int fg);
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

  const boolean _functionDebug = 0;
  const boolean _stateMDebug = 0;
  const boolean _stepDebug = 0;
  
  byte board[4][4];
  byte arrow[4][4];
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

  }

  void update(){
    switch (sim_state) {
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
    sim_state=_simState_seq;
    sim_currentUserStep = 0;
    sim_roundStep = 0;
    sim_misses = 0;
    generate_sequence();
  }

  void generate_sequence(){
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
    }
  }

      
  void init_seq(){
    if (_functionDebug) { Serial.println("Enter init_seq"); }
    sim_state=_simState_seq;
    simTime_seq = currentTime + _simTimeout_seq;
    sim_displayStep = 0;
  }

  void process_seq(){
    draw_all(0,0,3);
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
//    board[row][col] = seq_color[colorIndex];
  }

  // Wait starts with a clear board (noone on it) and waits for the first step.
  // It will timeout, but not implemented yet.
  void init_wait(){
    if (_functionDebug) {  Serial.println("Enter init_wait"); }
    sim_state=_simState_wait;
    simTime_wait = currentTime + _simTimeout_wait;
  }

  void process_wait(){
    if (currentTime > simTime_wait){
      badCol=sim_seq[0][0]; badRow=sim_seq[0][1]; // set the red to the first square
      init_uBad();
      return; 
    }
    if ((numberSquaresDown()==1) && (state[sim_seq[0][0]][sim_seq[0][1]] == _down)){
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
//    if (_arrowDebug) { printArrow(); }
    return;
  }


  void printArrow(){
    const char rs[] = {'.','>','^','<','_','-','|','X'};
    Serial.println("");
    Serial.print("Arrow"); Serial.println();
    for (int i=0; i<4; i++){
      for (int j=0; j<4; j++){
        Serial.print(rs[arrow[i][j]]);
      }
      Serial.println();
    }
  }

  void init_uGood(){
    if (_functionDebug) { Serial.println("Enter init_uGood"); }
    sim_state=_simState_uGood;
    simTime_uGood = currentTime + _simTimeout_uGood;
    sim_currentUserStep = -1;
    process_uGood();  // needed to keep from losing the first press
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
    // setBoardToColor(_darkblue);

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
          // board[i][j] = _green0;
        }
      }
    }
    return;
  }

  void process_uGood2(){
    if (_functionDebug) { Serial.println("Enter uGood");}
    if (_stepDebug) { Serial.print("CUS: "); Serial.println(sim_currentUserStep); }  
    if (sim_currentUserStep == -1) { // convert the _down to a _press for the first step as they are on the right square
      state[sim_seq[0][0]][sim_seq[0][1]] = _pressed;
    }
    // setBoardToColor(_darkblue);
    int currentSeqState = state[sim_seq[sim_currentUserStep][0]][sim_seq[sim_currentUserStep][1]];
    if (currentSeqState == _released || (numberSquaresDownOrPressed()==1 && currentSeqState )){

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
          // board[i][j] = _green0;
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
    simTime_uBad_step = currentTime + _simTimeout_uBad_step;
    if (++sim_misses >= _sim_maxMisses){
      // you lose!!
      init_lGame();
    }
  }

  void process_uBad(){
    draw_all(1,1,1);
    // board[badRow][badCol] = _red1;
    if (currentTime <= simTime_uBad_step){ // flash the last step
      drawBadStep();
    } else {
      drawStrikes(sim_misses);
    }
    if (currentTime >= simTime_uBad){
      init_seq();
    }
  }

  void drawBadStep(){
    //board[sim_seq[sim_roundStep-1][0]][sim_seq[sim_roundStep-1][1]] = _white;
    // board[badRow][badCol] = _red0;
  }

  void drawStrikes(int count){
/*    setCorners(_grey, _black);
    d_rect(15, 0, 5, 15, _white);
    d_rect(16, 1, 3, 3,  _black);
    d_rect(16, 6, 3, 3,  _black);
    d_rect(16, 11, 3, 3, _black);
    if (count >= 1){ 
      // d_X(15,0,_red2); 
    }
    if (count >= 2){ 
      // d_X(15,5,_red2);
    }
    if (count >= 3){ 
      // d_X(15,10,_red2); 
    }*/
  }

  void setCorners(int fg, int bg){
    d_rect(0,0,20,20, bg);
    d_rect(0,0,2,2,fg);
    d_rect(18,0,2,2,fg);
    d_rect(0,18,2,2,fg);
    d_rect(18,18,2,2,fg);
  }

  void d_X(int pRow, int pCol, int fg){
/*    d_setPixel(pRow+0,pCol+0,fg); d_setPixel(pRow+4,pCol+0,fg);
    d_setPixel(pRow+1,pCol+1,fg); d_setPixel(pRow+3,pCol+1,fg);
    d_setPixel(pRow+2,pCol+2,fg); 
    d_setPixel(pRow+1,pCol+3,fg); d_setPixel(pRow+3,pCol+3,fg);
    d_setPixel(pRow+0,pCol+4,fg); d_setPixel(pRow+4,pCol+4,fg);
  */}

  void d_square(int x, int y, int side, int color){
    d_rect(x, y, side, side, color);
  }

  void d_rect(int x, int y, int dx, int dy, int color){
    for (int r=x; r<x+dx; r++){
      for (int c=y; c<y+dy; c++){
  //      d_setPixel(r,c,color);
      }
    }
  }

  void init_wSeq(){
    sim_state=_simState_wSeq;
    simTime_wSeq = currentTime + _simTimeout_wSeq;
    simTime_wSeq_step = currentTime + _simTimeout_wSeq_step;
    if (sim_roundStep >= sim_maxStep){
      init_wGame();
    } else {
      sim_roundStep++;
    }
  }

  void process_wSeq(){
      drawWinSeq();
      if (currentTime >= simTime_wSeq){
        init_seq();
      }
  }

  void drawRightStep(){
    /*for (int i=0; i<4; i++){
      for (int j=0; j<4; j++){
        // setPalletteToColor(i,j,_black);
      }
    }
//    board[sim_seq[sim_roundStep-1][0]][sim_seq[sim_roundStep-1][1]] = _white;
    int row = sim_seq[sim_roundStep-1][0];
    int col = sim_seq[sim_roundStep-1][1];
    int rnd = currentTime%200;
    int color1 = 0;
    int color2 = 1;
    if (rnd > 100) {
      // color1 = _black; color2 = _green1;
    } else {
      // color2 = _black; color1 = _green1;    
    }  
    pallette[row*5+0][col*5+0]=color1;pallette[row*5+0][col*5+1]=color1;pallette[row*5+0][col*5+2]=color1;pallette[row*5+0][col*5+3]=color2;pallette[row*5+0][col*5+4]=color2;
    pallette[row*5+1][col*5+0]=color1;pallette[row*5+1][col*5+1]=color1;pallette[row*5+1][col*5+2]=color1;pallette[row*5+1][col*5+3]=color2;pallette[row*5+1][col*5+4]=color2;
    pallette[row*5+2][col*5+0]=color1;pallette[row*5+2][col*5+1]=color1;pallette[row*5+2][col*5+2]=color1;pallette[row*5+2][col*5+3]=color1;pallette[row*5+2][col*5+4]=color1;
    pallette[row*5+3][col*5+0]=color2;pallette[row*5+3][col*5+1]=color2;pallette[row*5+3][col*5+2]=color1;pallette[row*5+3][col*5+3]=color1;pallette[row*5+3][col*5+4]=color1;
    pallette[row*5+4][col*5+0]=color2;pallette[row*5+4][col*5+1]=color2;pallette[row*5+4][col*5+2]=color1;pallette[row*5+4][col*5+3]=color1;pallette[row*5+4][col*5+4]=color1;
  */}

  void init_wGame(){
    sim_state=_simState_wGame;
    simTime_wGame = currentTime + _simTimeout_wGame;
//    d_rect(0,0,20,20,_black);
  }

  void process_wGame(){
    drawWin();
    if (currentTime >= simTime_wGame){
      init_intro();
    }
  }

  void drawWin(){
    int diameter = mrandom(0,2);
    int x = 0; int y=0;
    switch (diameter){
      case 0: 
        x=random(1,18); y=random(1,18); 
        // d_circle_green(x,y,1);
        break;
      case 1: 
        x=random(2,17); y=random(2,17); 
        // d_circle_green(x,y,3);
        break;
      case 2: 
        x=random(3,16); y=random(3,16); 
        // d_circle_green(x,y,5);
        break;
    }
  }

  void init_lGame(){
    sim_state=_simState_lGame;
    simTime_lGame = currentTime + _simTimeout_lGame;
  }

  void process_lGame(){
  //  setBoardToColor(_black);
    drawLose();
    if (currentTime >= simTime_lGame){
      init_intro();
    }
  }

  void drawLose(){
    for (int i=0; i<4; i++){
      for (int j=0; j<4; j++){
  //      setPalletteToColor(i,j,_black);
      }
    }
    drawStrikes(3);
    for (int offset=-1; offset<=1; offset++){
      for (int i=0; i<10; i++){
        //if (i+offset+5 >= 5 && i+offset+5 <= 14) { pallette[i+offset+5][i+5]=_red1; }
        //if (i+offset+5 >= 5 && i+offset+5 <= 14) { pallette[i+offset+5][9-i+5]=_red1;}
      }
    }
  }

  
  void setBoardToSimonSeq(int displayStep){
 //   setBoardToColor(_darkblue);
    int row = sim_seq[displayStep][0];
    int col = sim_seq[displayStep][1];
    //board[row][col] = _white;
  }


  // ___________ draw
  //
  // outputs the board based upon the board color variable or pallette based on it
  //

  void setPalletteToArrow(int row, int col, int arrowType){
    draw_all(0,0,0);
/*    const int fg = _green1; 

    int rot = (currentTime/100)%4;
    // int fg1=_yellow1; int fg2=_red1; int fg3=_blue1; int fg4=_pink1;
    switch (rot){
      case 0: fg1=_yellow1; fg2=_blue1; fg3=_blue1; fg4=_blue1; break;
      case 1: fg2=_yellow1; fg3=_blue1; fg4=_blue1; fg1=_blue1; break;
      case 2: fg3=_yellow1; fg4=_blue1; fg1=_blue1; fg2=_blue1; break;
      case 3: fg4=_yellow1; fg1=_blue1; fg2=_blue1; fg3=_blue1; break;
    }
    // fg=_greenC53; 
    int p[5][5] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    for (int i=0; i<5; i++){
      for (int j=0; j<5; j++){
        p[i][j] = _black;
      }
    }
    for (int i=0; i<5; i++){
      for (int j=0; j<5; j++){
    switch (arrowType){
      case _arrow_up:
//        setPixel[0][col*5+2]=fg;
        p[row*5+1][col*5+1]=fg;p[1][2]=fg;p[1][3]=fg;
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
        p[0][0]=fg1;p[0][1]=fg2;p[0][2]=fg3;p[0][3]=fg4;p[0][4]=fg1;
        p[1][0]=fg4;p[1][4]=fg2;
        p[2][0]=fg3;p[2][4]=fg3;
        p[3][0]=fg2;p[3][4]=fg4;
        p[4][0]=fg1;p[4][1]=fg4;p[4][2]=fg3;p[4][3]=fg2;p[4][4]=fg1;
        break;
        pallette[row*5+i][col*5+j] = p[i][j];
      }
    }  
    }
  */}
}