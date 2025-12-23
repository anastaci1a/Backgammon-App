// -- Misc Utils --


// android functions

boolean setVibrate = false;
boolean setVibrate_previous = false;

boolean setVibrateTwice = false;
boolean setVibrateTwice_previous = false;

int vibrateTwice_delayCount = -1;
long vibrateTwice_amountBuffer = 0;

void vibrateOnce(long amount) {
  if (!setVibrate_previous) {
    vibrate(amount);
  }
  setVibrate = true;
}

void vibrateTwice(long amount, int delay) {
  if (!setVibrateTwice_previous) {
    vibrate(amount);
  
    vibrateTwice_delayCount = delay;
    vibrateTwice_amountBuffer = amount;
  }
  setVibrateTwice = true;
}

void vibrate(long amount) {
  //((Vibrator) getContext().getSystemService(Context.VIBRATOR_SERVICE)).vibrate(amount); // UNCOMMENT ON ANDROID
  //// println("vibrating with amount " + str(amount)); // debug
}

void manageAndroid() {
  // "tap" system for vibrateOnce
  setVibrate_previous = setVibrate || false;
  setVibrate = false;
  
  // "tap" system for vibrateTwice
  setVibrateTwice_previous = setVibrateTwice || false;
  setVibrateTwice = false;
  
  // vibrateTwice countdown management
  if (vibrateTwice_delayCount != -1) {
    if (vibrateTwice_delayCount == 0) vibrate(vibrateTwice_amountBuffer);
    vibrateTwice_delayCount --;
  }
}


// drawing functions/classes

void vertex(PVector p) {
  vertex(p.x, p.y);
}

void translate(PVector p) {
  translate(p.x, p.y);
}

void scale(PVector s) {
  scale(s.x, s.y);
}

void circle(float x, float y, float d) {
  ellipse(x, y, d, d);
}

void circle(float d) {
  ellipseMode(CENTER);
  circle(0, 0, d);
}

void ellipseOutlined(PVector pos, float w, float h) {
  PGraphics g = getGraphics();
  
  boolean fillEnabled = g.fill;
  color fillColor = getGraphics().fillColor;
  boolean strokeEnabled = g.stroke;
  float strokeWeight = g.strokeWeight;
  color strokeColor = g.strokeColor;
  
  // main ellipse
  if (fillEnabled && strokeEnabled) {
    ellipseMode(CENTER);
    
    // outline
    noStroke();
    fill(strokeColor);
    ellipse(pos.x, pos.y, w, h);
    
    // fill
    fill(fillColor);
    ellipse(pos.x, pos.y, w - (2 * strokeWeight), h - (2 * strokeWeight));
  }
  
  // um
  else println("ellipseOutlined: you...you didn't make use of the ENTIRE purpose of this function...");
}

void rect(PVector[] corners) {
  rect(corners, 0);
}
void rect(PVector[] corners, float rounding) {
  rectMode(CORNERS);
  rect(corners[0].x, corners[0].y, corners[1].x, corners[1].y, rounding);
}

void rectCustomCorners(PVector[] corners) {
  rectCustomCorners(corners, 0);
}
void rectCustomCorners(PVector[] corners, float rounding) {
  PVector size = getSizeFromCorners(corners);
  rectCustom(corners[0], size, rounding);
}

void rectCustomHere(float size) {
  rectCustomHere(size, 0);
}
void rectCustomHere(PVector size) {
  rectCustomHere(size, 0);
}
void rectCustomHere(float size, float rounding) {
  PVector center = new PVector(0, 0);
  rectCustomCenter(center, size, rounding);
}
void rectCustomHere(PVector size, float rounding) {
  PVector center = new PVector(0, 0);
  rectCustomCenter(center, size, rounding);
}

void rectCustomCenter(PVector center, float size) {
  rectCustomCenter(center, size, 0);
}
void rectCustomCenter(PVector center, PVector size) {
  rectCustomCenter(center, size, 0);
}
void rectCustomCenter(PVector center, float _size, float rounding) {
  PVector size = new PVector(_size, _size);
  rectCustomCenter(center, size, rounding);
}
void rectCustomCenter(PVector center, PVector size, float rounding) {
  PVector topLeft = center.copy().sub(size.x / 2, size.y / 2);
  rectCustom(topLeft, size, rounding);
}

