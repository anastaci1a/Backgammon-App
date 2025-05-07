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


class DiePair {
  Board board;
  
  // --
  
  boolean flip;
  int flipSign;
  
  ArrayList<Physics.Box> dice;
  ArrayList<Physics.Box> allDice;
  
  ArrayList<PVector> diceBasePositions;
  float diceSize, diceFriction;
  
  PVector[] hitboxCorners;
  
  // --
  
  boolean diceReady, diceHeld, diceBoardEnable, diceBounce, diceReturn;
  
  float spinDiceDist;
  float spin, spinVel, spinAcc, spinVelStart, spinVelMax;
  float spinVelMagPercent;
  
  float diceReleaseVelFactor;
  
  int diceReturnCountdown, diceReturnCountdownStart;
  ArrayList<PVector> diceReturnStartPositions;
  FloatList diceReturnStartRotations;
  Ease diceReturnEase;
  
  float diceBounceSlowVelThres, diceBounceSlowFactor;
  float diceReturnVelThres;
  
  // --
  
  boolean doublesMode;
  ParticleField field;
  
  DiePair(Board _board, ArrayList<Physics.Box> _allDice, ParticleField _field, boolean _flip) {
    board = _board;
    field = _field;
    
    // --
    
    flip = _flip;
    flipSign = flip ? -1 : 1;
    
    dice = new ArrayList<Physics.Box>();
    allDice = _allDice;
    
    diceBasePositions = new ArrayList<PVector>();
    
    diceSize = Settings.DICE_SIZE_PERCENT * board.size.x;
    diceFriction = Settings.DICE_FRICTION;
    
    // general dice positional setup
    float dicePadding     = Settings.DICE_PADDING_PERCENT * board.size.x;
    float diceDeltaY_half = (diceSize + dicePadding) / 2;
    float diceDeltaX      = dicePadding + (diceSize / 2);
    float diceX           = (flip ? board.size.x : 0) + (flipSign * diceDeltaX);
    
    // top die
    PVector topDiePos = new PVector(diceX, board.center.y - diceDeltaY_half);
    diceBasePositions.add(topDiePos.copy());
    Die topDie = new Die(
      allDice.size(),
      this,
      topDiePos,
      diceSize,
      flip,
      diceFriction,
      allDice
    );
    dice.add(topDie);
    allDice.add(topDie);
    
    // bottom die
    PVector bottomDiePos = new PVector(diceX, board.center.y + diceDeltaY_half);
    diceBasePositions.add(bottomDiePos.copy());
    Die bottomDie = new Die(
      allDice.size(),
      this,
      bottomDiePos,
      diceSize,
      flip,
      diceFriction,
      allDice
    );
    dice.add(bottomDie);
    allDice.add(bottomDie);
    
    float diceBounds_paddingY = Settings.BOARD_SHELF_THICK_PERCENT * board.size.y;
    float diceBounds_paddingX = Settings.BOARD_SHELF_THIN_PERCENT * board.size.y;
    PVector[] diceBounds = new PVector[2];
    diceBounds[0] = board.corners[0].copy().add(diceBounds_paddingX, diceBounds_paddingY);
    diceBounds[1] = board.corners[1].copy().sub(diceBounds_paddingX, diceBounds_paddingY);
    
    dice.get(0).boundsCorners = diceBounds;
    dice.get(1).boundsCorners = diceBounds;
    
    for (Physics.Box d : dice) {
      Die die = (Die) d;
      
      die.boundsCorners = diceBounds;
      die.setOtherDie();
    }
    
    // --
    
    float hitboxWidth_percentOfMax  = 0.95;
    float hitboxHeight_percentOfMax = 0.95;
    
    float thinShelf  = Settings.BOARD_SHELF_THIN_PERCENT  * board.size.x;
    float thickShelf = Settings.BOARD_SHELF_THICK_PERCENT * board.size.y;
    
    float hitboxMaxWidth = ((1 - Settings.BOARD_SHELF_MIDDLE_PERCENT) * (board.size.x / 2)) - thinShelf;
    
    float hitboxDeltaWidth  = hitboxWidth_percentOfMax  * hitboxMaxWidth;
    float hitboxDeltaHeight = hitboxHeight_percentOfMax * thickShelf;
    
    PVector hitboxTopLeftPosDelta   = new PVector(flipSign * (thinShelf - (board.size.x / 2)), -hitboxDeltaHeight / 2); // delta of board.center
    PVector hitboxBottomCornerDelta = new PVector(flipSign * hitboxDeltaWidth, hitboxDeltaHeight);
    
    hitboxCorners = new PVector[2];
    hitboxCorners[0] = PVector.add(board.center, hitboxTopLeftPosDelta);
    hitboxCorners[1] = hitboxCorners[0].copy().add(hitboxBottomCornerDelta);
    
    // --
    
    // modes
    diceReady       = true;
    diceHeld        = false;
    diceBoardEnable = false;
    diceBounce      = false;
    diceReturn      = false;
    
    // spin animation
    spinDiceDist = 3.5 * diceSize;
    
    spin = 0;
    spinVel = 0;
    
    spinAcc = 0.005;
    spinVelStart = 0.1;
    spinVelMax = 0.6; // max before glitching out (at this spinDiceDist)
    
    spinVelMagPercent = 0.2; // percent of total distance to mouse
    
    diceReleaseVelFactor = 2;
    
    // bouncing
    diceBounceSlowVelThres  = 0.010 * diceSize;
    diceBounceSlowFactor = 0.95;
    
    diceReturnVelThres = 0.001 * diceSize;
    
    // return animation
    diceReturnCountdown = -1;
    diceReturnStartPositions = new ArrayList<PVector>();
    diceReturnStartRotations = new FloatList();
    
    diceReturnCountdownStart = Settings.ANIM_FRAMECOUNT_INOUT;
    diceReturnEase           = Settings.ANIM_EASE_INOUT;
    
    // --
    
    doublesMode = false;
    
    //if (flip) {
    //  int iterations = 10000000;
      
    //  // number fairness
      
    //  //float accuracy = ((Die) dice.get(0)).testFairness(iterations);
    //  //println(accuracy, accuracy * Settings.DICE_RANDOM_RANGE);
      
      
    //  // doubles fairness
      
    //  int doublesTimes = 0;
    //  for (int i = 0; i < iterations; i++) {
    //    randomize();
        
    //    Die die0 = (Die) dice.get(0);
    //    Die die1 = (Die) dice.get(1);
        
    //    die0.number = die0.getRandomNumber();
    //    die1.number = die1.getRandomNumber();
        
    //    if (die0.number == die1.number) doublesTimes++;
    //  }
      
    //  float fair = (float) 1 / Settings.DICE_RANDOM_RANGE;
    //  float fairness = (float) doublesTimes / iterations;
    //  println(fair, fairness);
      
    //  float accuracy = 1 - abs(1 - (fairness / fair));
    //  String str = str(int(10000 * accuracy));
    //  String accuracyPercent = new StringBuilder(str).insert(str.length() - 2, ".") + "%";
    //  println(accuracyPercent);
    //}
  }
  
