// -- Board PiecePool Classes --


class PiecePool {
  Board parent;
  
  PVector[] corners;
  PVector size;
  
  ArrayList<Piece> pieces;
  Piece pieceToPickUp;
  
  PiecePool(Board _parent, PVector[] _corners) {
    parent = _parent; int tfyguhbij;
    
    corners = _corners;
    size = getSizeFromCorners(corners);
    
    pieces = new ArrayList<Piece>();
    pieceToPickUp = null;
  }
  
  void manage() {
    managePieces();
  }
  
  //void debug() {
  //  // "hitboxes" debug
  //  if (mousePressed && mouseButton == RIGHT) {
  //    noFill();
  //    stroke(#00ffff);
  //    strokeWeight(1);
  //    rect(corners, 10);
  //  }
  //}
  
  // --
  
  void managePieces() {
    for (Piece p : pieces) {
      p.update();
      if (!p.sending) p.display(); // handled in parent (display over interactives)
    }
  }
  
  // --
  
  void pieceSelect(Piece pickedPiece) {
    parent.setPieceToPickUp(this, pickedPiece);
  }
  
  boolean receiveNewPiece(Piece newPiece) {
    newPiece.parent = this;
    
    addNewPiece(newPiece);
    return true;
  }
  
  void addNewPiece(Piece newPiece) {
    newPiece.parent = this;
    newPiece.canSelect = true;
    
    pieces.add(newPiece);
  }
  
  Piece createPiece(color col) {
    PVector newPiece_pos = getNextPiecePos();
    Piece newPiece = new Piece(this, newPiece_pos, col);
    
    addNewPiece(newPiece);
    newPiece.forceFinishSend();
    return newPiece;
  }
  
  boolean removePiece(Piece pieceToRemove) {
    String pieceUID = pieceToRemove.uid;
    for (int i = pieces.size() - 1; i >= 0; i--) {
      Piece p = pieces.get(i);
      
      if (p.uid == pieceUID) {
        pieces.remove(i);
        return true; // success
      }
    }
    
    return false; // failed
  }
  
  // --
  
  boolean pointInPool(PVector point) {
    return inRange(point, corners);
  }
  
  PVector getNextPiecePos() {
    float randomness = parent.outPiece_sendOutRandomness;
    
    float gauss = map(randomGaussian(), -1, 1, 0, randomness);
    gauss = constrain(gauss, 0, randomness - 1); // collision safety precaution (gauss is weird yknow)
    PVector randomDelta = PVector.random2D().setMag(gauss);
    
    PVector poolCenter = centerFromCorners(corners);
    PVector newPos = poolCenter.copy().add(randomDelta);
    
    return newPos;
  }
  
  color getColor(color defaultColor) {
    return defaultColor;
  }
  
  void setColor(color col) {}
  
  ArrayList<Piece> getReorderedPieces() {
    ArrayList<Piece> newPieces = new ArrayList<Piece>();
    ArrayList<Piece> sendingPieces = new ArrayList<Piece>();
    
    for (Piece p : pieces) {
      if (!p.sending) newPieces.add(p);
      else sendingPieces.add(p);
    }
    newPieces.addAll(sendingPieces);
    
    return newPieces;
  }
  
  void realignPieces() {
    pieces = getReorderedPieces();
  }
  
  void movePieceToEnd(Piece piece) {
    if (removePiece(piece)) pieces.add(piece);
  }
  
  boolean piecesNotMovingInPool(float thres) {
    boolean notMoving = true;
    for (Piece p : pieces) {
      boolean thresTest = p.sendPercent < thres;
      if (p.sending && thresTest) {
        notMoving = false;
      }
    }
    
    return notMoving;
  }
  
  int piecesOfColorInPool(color col) {
    int amount = 0;
    for (Piece p : pieces) {
      if (p.col == col) amount++;
    }
    
    return amount;
  }
}


class PiecePoolStack extends PiecePool {
  PVector posStackStart;
  int maxPieces;
  float stackSpacing, stackEdgePaddingX;
  
  boolean flip;
  int flipSign;
  
  color stackColor;
  
  float overflowFadeIn_percent;
  int overflowFadeIn_count, overflowFadeIn_countMax;
  
  PiecePoolStack(Board _parent, PVector[] _corners, boolean _flip, float stackWidth) {
    super(_parent, _corners); int trfygvuhb;
    
    stackEdgePaddingX = Settings.BOARD_SHELF_THIN_PERCENT * parent.size.x;
    
    flip = _flip;
    flipSign = flip ? -1 : 1;
    
    if (flip) posStackStart = corners[1].copy().sub(parent.pieceSize / 2, size.y / 2);
    else posStackStart = corners[0].copy().add(parent.pieceSize / 2, size.y / 2);
    
    maxPieces = Settings.PIECES_STACK_AMOUNT;
    stackSpacing = (stackWidth - parent.pieceSize) / (maxPieces - 1);
    
    overflowFadeIn_percent = 0;
    overflowFadeIn_count = 0;
    overflowFadeIn_countMax = Settings.PIECE_OVERFLOW_FADEIN_FRAMES;
  }
  
  @Override
  void manage() {
    managePieces();
    displayOverflowNumber();
    
    managePickups();
  }
  
  // --
  