void rectCustom(PVector topLeft, float _size) {
  PVector size = new PVector(_size, _size);
  rectCustom(topLeft, size);
}
void rectCustom(PVector topLeft, PVector size) {
  rectCustom(topLeft, size, 0);
}
void rectCustom(PVector topLeft, PVector size, float _rounding) {
  PGraphics g = getGraphics();
  
  boolean fillEnabled = g.fill;
  color fillColor = getGraphics().fillColor; // unused
  boolean strokeEnabled = g.stroke;
  float strokeWeight = min(g.strokeWeight, min(size.x, size.y) / 2);
  color strokeColor = g.strokeColor;
  
  float rounding = min(_rounding, min(size.x, size.y) / 2);
  
  // normal
  if (fillEnabled) {
    noStroke();
    rectMode(CORNER);
    rect(topLeft.x, topLeft.y, size.x, size.y, rounding);
  }
  
  // outline
  if (strokeEnabled) {
    PVector[] fillCorners = new PVector[2];
    fillCorners[0] = topLeft.copy().add(strokeWeight, strokeWeight);
    fillCorners[1] = topLeft.copy().add(size).sub(strokeWeight, strokeWeight);
    
    float fillRounding = max(0, rounding - strokeWeight);
    //float fillRounding = rounding;
    
    //noStroke();
    
    // outline
    fill(strokeColor);
    rectMode(CORNER);
    rect(topLeft.x, topLeft.y, size.x, size.y, rounding);
    
    // fill
    fill(fillColor);
    rectMode(CORNERS);
    rect(fillCorners[0].x, fillCorners[0].y, fillCorners[1].x, fillCorners[1].y, fillRounding);
  }
}

class Shape {
  Shape() {}
  
  void display() {}
}

class Rect extends Shape {
  PVector[] corners;
  color fillColor, strokeColor;
  float strokeWeight, rounding;
  boolean stroke;
  
  Rect(PVector[] _corners, color _fillColor) {
    corners = _corners;
    fillColor = _fillColor;
    stroke = false;
    
    rounding = 0;
  }
  
  Rect(PVector[] _corners, color _fillColor, float _rounding) {
    corners = _corners;
    fillColor = _fillColor;
    stroke = false;
    
    rounding = _rounding;
  }
  
  Rect(PVector[] _corners, color _fillColor, color _strokeColor, float _strokeWeight) {
    corners = _corners;
    
    fillColor = _fillColor;
    stroke = true;
    strokeColor = _strokeColor;
    strokeWeight = _strokeWeight;
    
    rounding = 0;
  }
  
  Rect(PVector[] _corners, color _fillColor, color _strokeColor, float _strokeWeight, float _rounding) {
    corners = _corners;
    
    fillColor = _fillColor;
    stroke = true;
    strokeColor = _strokeColor;
    strokeWeight = _strokeWeight;
    
    rounding = _rounding;
  }
  
  @Override
  void display() {
    fill(fillColor);
    if (stroke) {
      stroke(strokeColor);
      strokeWeight(strokeWeight);
    } else noStroke();
    
    rectCustomCorners(corners, rounding);
  }
}

class Triangle extends Shape {
  PVector[] corners;
  PVector pos, size;
  
  color col, shadingCol;
  boolean flipX;
  
  Triangle(PVector[] _corners, color _col, boolean _flipX) {
    corners = _corners;
    col = _col;
    shadingCol = col;
    
    flipX = _flipX;
    
    pos = corners[0].copy();
    size = getSizeFromCorners(corners);
  }
  
  @Override
  void display() {
    pushMatrix();
    
    translate(pos);
    if (flipX) {
      translate(size.x, 0);
      scale(-1, 1);
    }
    
    noStroke();
    fill(col);
    beginShape();
    vertex(0, 0);
    fill(shadingCol);
    vertex(size.x, size.y / 2);
    vertex(0, size.y);
    endShape();
    
    popMatrix();
  }
}

class CustomShape extends Shape {
  PVector[] vertices;
  color[] colors;
  
  CustomShape(PVector[] _vertices, color[] _colors) {
    vertices = _vertices;
    colors = _colors;
  }
  
  @Override
  void display() {
    noStroke();
    beginShape();
    for (int i = 0; i < vertices.length; i++) {
      fill(colors[i]);
      vertex(vertices[i]);
    }
    endShape();
  }
}

