// -- Single Die --


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
  
  Die(int _id, DiePair _parent, PVector _pos, PVector[] _boundsCorners, float _size, boolean _flip, float _friction, ArrayList<Physics.Box> _allDice) {
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
    boundsCorners = _boundsCorners;
    
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
    
    flipAccThres = 0.1 * size.x; // amount of accel for die num to change (this is a weird magic number, adjust with testing)
  }
  
  void setOtherDie() {
    int otherDie_indexDelta = -(2 * (id % 2) - 1); // just go with it, it works
    otherDie = (Die) allBoxes.get(id + otherDie_indexDelta);
  }
  
  void setOtherDie(Physics.Box other) {
    otherDie = (Die) other;
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
    PVector scaleVector = new PVector(size.y, size.x).mult(0.5 * designScale);
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

    default: { // boring (it's just text)
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
      parent.setDiceNumbers(number);
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
}
