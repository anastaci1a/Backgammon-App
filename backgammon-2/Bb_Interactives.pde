// -- Board Interactive Classes (high level) --


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


class BoardReset extends Interactive {
  PVector pos;
  float size;
  
  color colFill, colStroke;
  float outlineSize, rounding;
  
  // --
  
  PVector[] hitbox;
  
  int holdCountdown, holdCountdownReset;
  float countdownPercent;
  
  // --
  
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



class TeamProgress extends Interactive {
  int[] blackPPValues, whitePPValues;
  
  int blackProgress, whiteProgress;
  int blackProgress_change, whiteProgress_change;
  
  int maxPieceValue, maxTeamProgress;
  
  boolean shouldCalculate;
  
  // --
  
  ParticleField field;
  PVector blackParticlesPos, whiteParticlesPos;
  
  ProgressBar blackPB, whitePB;
  
  TeamProgress(Board _board) {
    super(_board);
    
    blackProgress = 0;
    whiteProgress = 0;
    
    blackProgress_change = 0;
    whiteProgress_change = 0;
    
    maxPieceValue   = (4 * Settings.BOARD_PILLARS_PER_SECTION) + 1;
    maxTeamProgress = maxPieceValue * Settings.PIECES_PER_COLOR;
    
    setPPValues();
    
    // --
    
    field = new ParticleField();
    
    float diceSize = Settings.DICE_SIZE_PERCENT * board.size.x;
    float textSize = Settings.PARTICLE_SCORE_TEXT_SIZE_PERCENT * board.size.x;
    
    float deltaX = (board.size.x / 2) - diceSize - (textSize / 1.2);
    
    blackParticlesPos = board.center.copy().add(-deltaX, 0);
    whiteParticlesPos = board.center.copy().add(deltaX, 0);
  }
  
  void setupPBs(ProgressBar white, ProgressBar black) {
    blackPB = black;
    whitePB = white;
  }
  
  // --
  
  @Override
  void manage() {
    update();
    field.manage();
  }
  
  void update() {
    if (board.safeFrame) {
      calculateProgress();
      observeChange();
    }
  }
  
  // --
  
  void calculateProgress() {
    int blackProgress_prev = blackProgress;
    int whiteProgress_prev = whiteProgress; 
    
    blackProgress = 0;
    whiteProgress = 0;
    
    for (int i = 0; i < board.piecePools.size(); i++) {
      PiecePool pp = board.piecePools.get(i);
      
      int blackAmount = pp.piecesOfColorInPool(Palette.PIECE_DARK);
      int whiteAmount = pp.piecesOfColorInPool(Palette.PIECE_LIGHT);
      
      blackProgress += blackPPValues[i] * blackAmount;
      whiteProgress += whitePPValues[i] * whiteAmount;
    }
    
    blackProgress_change = blackProgress - blackProgress_prev;
    whiteProgress_change = whiteProgress - whiteProgress_prev;
    
    // progress bar
    
    int ratio1 = blackProgress; //maxTeamProgress - whiteProgress;
    int ratio2 = whiteProgress; //maxTeamProgress - blackProgress;
    float ratio = (float) ratio1 / (ratio1 + ratio2);
    
    Ease curve = Ease.INOUT_EXPO;
    float ratioCurved = curve.apply(ratio); // once isn't enough
    
    blackPB.moveTo(ratioCurved);
    whitePB.moveTo(1 - ratioCurved);
  }
  
  void observeChange() {
    boolean shouldObserveChange = (blackProgress_change != 0 || whiteProgress_change != 0);
    shouldObserveChange = shouldObserveChange && !board.doNotProcessFrame;
    
    // score indicator particles
    if (shouldObserveChange) {
      // one player gets fx (the one moving), unless other player gets out
      
      if (blackProgress_change != 0) {
        int totalChange = blackProgress_change; // - whiteProgress_change;
        field.addPreset(ParticlePreset.SCORE_INDICATOR, blackParticlesPos, false, totalChange);
      }
      
      if (whiteProgress_change != 0) {
        int totalChange = whiteProgress_change; // - blackProgress_change;
        field.addPreset(ParticlePreset.SCORE_INDICATOR, whiteParticlesPos, true, totalChange);
      }
      
      
      // both players get fx each turn
      
      //int totalChange_black = blackProgress_change - whiteProgress_change;
      //field.addPreset(ParticlePreset.SCORE_INDICATOR, blackParticlesPos, false, totalChange_black);
      
      //int totalChange_white = whiteProgress_change - blackProgress_change;
      //field.addPreset(ParticlePreset.SCORE_INDICATOR, whiteParticlesPos, true, totalChange_white);
      
      
      // reset derivs
      
      whiteProgress_change = 0;
      blackProgress_change = 0;
    }
  }
  