class Gradient {
  PVector[] corners;
  color col;
  boolean show, rotateGradient;
  int recursions;
  
  Gradient(PVector[] _corners, color _col) {
    corners = _corners;
    col = _col;
    show = true;
    
    rotateGradient = false;
    recursions = 1;
  }
  
  Gradient(PVector[] _corners, color _col, boolean _show) {
    corners = _corners;
    col = _col;
    show = _show;
    
    rotateGradient = false;
    recursions = 1;
  }
  
  void display() {
    for (int i = 0; i < recursions; i++) {
      if (show) {
        noStroke();
        fill(hue(col), saturation(col), brightness(col), 0);
        
        beginShape();
        
        if (!rotateGradient) {
          vertex(corners[0]);                 // top left
          vertex(corners[1].x, corners[0].y); // top right
          fill(col);
          vertex(corners[1]);                 // bottom right
          vertex(corners[0].x, corners[1].y); // bottom left
        }
        
        else {
          vertex(corners[0]);                 // top left
          vertex(corners[0].x, corners[1].y); // bottom left
          fill(col);
          vertex(corners[1]);                 // bottom right
          vertex(corners[1].x, corners[0].y); // top right
        }
        
        endShape();
      }
    }
  }
}

void loadingAnimation(float percentComplete, PVector pos, float size, float outlineSize, float rotateFactor) {
  color col = color(0, 0, 100);
  loadingAnimation(percentComplete, pos, size, outlineSize, rotateFactor, col);
}

void loadingAnimation(float percentComplete, PVector pos, float size, float outlineSize, float rotateFactor, color col) {
  // percent calculations
  float weightForPercent = 0.95;
  float weightedPercent = map(percentComplete, 0, weightForPercent, 0, 1);
  
  // animation vars
  float arcStart  = 0;
  float arcEnd    = constrain(9 * weightedPercent, 0, TWO_PI);
  float radRotate = radians((15 * frameCount) % 360);
  
  // colors
  stroke(hue(col), saturation(col), brightness(col), 300 * weightedPercent);
  strokeWeight(outlineSize);
  noFill();
  
  // draw
  pushMatrix();
  translate(pos);
  rotate(radRotate);
  arc(0, 0, size, size, arcStart, arcEnd);
  popMatrix();
}


// misc

PVector getSizeFromCorners(PVector[] corners) {
  return corners[1].copy().sub(corners[0]);
}

String generateUID(int digits) {
  String UID = "";
  for (int i = 0; i < digits; i++) {
    int index = int(random(Constant.ALPHANUMERALS.length()));
    UID += Constant.ALPHANUMERALS.substring(index, index + 1);
  }
  
  return UID;
}

boolean fastUnderDist(PVector point1, PVector point2, float range) {
  float rangeSquared = range * range;
  float distSquared = pow(point2.x - point1.x, 2) + pow(point2.y - point1.y, 2);
  boolean inRange = distSquared < rangeSquared;
  
  return inRange;
}

boolean inRange(PVector point, PVector[] _range) {
  PVector[] range = normalizeCorners(_range);
  boolean isInside = (range[0].x <= point.x && point.x <= range[1].x) &&
                     (range[0].y <= point.y && point.y <= range[1].y);
  
  return isInside;
}

PVector[] normalizeCorners(PVector[] _range) {
  PVector[] range = new PVector[2];
  range[0] = new PVector(min(_range[0].x, _range[1].x), min(_range[0].y, _range[1].y));
  range[1] = new PVector(max(_range[0].x, _range[1].x), max(_range[0].y, _range[1].y));
  
  return range;
}

PVector lerpVector(float x, PVector p1, PVector p2) {
  PVector p1_add = p1.copy().mult(1 - x);
  PVector p2_add = p2.copy().mult(x);
  
  PVector result = PVector.add(p1_add, p2_add);
  return result;
}

PVector constrainVector(PVector vector, PVector[] _bounds) {
  PVector[] bounds = normalizeCorners(_bounds);
  
  PVector constrained = vector.copy();
  constrained.x = constrain(constrained.x, bounds[0].x, bounds[1].x);
  constrained.y = constrain(constrained.y, bounds[0].y, bounds[1].y);
  
  return constrained;
}

PVector centerFromCorners(PVector[] corners) {
  return PVector.add(corners[0], corners[1]).div(2);
}
