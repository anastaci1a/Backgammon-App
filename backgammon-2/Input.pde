// -- User Input --


Mouse mouse = new Mouse();

class Mouse {
  PVector pos, pos_previous, pos_change;
  float x, y, xPrev, yPrev, xChange, yChange;
  
  boolean tap, pressed, pPressed, released;
  
  // --
  
  float matrixRotation;
  
  Mouse() {
    pos          = new PVector(0, 0);
    pos_previous = new PVector(0, 0);
    pos_change   = new PVector(0, 0);
    
    x       = 0;
    y       = 0;
    xPrev   = 0;
    yPrev   = 0;
    xChange = 0;
    yChange = 0;
  }
  
  // --
  
  void setPosition() {
    // mouse position
    pos_previous = pos.copy();
    pos = getMousePosition();
  }
  
  void manage() {
    // mouse button
    pressed = mousePressed;
    tap = !pPressed && pressed;
    released = pPressed && !pressed;
    pPressed = pressed;
    
    // pos change
    pos_change = pos.copy().sub(pos_previous);
    if (tap) pos_change.setMag(0);
    
    // set basic vars
    x       = pos.x;
    y       = pos.y;
    xPrev   = pos_previous.x;
    yPrev   = pos_previous.y;
    xChange = pos_change.x;
    yChange = pos_change.y;
  }
  
  // --
  
  boolean belowDist(PVector point, float dist) {
    PVector tapPos = new PVector(pos.x, pos.y);
    return fastUnderDist(tapPos, point, dist);
  }
  
  boolean inRange(PVector[] _range) {
    PVector[] range = new PVector[2];
    range[0] = new PVector(min(_range[0].x, _range[1].x), min(_range[0].y, _range[1].y));
    range[1] = new PVector(max(_range[0].x, _range[1].x), max(_range[0].y, _range[1].y));
    
    boolean isInside = (range[0].x <= pos.x && pos.x <= range[1].x) &&
                       (range[0].y <= pos.y && pos.y <= range[1].y);
    
    return isInside;
  }
  
  PVector getMousePosition() {
    PVector mousePos = new PVector(mouseX, mouseY);
    
    // ... possible filtering if necessary (rotation ugh)
    
    return mousePos;
  }
}