  void setPPValues() {
    int PPS = Settings.BOARD_PILLARS_PER_SECTION;
    
    int poolsTotal = (4 * PPS) + 6; // 4 sections, 6 other pools (4 homes, 2 outs)
    blackPPValues = new int[poolsTotal];
    whitePPValues = new int[poolsTotal];
    
    
    // black
    
    // top L/R (B/W) homes
    blackPPValues[0] = maxPieceValue;
    blackPPValues[1] = 0;
    
    // center quarries (piece is out)
    blackPPValues[2] = 0;
    blackPPValues[3] = 0;
    
    // bottom L/R (W/B) "homes" (meaningless unless game is rotated 180° ...which doesn't happen)
    blackPPValues[4] = 0;
    blackPPValues[5] = maxPieceValue;
    
    // all other pools (sequence: TL/BL/TR/BR)
    int i = 6;
    for (int j = 0; j < PPS; j++) {
      // top left
      blackPPValues[i] = (4 * PPS) - j;
      
      // bottom left
      blackPPValues[i + 1] = (3 * PPS) - j;
      
      // top right
      blackPPValues[i + 2] = j + 1;
      
      // bottom right
      blackPPValues[i + 3] = PPS + 1 + j;
      
      // iter
      i += 4;
    }
    
    
    // white
    
    // white is (mostly) the inverse of black
    for (int j = 0; j < poolsTotal; j++) {
      whitePPValues[j] = maxPieceValue - blackPPValues[j];
    }
    
    // center quarries (piece is out)
    whitePPValues[2] = 0;
    whitePPValues[3] = 0;
  }
}


class ProgressBar extends Interactive {
  PVector pos, size;
  boolean flip;
  
  float currentProgress, startProgress, endProgress;
  
  int easeFramesTotal, easeFrames;
  Ease easeFunc;
  
  // --
  
  color startColor, previewColor, endColor, outlineColor;
  
  float outlineSize;
  float rounding;
  
  ProgressBar(Board _board, PVector _pos, PVector _size, boolean _flip) {
    super(_board);
    
    pos = _pos;
    size = _size;
    flip = _flip;
    
    currentProgress = 0.5;
    startProgress = 0; endProgress = 0;
    
    easeFunc = Settings.ANIM_EASE_MEDIUM;
    easeFrames = 0;
    easeFramesTotal = Settings.ANIM_FRAMECOUNT_MEDIUM;
    
    // --
    
    startColor   = Palette.PROGRESSBAR_DARK;
    previewColor = Palette.PROGRESSBAR_PREVIEW;
    endColor     = Palette.PROGRESSBAR_LIGHT;
    outlineColor = Palette.PROGRESSBAR_OUTLINE;
    
    if (flip) {
      color temp = startColor;
      
      startColor = endColor;
      endColor = temp;
    }
    
    outlineSize = Settings.PROGRESSBAR_OUTLINE_PERCENT * board.size.x;
    rounding    = Settings.PROGRESSBAR_ROUNDING_PERCENT * board.size.x;
  }
  
  @Override
  void manage() {
    update();
    display();
  }
  
  void update() {
    if (easeFrames <= easeFramesTotal) {
      float easeVal = getEaseVal();
      currentProgress = map(easeVal, 0, 1, startProgress, endProgress);
      
      easeFrames++;
    }
  }
  
  void display() {
    pushMatrix();
    
    translate(pos.x, pos.y);
    rotate(HALF_PI);
    
    // "background" of progress bar (end color)
    
    fill(endColor);
    noStroke();
    
    rectCustomHere(size, rounding);
    
    // "progress' shadow" (preview color)
    
    pushMatrix();
    
    translate((size.x * endProgress / 2) - (size.x / 2), 0);
    fill(getEasedPreviewColor());
    
    PVector previewProgressSize = new PVector(size.x * endProgress, size.y);
    rectCustomHere(previewProgressSize, rounding);
    
    popMatrix();
    
     // "progress of progress" (start color)
    
    pushMatrix();
    
    translate((size.x * currentProgress / 2) - (size.x / 2), 0);
    fill(startColor);
    
    PVector currentProgressSize = new PVector(size.x * currentProgress, size.y);
    rectCustomHere(currentProgressSize, rounding);
    
    popMatrix();
    
    popMatrix();
  }
  
  // --
  
  void moveTo(float newProgress) {
    easeFrames = 0;
    
    startProgress = currentProgress;
    endProgress = newProgress;
  }
  
  float getEaseVal() {
    float easeX = (float) easeFrames / easeFramesTotal;
    return easeFunc.apply(easeX);
  }
  
  color getEasedPreviewColor() {
    float easeVal = easeFunc.apply(easeFunc.apply(getEaseVal()));
    color easedCol = lerpColor(endColor, previewColor, easeVal);
    
    return easedCol;
  }
}