  void manage() {
    update();
    display();
  }
  
  void update() {
    manageDice();
  }
  
  void display() {
    for (Physics.Box d : dice) ((Die) d).display();
  }
  
  // --
  
  void manageDice() {
    // ready to be picked up
    if (diceReady) {
      boolean noHeldPiece = (board.heldPiece == null) && (board.pieceToPickUp == null);
      boolean diceTapped = mouse.tap && mouse.inRange(hitboxCorners);
      
      if (noHeldPiece && diceTapped) {
        resetSpin();
        
        randomizeDoubles();
        
        physicsActive(true);
        
        diceReady = false;
        diceHeld = true;
      }
    }
    
    // picked up
    if (diceHeld) {
      boolean diceReleased = mouse.released || !mouse.pressed;
      // end holding
      if (diceReleased) {
        randomize(); // cheating precaution
        
        for (Physics.Box d : dice) {
          d.vel.mult(diceReleaseVelFactor);
        }
        
        diceHeld = false;
        diceBounce = true;
      }
      
      
      // holding
      else {
        // particles
        
        if (doublesMode) {
          field.addPreset(ParticlePreset.MAGICALS);
        }
        
        
        // dice
        
        ArrayList<PVector> easeVels = calculateSpunDiceVelocities();
        
        for (int i = 0; i < dice.size(); i++) {
          Die die = (Die) dice.get(i);
          
          PVector easeVel = easeVels.get(i);
          die.vel = easeVel.copy();
          
          die.update();
        }
      }
    }
    
    // bouncing around
    else if (diceBounce) {
      int diceFinished = 0;
      
      for (Physics.Box d : dice) {
        Die die = (Die) d;
        die.update();
        
        float velMag = die.vel.mag();
        if (velMag < diceBounceSlowVelThres) {
          if (velMag < diceReturnVelThres) diceFinished ++;
          else {
            die.vel.mult(diceBounceSlowFactor);
            
            die.rotVel *= diceBounceSlowFactor;
          }
        }
      }
      
      if (diceFinished == dice.size()) {
        physicsActive(false);
        resetEase();
        
        diceBounce = false;
        diceReturn = true;
      }
    }
    
    // dice returning to base
    if (diceReturn) {
      // ease
      if (diceReturnCountdown >= 0) {
        float easeX = 1 - ((float) diceReturnCountdown / diceReturnCountdownStart);
        float easeVal = diceReturnEase.apply(easeX);
        applyEase(easeVal);
        
        diceReturnCountdown --;
      }
      
      // ease finished
      else {
        //Die die0 = (Die) dice.get(0);
        //Die die1 = (Die) dice.get(1);
        
        //if (doublesMode) {
        //  if (die0.number != die1.number) println("!?!?!??!?!?!?!", die0.avoidNumber, die1.number, random(1));
        //  else println("doubles was good", die0.number, die1.number);
        //}
        
        //else {
        
        //  //if (die0.number == die1.number) println(flip, "??????????????????????????");
        //  if (die0.number == die1.number) println("!?!?!??!?!?!?!", die0.avoidNumber, die1.number, random(1));
        //  else println("avoid was good", die0.number, die1.number);
        //}
        
        //((Die) dice.get(0)).avoidNumber = -1;
        //((Die) dice.get(1)).avoidNumber = -1;
        
        doublesMode = false;
        
        diceReturn = false;
        diceReady = true;
      }
    }
  }
  
