// -- Board Interactive Classes --


class Interactive {
  Board board;
  
  Interactive(Board _board) {
    board = _board;
  }
  
  void manage() {}
}


class DiePairPair extends Interactive { // both (left/right) pairs of dice
  DiePair[] diePairPair;
  ArrayList<Physics.Box> allDice;
  ParticleField field;
  
  DiePairPair(Board _board) {
    super(_board);
    
    allDice = new ArrayList<Physics.Box>();
    field = new ParticleField();
    
    diePairPair = new DiePair[2];
    diePairPair[0] = new DiePair(board, allDice, field, false); // left
    diePairPair[1] = new DiePair(board, allDice, field, true);  // right
  }
  
  @Override
  void manage() {
    field.manage();
    for (DiePair dp : diePairPair) {
      dp.manage();
    }
  }
}


// CLASS DIEPAIR


// CLASS DIE


class BoardReset extends Interactive {
  PVector pos;
  float size;
  
  color colFill, colStroke;
  float outlineSize, rounding;
  
  // --
  
  PVector[] hitbox;
  
  int holdCountdown, holdCountdownReset;
  float countdownPercent;
  
  BoardReset(Board _board, PVector _pos) {
    super(_board);
    
    pos = _pos.copy();
    size = Settings.BOARDRESET_SIZE_PERCENT * board.size.y;
    
    colFill = -1;
    colStroke = Palette.BOARDRESET_OUTLINE;
    outlineSize = Settings.BOARDRESET_OUTLINE_PERCENT * size;
    rounding = Settings.BOARDRESET_ROUNDING_PERCENT * size;
    
    // --
    
    hitbox = new PVector[2];
    hitbox[0] = pos.copy().sub(size / 2, size / 2);
    hitbox[1] = pos.copy().add(size / 2, size / 2);
    
    holdCountdown = -1;
    countdownPercent = 0;
    holdCountdownReset = Settings.BOARDRESET_HOLD_FRAMES;
  }
  
  // --
  
  void manage() {
    update();
    display();
  }
  
  void update() {
    setColor();
    
    manageCountdown();
  }
  
  void display() {
    drawButton();
    drawLoading();
  }
  
  // --
  
  void manageCountdown() {
    if (holdCountdown == -1) {
      if (mouse.tap && mouse.inRange(hitbox)) holdCountdown = holdCountdownReset;
    }
    
    if (mouse.released || !mouse.pressed) holdCountdown = -1;
    
    if (holdCountdown > 0) {
      countdownPercent = (float) (holdCountdownReset - holdCountdown) / holdCountdownReset;
      
      long vibrateAmount = (long) map(countdownPercent, 0, 1, Settings.VIBRATE_AMOUNT_BOARDRESET_MIN, Settings.VIBRATE_AMOUNT_BOARDRESET_MAX);
      vibrate(vibrateAmount);
      
      holdCountdown--;
    }
    
    else if (holdCountdown == 0) {
      board.initiateBoardSetup();
      holdCountdown = -1;
    }
  }
  
  void drawButton() {
    fill(colFill);
    stroke(colStroke);
    strokeWeight(outlineSize);
    
    rectCustomCenter(pos, size, rounding);
  }
  
  void drawLoading() {
    if (holdCountdown > 0) {
      float loadingSize = 0.5 * board.size.x;
      float loadingOutlineSize = 0.1 * loadingSize;
      
      loadingAnimation(countdownPercent, pos, loadingSize, loadingOutlineSize, 15);
    }
  }
  
  // --
  
  void setColor() {
    float hue = (frameCount / 3.0) % 360;
    colFill = color(hue, 50, 100);
  }
}
