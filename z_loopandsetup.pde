void drawCurrentGame() {
  switch (currentGame) {
    case _gameSelector:
      gameSelector::game_draw();
      break;
    case _simonGame:
      // do nothing, draw in update
      break;
    case _pongGame:
      pongGame::game_draw();
      break;
  }
}

void updateCurrentGame() {
  switch (currentGame) {
    case _gameSelector:
      gameSelector::game_update();
      break;
    case _simonGame:
      simon::game_update();
      break;
    case _pongGame:
      pongGame::game_update();
      break;
  }
}

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
  gameSelector::game_boot();
}

void loop() {
  currentTime = millis();
  if (currentTime >= lodo_updateTime) {
    updateBoard();
    updateCurrentGame();
    lodo_updateTime = currentTime + _lodo_updatePoll;
    drawCurrentGame();
    printLights();
  } 
}