  ArrayList<PVector> calculateSpunDiceVelocities() {
    ArrayList<PVector> newVelocities = new ArrayList<PVector>();
    float spinDelta = TWO_PI / dice.size(); // spin difference between dice
    
    // calculate velocities
    PVector normVector = new PVector(1, 0);
    for (int i = 0; i < dice.size(); i++) {
      Physics.Box die = dice.get(i);
      
      float thisSpin = spin + (i * spinDelta);

      PVector mouseDelta = normVector.copy().rotate(thisSpin).setMag(spinDiceDist / 2);
      PVector newPos = PVector.add(mouse.pos, mouseDelta);
      newPos.x = constrain(newPos.x, board.corners[0].x, board.corners[1].x);
      newPos.y = constrain(newPos.y, board.corners[0].y, board.corners[1].y);
      
      PVector posDelta = PVector.sub(newPos, die.pos);
      PVector newVel   = posDelta.copy().mult(spinVelMagPercent);
      newVelocities.add(newVel);
    }
    
    // vel update
    spinVel += spinAcc;
    spinVel = min(spinVel, spinVelMax);
    
    // pos update
    spin += spinVel;
    spin %= TWO_PI;
    
    return newVelocities;
  }
  
  void resetSpin() {
    spin = 0;
    spinVel = spinVelStart;
  }
  
