class Piece {
  PiecePool parent;
  String uid;
  
  PVector pos;
  float pieceSize;
  color col;
  
  boolean show, canSelect, canSelectAfterSend;
  boolean holding, heldLast, holding_previousFrame;
  boolean holdingStarted;
  
  boolean sending, undoSend;
  PVector sentPos, sendingStartPos;
  int sendCountdown, sendCountdownStart;
  Ease sendingEase;
  float sendPercent;
  
  PVector posPreHolding;
  
  Piece(PiecePool _parent, PVector _pos, color _col) {
    parent = _parent;
    uid = generateUID(Settings.PIECE_UID_LENGTH);
    
    pos = _pos.copy();
    
    pieceSize = parent.parent.pieceSize;
    col = _col;
    
    show = true;
    canSelect = false;
    canSelectAfterSend = false;
    
    holding = false;
    heldLast = false; // for differentiating a recently held piece from regular moving pieces (in Board class)
    holding_previousFrame = false;
    
    sending = false;
    undoSend = false;
    sentPos = null;
    sendCountdownStart = 0;
    sendCountdown = -1;
    sendPercent = 1;
    
    posPreHolding = pos;
  }
  
  void manage() {
    update();
    if (show) display();
  }
  
  void update() {
    // sending (no user control)
    if (sending) {
      if (sendCountdown == 0) {
        pos = sentPos.copy();
        
        sendCountdownStart = 0;
        sendCountdown = -1;
        
        sending = false;
        canSelect = canSelectAfterSend;
      } else {
        sendPercent = 1 - ((float) sendCountdown / sendCountdownStart);
        float easeVal = sendingEase.apply(sendPercent);
        PVector newPos = lerpVector(easeVal, sendingStartPos, sentPos);
      
        pos = newPos.copy();
        
        sendCountdown--;
      }
    }
    
    // not sending (user control - if enabled)
    else {
      // holding
      if (holding && parent.parent.heldPiece == this) { // note: when holding, the "parent" reference is no longer accurate- the real holder of `this` is the Board instance with heldPiece
        pos.add(mouse.pos_change);
        holding = !mouse.released && mouse.pressed;
      }
      
      // not holding
      else if (!holding) {
        // pre holding buffer
        posPreHolding = pos.copy();
        
        // selecting enabled
        if (canSelect) {
          if (mouse.tap && mouse.belowDist(pos, parent.parent.pieceTapRadius)) {
            parent.pieceSelect(this);
          }
        }
      }
      
      // released (this frame)
      boolean released = !holding && holding_previousFrame;
      if (released) {
        pos = constrainVector(pos, parent.parent.corners);
      }
    }
    
    // --
    
    holding_previousFrame = holding;
  }
  
  void display() {
    drawPiece(pos, pieceSize, col);
  }
  
  // --
  
  void pickUp() {
    holding = true;
    vibrate(Settings.VIBRATE_AMOUNT_PIECE_PICKUP);
  }
  
  void sendToPos(PVector _sentPos, int _sendCountdown, Ease _sendingEase, boolean _canSelectAfterSend) {
    sending = true;
    canSelect = false;
    
    canSelectAfterSend = _canSelectAfterSend;
    
    sentPos = _sentPos.copy();
    sendCountdownStart = _sendCountdown;
    sendCountdown = sendCountdownStart;
    
    sendingEase = _sendingEase;
    
    sendingStartPos = pos.copy();
  }
  
  void forceFinishSend() {
    if (sending) {
      pos = sentPos.copy();
      
      sendCountdownStart = 0;
      sendCountdown = -1;
      
      sending = false;
      canSelect = canSelectAfterSend;
    }
  }
}

void drawPiece(PVector pos, float size, color col) {
  fill(col);
  stroke(Palette.PIECE_OUTLINE);
  strokeWeight(size / 8);
  ellipseOutlined(pos, size, size);
}

void drawPieceShadow(PVector pos, float baseSize, PVector perspectivePoint, float maxDist, float lift /* between 0-1, higher is farther */) { // [UNUSED]
  float perspectiveFactor = 1.08;
  PVector deltaCenter = perspectivePoint.copy().sub(pos).mult(perspectiveFactor);
  
  PVector shadowPos = perspectivePoint.copy().sub(deltaCenter);
  float rot = deltaCenter.heading() + HALF_PI;
  float scaleY = map(deltaCenter.mag(), 0, maxDist, 1, 1.25);
  float size = map(deltaCenter.mag(), 0, maxDist, 0.95 * baseSize, 1.35 * baseSize);
  
  
  // closeness adjustment
  
  size = map(lift, 0, 1, 1, size);
  scaleY = map(lift, 0, 1, 1, scaleY);
  
  
  // displaying
  
  float alpha = map(deltaCenter.mag(), 0, maxDist, 180, 0);
  fill(0, 0, 0, alpha);
  noStroke();
  
  pushMatrix();
  translate(shadowPos);
  rotate(rot);
  scale(1, scaleY);
  
  ellipse(0, 0, size, size);
  
  popMatrix();
}
