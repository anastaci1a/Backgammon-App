// -- Pair of Two Dice --


class DiePair {
  Board board;
  
  // --
  
  boolean flip;
  int flipSign;
  
  ArrayList<Physics.Box> dice;
  ArrayList<Physics.Box> allDice;
  
  ArrayList<PVector> diceBasePositions;
  PVector[] diceBounds;
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
    
    // dice bounds
    float diceBounds_paddingY = Settings.BOARD_SHELF_THICK_PERCENT * board.size.y;
    float diceBounds_paddingX = Settings.BOARD_SHELF_THIN_PERCENT * board.size.y;
    diceBounds = new PVector[2];
    diceBounds[0] = board.corners[0].copy().add(diceBounds_paddingX, diceBounds_paddingY);
    diceBounds[1] = board.corners[1].copy().sub(diceBounds_paddingX, diceBounds_paddingY);
    
    // top die
    PVector topDiePos = new PVector(diceX, board.center.y - diceDeltaY_half);
    diceBasePositions.add(topDiePos.copy());
    createDie(topDiePos);
    
    // bottom die
    PVector bottomDiePos = new PVector(diceX, board.center.y + diceDeltaY_half);
    diceBasePositions.add(bottomDiePos.copy());
    createDie(bottomDiePos);
    
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
  }
  
  Die createDie(PVector diePos) {
    Die die = new Die(
      allDice.size(),
      this,
      diePos,
      diceBounds,
      diceSize,
      flip,
      diceFriction,
      allDice
    );
    dice.add(die);
    allDice.add(die);
    
    return die;
  }
  
  // --
  
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
        
        if (doublesMode) addDoublesDice();
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
        
        diceReturnCountdown--;
      }
      
      // ease finished
      else {
        resetDoublesDice();
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
      PVector endPos   = diceBasePositions.get(i % 2); // diceBasePosition has size 2
      
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
  
  void addDoublesDice() {
    int diceSize = dice.size();
    
    int diceToAdd = 12;
    for (int i = 0; i < diceToAdd; i++) {
      int index = i % diceSize;
      Die d = (Die) dice.get(index);
      
      Die newDie = createDie(d.pos.copy());
      newDie.physicsActive = true;
      newDie.vel = d.vel.copy().rotate(HALF_PI);
      newDie.rot = d.rot;
      
      newDie.setOtherDie(d);
    }
    
    for (Physics.Box die : dice) die.friction *= Settings.DICE_DOUBLES_FRICTION_FACTOR;
  }
  
  void resetDoublesDice() {
    if (doublesMode) {
      // remove all local dice except starting pair
      int diceToRemove = dice.size() - 2;
      if (diceToRemove > 0) {
        for (int i = (2 + diceToRemove) - 1; i >= 2; i--) {
          Die localDie = (Die) dice.get(i);
          int localIndex = localDie.id;
          
          // remove die from dice list
          dice.remove(i);
          
          // remove die from allDice list
          for (int j = 0; j < allDice.size(); j++) {
            Die globalDie = (Die) allDice.get(j);
            int globalIndex = globalDie.id;
            
            if (globalIndex == localIndex) {
              allDice.remove(j);
              break;
            }
          }
        }
      }
      
      // reset slippery friction
      for (Physics.Box die : dice) die.friction /= Settings.DICE_DOUBLES_FRICTION_FACTOR;
    }
  }
  
  // --
  
  void randomize() {
    for (Physics.Box d : dice) ((Die) d).generateNumber();
  }
  
  void randomizeDoubles() {
    doublesMode = int(random(Settings.DICE_RANDOM_RANGE)) == 0;
  }
  
  void setDiceNumbers(int n) {
    for (Physics.Box die : dice) {
      ((Die) die).number = n;
    }
  }
}