  void resetEase() {
    diceReturnStartPositions = new ArrayList<PVector>();
    diceReturnStartRotations = new FloatList();
    for (Physics.Box d : dice) {
      diceReturnStartPositions.add(d.pos.copy());
      diceReturnStartRotations.append(d.rot);
    }
    
    diceReturnCountdown = diceReturnCountdownStart;
  }
  
  void applyEase(float easeVal) {
    for (int i = 0; i < dice.size(); i++) {
      Physics.Box die = dice.get(i);
      
      // pos
      PVector startPos = diceReturnStartPositions.get(i);
      PVector endPos   = diceBasePositions.get(i);
      
      PVector newPos = lerpVector(easeVal, startPos, endPos);
      die.pos = newPos.copy();
      
      // rot
      float startRot = diceReturnStartRotations.get(i);
      float endRot = startRot > PI ? 0 : TWO_PI; // this is technically the reverse of what it ""should"" be
                                                 // (...but I like how the quick rotate looks)
      float newRot = lerp(startRot, endRot, easeVal);
      die.rot = newRot;
    }
  }
  
  void physicsActive(boolean active) {
    for (Physics.Box d : dice) d.physicsActive = active;
  }
  
  // --
  
  void randomize() {
    for (Physics.Box d : dice) ((Die) d).generateNumber();
  }
  
  void randomizeDoubles() {
    doublesMode = int(random(Settings.DICE_RANDOM_RANGE)) == 0;
  }
  
  //void enforceNumbers() {
  //  if (doublesMode) {
  //    Die die0 = (Die) dice.get(0);
  //    Die die1 = (Die) dice.get(1);
      
  //    die0.number = die1.number;
  //  }
    
  //  else {
  //    Die die0 = (Die) dice.get(0);
  //    Die die1 = (Die) dice.get(1);
      
  //    while (die1.number == die0.number) {
  //      die0.setRandomNumber();
  //    }
      
  //    //die0.avoidNumber = die1.number;
  //    //die1.avoidNumber = die0.number;
  //  }
  //}
} //<>//


class Die extends Physics.Box {
  DiePair parent;
  Die otherDie;
  
  int number = 1;
  
  color colFill, colStroke;
  float outlineSize, shapeRounding;
  
  boolean flip;
  int flipSign;
  
  // --
  
  PVector acc, vel_previous;
  float flipAccThres;
  
  Die(int _id, DiePair _parent, PVector _pos, float _size, boolean _flip, float _friction, ArrayList<Physics.Box> _allDice) {
    super(
      _id,
      _pos,
      new PVector(0, 0), // vel
      new PVector(_size, _size),
      0, 0, // rot, rotVel
      _friction,
      _allDice
    );
    physicsActive = false;
    
    parent = _parent;
    
    generateNumber();
    
    colFill = Palette.DICE;
    colStroke = Palette.DICE_OUTLINE;
    outlineSize = Settings.DICE_OUTLINE_PERCENT * size.x;
    
    shapeRounding = Settings.DICE_ROUNDING_PERCENT * size.x;
    
    flip = _flip;
    flipSign = flip ? -1 : 1;
    
    // --
    
    acc = new PVector(0, 0);
    vel_previous = vel.copy();
    
    flipAccThres = 0.1 * size.x; // this is a weird magic number, adjust with testing
  }
  
  void setOtherDie() {
    int otherDie_indexDelta = -(2 * (id % 2) - 1); // just go with it, it works
    otherDie = (Die) allBoxes.get(id + otherDie_indexDelta);
  }
  
  // --
  
  void update() {
    managePhysics();
    manageNumberFaces();
  }
  
  void display() {
    pushMatrix();
    
    translate(pos);
    rotate(rot);
    
    stroke(colStroke);
    strokeWeight(outlineSize);
    fill(colFill);
    
    rectCustomHere(size, shapeRounding);
    rotate(flipSign * HALF_PI);
    drawNumberFaces();
    
    popMatrix();
  }
  
