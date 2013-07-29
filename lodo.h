// SIMON STATE VARIABLES
 
// SIMON VARIABLES
 
// SIMON STATES
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
const unsigned long _simTimeout_intro = 3000;
const unsigned long _simTimeout_seq  = 500;
const unsigned long _simTimeout_wait  = 5000;
const unsigned long _simTimeout_uGood = 5000;
const unsigned long _simTimeout_uBad  = 3000;
const unsigned long _simTimeout_wSeq  = 3000;
const unsigned long _simTimeout_wGame = 15000;
const unsigned long _simTimeout_lGame = 10000;
const unsigned long _sim_updatePoll = 100;
 
//SIMON TIME VARIABLES
unsigned long simTime_intro = 0;
unsigned long simTime_seq = 0;
unsigned long simTime_wait  = 0;
unsigned long simTime_clear  = 0;
unsigned long simTime_cWait  = 0;
unsigned long simTime_uGood = 0;
unsigned long simTime_uBad  = 0;
unsigned long simTime_wSeq  = 0;
unsigned long simTime_wGame = 0;
unsigned long simTime_lGame = 0;
unsigned long simTime_updatePoll = 0;
 
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
 
//
int colorArray[24][3] = {
  {0 , 0, 0},   // _black
  {32,  0,  0}, // _red0
  {0 , 32, 0 }, // _green0
  { 0,  0, 32}, // _blue0
  { 0, 32, 32}, // _turq0
  {32,  0, 32}, // _pink0
  {32, 32,  0}, // _yellow0
  {32, 32, 32},
  {128,   0,   0},
  {  0, 128,   0},
  {  0,   0, 128},
  {  0, 128, 128},
  {128,   0, 128},
  {128, 128,   0},
  {128, 128, 128},
  {255,   0, 0},
  {  0, 255,   0},
  {  0,   0, 255},
  {  0, 255, 255},
  {255,   0, 255},
  {255, 255,   0},
  {255, 255, 255},
  {0,0,1},
  {1,1,1}
};
 
 
const int _black   = 0;
const int _red0   = 1;
const int _green0  = 2;
const int _blue0   = 3;
const int _turq0   = 4;
const int _pink0   = 5;
const int _yellow0 = 6;
const int _white0  = 7;
const int _red1   = 8;
const int _green1  = 9;
const int _blue1   = 10;
const int _turq1   = 11;
const int _pink1   = 12;
const int _yellow1 = 13;
const int _white1  = 14;
const int _red2   = 15;
const int _green2  = 16;
const int _blue2   = 17;
const int _turq2   = 18;
const int _pink2   = 19;
const int _yellow2 = 20;
const int _white   = 21;
const int _darkblue    = 22;
const int _grey    = 23;
int seq_color [] = {_pink0, _turq0, _yellow0, _green0, _pink0, _turq0, _yellow0, _green0};
 
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