  void managePickups() {
    if (pieces.size() >= 1) {
      Piece pieceToPickUp = pieces.get(pieces.size() - 1);
      
      if (mouse.tap && mouse.inRange(corners) && !pieceToPickUp.sending) {
        parent.setPieceToPickUp(this, pieceToPickUp, true);
      }
    }
  }
  
  // --
  
  @Override
  boolean receiveNewPiece(Piece newPiece) {
    return receiveNewPiece(newPiece, newPiece.heldLast);
  }
  
  boolean receiveNewPiece(Piece newPiece, boolean vibrateIfAccept) {
    boolean acceptPiece;
    
    // empty stack?
    if (pieces.size() == 0) acceptPiece = true;
    
    // same color?
    else if (newPiece.col == stackColor) acceptPiece = true;
    
    // only opposing piece in the stack?
    else if (pieces.size() == 1) {
      sendPieceOut();
      
      acceptPiece = true;
    }
    
    // reject
    else acceptPiece = false;
    
    // if accepted
    if (acceptPiece) {
      addNewPiece(newPiece, vibrateIfAccept);
    }
    
    return acceptPiece;
  }
  
  @Override
  void addNewPiece(Piece newPiece) {
    addNewPiece(newPiece, false);
  }
  
  void addNewPiece(Piece newPiece, boolean vibrate) {
    if (vibrate) vibrateOnce(Settings.VIBRATE_AMOUNT_PIECE_DROP);
    
    stackColor = newPiece.col;
    newPiece.parent = this;
    
    PVector newPiece_sendPos = getNextPiecePos();
    newPiece.sendToPos(newPiece_sendPos, Settings.ANIM_FRAMECOUNT_QUICK, Settings.ANIM_EASE_QUICK, false);
    
    newPiece.canSelect = false;
    newPiece.parent = this;
    pieces.add(newPiece);
  }
  
  void sendPieceOut() {
    Piece outPiece = pieces.get(0);
    pieces.remove(0);
    
    parent.getPieceOut(outPiece);
  }
  
  void displayOverflowNumber() {
    if (pieces.size() > maxPieces) {
      float thres = 0.96; // experimented through board resetting (farthest pool away)
      if (piecesNotMovingInPool(thres)) {
        overflowFadeIn_percent = (float) overflowFadeIn_count / overflowFadeIn_countMax;
        if (overflowFadeIn_count < overflowFadeIn_countMax) overflowFadeIn_count++;
      }
      
      else overflowFadeIn_count = max(overflowFadeIn_count - 1, 0);
      
      // --
      
      color reverseColor = stackColor == Palette.PIECE_LIGHT ? Palette.PIECE_DARK : Palette.PIECE_LIGHT;
      
      int movingPieces = 0;
      for (Piece p : pieces) movingPieces += p.sending ? 1 : 0;
      
      int overflowNumber = pieces.size() - maxPieces + 1 - movingPieces;
      
      if (overflowNumber > 1) {
        float alpha = 255 * overflowFadeIn_percent;
        
        pushMatrix();
        
        PVector translatePos = getNextPiecePos();
        translate(translatePos);
        rotate(flipSign * HALF_PI);
        
        fill(hue(reverseColor), saturation(reverseColor), brightness(reverseColor), alpha);
        noStroke();
        
        textAlign(CENTER, CENTER);
        textSize(parent.guiTextSize);
        text(overflowNumber, 0, 0);
        
        popMatrix();
      }
    }
  }
  
  @Override
  void realignPieces() {
    pieces = getReorderedPieces();
    
    for (int i = 0; i < pieces.size(); i++) {
      Piece piece = pieces.get(i);
      if (!piece.sending) piece.pos = getPiecePosByIndex(i);
      else piece.sentPos = getPiecePosByIndex(i);
    }
  }
  
  // --
  
  @Override
  PVector getNextPiecePos() {
    return getPiecePosByIndex(pieces.size());
  }
  
  PVector getPiecePosByIndex(int index) {
    int stackIndex = min(index, maxPieces - 1);
    float stackDeltaX = (stackEdgePaddingX + (stackIndex * stackSpacing)) * flipSign;
    
    PVector piecePos = posStackStart.copy().add(stackDeltaX, 0);
    return piecePos;
  }
  
  @Override
  color getColor(color defaultColor) {
    return stackColor;
  }
  
  @Override
  void setColor(color col) {
    stackColor = col;
  }
}


class PiecePoolHome extends PiecePoolStack {
  PiecePoolHome(Board _parent, PVector[] _corners, boolean _flip) {
    super(_parent, _corners, _flip, 1); // the "1" is a nothing number, it determines maxPieces which is irrelevant here
    
    stackEdgePaddingX = 0; // also irrelevant
    
    maxPieces = Settings.PIECES_PER_COLOR;
    stackSpacing = (size.x - parent.pieceSize) / (maxPieces - 1);
  }
  
  // --
  
  boolean receiveNewPiece(Piece newPiece, boolean vibrateOnAccept) {
    boolean acceptPiece;
    
    //empty stack?
    if (pieces.size() == 0) {
      stackColor = newPiece.col;
      acceptPiece = true;
    }
    
    // same color as stack?
    else acceptPiece = stackColor == newPiece.col;
    
    // if accept
    if (acceptPiece) addNewPiece(newPiece, vibrateOnAccept);
    return acceptPiece;
  }
}