  // --
  
  void drawNumberFaces() {
    float dot = 0.8; // diameter of dots
    float designScale = 0.5;
    
    designScale *= 1 - (outlineSize / size.x);
    PVector scaleVector = new PVector(size.x, size.y).mult(0.5 * designScale);
    PVector scaleVector_inverse = new PVector(1 / scaleVector.x, 1 / scaleVector.y);
    
    pushMatrix();
    scale(scaleVector); // make the range -1 to 1 (and scalable)
    
    noStroke();
    fill(0, 0, 0);
    switch(number) {
    case 1: {
      circle(0, 0, dot);
      
      break;
    }
    
    case 2: {
      circle(-1, -1, dot);
      circle(1, 1, dot);
      
      break;
    }
    
    case 3: {
      circle(-1, -1, dot);
      circle(0, 0, dot);
      circle(1, 1, dot);
      
      break;
    }

    case 4: {
      circle(-1, -1, dot);
      circle(-1, 1, dot);
      circle(1, -1, dot);
      circle(1, 1, dot);
      
      break;
    }

    case 5: {
      circle(-1, -1, dot);
      circle(-1, 1, dot);
      circle(1, -1, dot);
      circle(1, 1, dot);
      circle(0, 0, dot);
      
      break;
    }

    case 6: {
      circle(-1, -1, dot);
      circle(-1, 0, dot);
      circle(-1, 1, dot);
      circle(1, -1, dot);
      circle(1, 0, dot);
      circle(1, 1, dot);
      
      break;
    }

    case 7: {
      circle(-1, -1, dot);
      circle(-1, 0, dot);
      circle(-1, 1, dot);
      circle(1, -1, dot);
      circle(1, 0, dot);
      circle(1, 1, dot);
      circle(0, 0, dot);
      
      break;
    }

    case 8: {
      circle(-1, -1, dot);
      circle(-1, 0, dot);
      circle(-1, 1, dot);
      circle(1, -1, dot);
      circle(1, 0, dot);
      circle(1, 1, dot);
      circle(0, -1, dot);
      circle(0, 1, dot);
      
      break;
    }

    case 9: {
      circle(-1, -1, dot);
      circle(-1, 0, dot);
      circle(-1, 1, dot);
      circle(1, -1, dot);
      circle(1, 0, dot);
      circle(1, 1, dot);
      circle(0, -1, dot);
      circle(0, 1, dot);
      circle(0, 0, dot);
      
      break;
    }

      // --

    default: { // boring
        scale(scaleVector_inverse);
        textAlign(CENTER, CENTER);
        textSize(0.5 * size.x);
        text(number, 0, 0);
        
        break;
      }
    }
    
    popMatrix();
  }
  
  // --
  
  void manageNumberFaces() {
    acc = PVector.sub(vel_previous, vel);
    vel_previous = vel.copy();
    
    if (acc.mag() > flipAccThres) {
      generateNumber();
      vibrate(Settings.VIBRATE_AMOUNT_DICE_BOUNCE);
    }
  }
  
  // --
  
  int generateNumber() {
    number = getRandomNumber();
    
    // doubles
    if (parent.doublesMode) {
      otherDie.number = number;
    }
    
    // avoid other die's number
    else if (otherDie != null) while (number == otherDie.number) {
      number = getRandomNumber();
    }
    
    return number;
  }

  int getRandomNumber() {
    return ceil(random(Settings.DICE_RANDOM_RANGE));
  }
  
  //float testFairness(int iterations) {
  //  int count = 0;
  //  for (int i = 0; i < iterations; i++) {
  //    count += getRandomNumber() - 1;
  //  }
    
  //  float average = (float) count / iterations;
  //  float fairness = 2 * (average / Settings.DICE_RANDOM_RANGE); // this isn't accurate
    
  //  return fairness;
  //}
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
