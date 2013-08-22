void setup() {
  TCL.begin();
  for (int i=0; i<4; i++){
    for (int j=0; j<4; j++){
      state[i][j] = _up;
    }
  }
  for (int i=0; i<20; i++){
    for (int j=0; j<20; j++){
      pallette[i][j][0] = 30;
      pallette[i][j][1] = 30;
      pallette[i][j][2] = 0;
    }
  }
  pinMode(A0, INPUT);
  pinMode(A1, INPUT);
  pinMode(2, OUTPUT);
  pinMode(3, OUTPUT);
  pinMode(4, OUTPUT);
  digitalWrite(4,LOW);
  pinMode(5, OUTPUT);
  Serial.begin(9600);
  randomSeed(analogRead(4)); // setup for a different starting point for the random number 
//  pongGame::game_boot();
  simon::game_boot();
}

void loop() {
  currentTime = millis();
/*  if (currentTime >= displayTime) {
 //   fire();
 //   pongGame::game_draw(currentTime - displayTime);
    simon::game_draw(currentTime - displayTime);
 //   printText();
    displayTime = currentTime + _lodo_drawPoll;
  }*/
  if (currentTime >= lodo_updateTime) {
    updateBoard();
    simon::gameUpdate();
    lodo_updateTime = currentTime + _lodo_updatePoll;
    printLights();
  } 
}

