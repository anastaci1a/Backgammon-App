// -- Board Class --


class Board {
  PVector[] corners;
  PVector center, size;
  
  ArrayList<Shape> drawnComponents;
  ArrayList<Interactive> interactives;
  ArrayList<PiecePool> piecePools;
  
  ArrayList<Piece> allPieces;
  ArrayList<Piece> blackPieces;
  ArrayList<Piece> whitePieces;
  int piecesPerColor;
  
  Piece pieceToPickUp;               // <-- pre-selection process for picking up pieces,
  PiecePool poolOfPieceToPickUp;     // <-- handled in Board so it's all in one place
  boolean pieceToPickUp_moveToMouse; // <--
  
  Piece heldPiece; // handled in Board so that the held piece is displayed above everything
  
  float pieceTapRadius; // set in configureBoard
  float pieceSize;
  float guiTextSize;
  
  HashMap<Integer, PiecePool> outPiece_pool; // out piece pools for respective colors
  float outPiece_sendOutRandomness;          // randomness applied to positions
  
  ArrayList<Piece> movingPieces; // pieces moving out (in these Piece instances, "sending" is true)
  ArrayList<Piece> lostPieces;   // pieces finished moving or no longer being held, not in a pool
  
  // --
  
  boolean setupBoard;
  int setupBoard_index, setupBoard_framesPerPiece;
  
  int[] setupBoard_mapOfBlack;
  int[] setupBoard_mapOfWhite;
  
  Board(PVector[] _corners) {
    corners = _corners;
    center = corners[0].copy().add(corners[1]).div(2);
    size = getSizeFromCorners(corners);
    
    drawnComponents = new ArrayList<Shape>();
    interactives = new ArrayList<Interactive>();
    piecePools = new ArrayList<PiecePool>();
    
    allPieces   = new ArrayList<Piece>();
    blackPieces = new ArrayList<Piece>();
    whitePieces = new ArrayList<Piece>();
    
    pieceToPickUp = null;
    poolOfPieceToPickUp = null;
    pieceToPickUp_moveToMouse = false;
    
    heldPiece = null;
    
    pieceTapRadius = 0;                                // <-- this is set in configureBoard (Board Setup)
    pieceSize = 0;                                     // <-- (these too)
    guiTextSize = 0;                                   // <--
    
    outPiece_pool = new HashMap<Integer, PiecePool>(); // <-- (and these)
    outPiece_sendOutRandomness = 0;                    // <--
    
    movingPieces = new ArrayList<Piece>();
    lostPieces = new ArrayList<Piece>();
    
    // --
    
    setupBoard = false;
    setupBoard_index = 0;
    setupBoard_framesPerPiece = Settings.BOARD_SETUP_FRAMES_PER_PIECE;
    
    setupBoard_mapOfBlack = null; // this is protected against
    setupBoard_mapOfWhite = null; // (the null values)
  }
  
  void manage() {
    manageBoardSetup();
    
    // --
    
    for (Shape s : drawnComponents) {
      s.display();
    }
    
    for (PiecePool pool : piecePools) {
      pool.manage();
      //pool.debug();
    }
    
    for (Interactive i : interactives) {
      i.manage();
    }
    
    // --
    
    manageMovingPieces();
    manageLostPieces();
    manageHeldPiece();
  }
  
  // --
  
  void manageMovingPieces() {
    // moving in pools (display over interactives)
    for (Piece p : allPieces) {
      if (p.sending) p.display();
    }
    
    // moving in movingPieces
    for (Piece p : movingPieces) {
      p.manage();
    }
    
    for (int i = movingPieces.size() - 1; i >= 0; i--) {
      Piece p = movingPieces.get(i);
      
      // piece finished moving
      if (!p.sending) {
        movingPieces.remove(i);
        lostPieces.add(p);
      }
    }
  }
  
  void manageLostPieces() {
    for (int i = lostPieces.size() - 1; i >= 0; i--) {
      Piece lostPiece = lostPieces.get(i);
      lostPiece.display();
      
      boolean poolFound = findPoolForLostPiece(lostPiece);
      
      // piece is no longer lost
      //if (poolFound) {} // nothing needs to be done here
      
      // no pool found, piece must go back to buffer position (moving)
      if (!poolFound) {
        PiecePool bufferPool = lostPiece.parent;
        
        boolean instanceofPiecePoolOriginal = !(bufferPool instanceof PiecePoolStack) && !(bufferPool instanceof PiecePoolHome);
        boolean canSelectAfterSend = instanceofPiecePoolOriginal;
        
        PVector sendBackPos = instanceofPiecePoolOriginal ? lostPiece.posPreHolding : bufferPool.getNextPiecePos().copy();
        
        sendPiece(lostPiece, sendBackPos, Settings.ANIM_FRAMECOUNT_QUICK, Settings.ANIM_EASE_QUICK, canSelectAfterSend);
      }
      
      // cleanup
      if (lostPiece.heldLast) {
        lostPiece.heldLast = false;
      }
      
      // in either circumstance the piece doesn't stay lost
      lostPieces.remove(i);
      
      // --
      
      // saving if no moving/lost pieces (and no held)
      
      boolean noLost = lostPieces.size() == 0;
      boolean noMoving = movingPieces.size() == 0;
      boolean noHeld = heldPiece == null;
      
      if (noLost && noMoving && noHeld) saveGame();
    }
  }
  
  void manageHeldPiece() { // heldPiece - step 3 (after this it goes through the lost pieces pipeline)
    // picking up pieces
    boolean pieceIsSelected = pieceToPickUp != null && poolOfPieceToPickUp != null;
    boolean noHeldPiece = (heldPiece == null);
    if (pieceIsSelected && noHeldPiece) {
      pieceHoldSelected();
    }
    
    // held piece exists
    if (heldPiece != null) {
      heldPiece.manage();
      
      // piece is no longer holding
      if (!heldPiece.holding) {
        heldPiece.heldLast = true;
        lostPieces.add(heldPiece);
        heldPiece = null;
      }
    }
  }
  
  // --
  
  void sendPiece(Piece pieceToSend, PVector sendPos, boolean canSelectAfterSend) { // pieceToMove has to be removed from the pool it may be in
    sendPiece(pieceToSend, sendPos, Settings.ANIM_FRAMECOUNT_FAST, Settings.ANIM_EASE_FAST, canSelectAfterSend);
  }
  
  void sendPiece(Piece pieceToSend, PVector sendPos, int sendFrames, Ease sendEase, boolean canSelectAfterSend) {
    pieceToSend.sendToPos(sendPos, sendFrames, sendEase, canSelectAfterSend);
    movingPieces.add(pieceToSend);
  }
  
  void setPieceToPickUp(PiecePool pool, Piece piece) { // heldPiece - step 1
    setPieceToPickUp(pool, piece, false);
  }
  
  void setPieceToPickUp(PiecePool pool, Piece piece, boolean moveToMouse) {
    pieceToPickUp = piece;
    poolOfPieceToPickUp = pool;
    pieceToPickUp_moveToMouse = moveToMouse;
  }
  
  void pieceHoldSelected() { // heldPiece - step 2
    heldPiece = pieceToPickUp;
    heldPiece.pickUp();
    poolOfPieceToPickUp.removePiece(pieceToPickUp);
    
    if (pieceToPickUp_moveToMouse) heldPiece.pos = mouse.pos.copy();
    
    pieceToPickUp = null;
    poolOfPieceToPickUp = null;
  }
  
  void getPieceOut(Piece outPiece) {
    PVector outPiecePos = getOutPiecePos(outPiece).copy();
    vibrateTwice(Settings.VIBRATE_AMOUNT_PIECE_GETOUT, Settings.VIBRATE_DELAY_PIECE_GETOUT);
    sendPiece(outPiece, outPiecePos, true);
  }
  
  boolean findPoolForLostPiece(Piece lostPiece) { // (true:  new pool was found and piece has been added; false: no pool was found and piece is still lost)
    PiecePool newPool = findPoolContainingPoint(lostPiece.pos);
    
    // new pool is found
    if (newPool != null) {
      return newPool.receiveNewPiece(lostPiece);
    } else return false;
  }
  
  PiecePool findPoolContainingPoint(PVector point) {
    PiecePool foundPool = null;
    for (PiecePool pool : piecePools) {
      if (pool.pointInPool(point)) {
        foundPool = pool;
        break;
      }
    }
    
    return foundPool;
  }
  
  int getPoolIndex(PiecePool pool) {
    for (int i = 0; i < piecePools.size(); i++) {
      if (pool == piecePools.get(i)) return i;
    }
    return -1;
  }
  
  // --
  
  PVector getOutPiecePos(Piece outPiece) {
    PiecePool errorPool = piecePools.get(0); // center if no match is found for color
    PiecePool outPool = outPiece_pool.getOrDefault(outPiece.col, errorPool);
    
    return outPool.getNextPiecePos();
  }
  
  void forceSendPieceToPool(Piece piece, PiecePool pool) {
    forceSendPieceToPool(piece, pool, Settings.ANIM_FRAMECOUNT_MEDIUM, Settings.ANIM_EASE_MEDIUM);
  }
  
  void forceSendPieceToPool(Piece piece, PiecePool pool, int frames, Ease ease) {
    if (piece.parent != pool) {
      
      // put piece at end of the stack, and realignment
      
      piece.sending = true;
      piece.parent.realignPieces();
      piece.pos = piece.sentPos == null ? piece.pos : piece.sentPos;
      piece.sending = false;
      piece.parent.removePiece(piece);
      piece.parent.realignPieces(); // <-- probs unnecessary but whatever it works
      
      // send out to new pos
      
      pool.addNewPiece(piece); // <-- the sending applied here is overwritten (the couple lines below this)
      
      PVector sendBackPos = pool.getNextPiecePos().copy();
      piece.sendToPos(sendBackPos, frames, ease, piece.canSelectAfterSend || piece.canSelect);
      pool.realignPieces();
    }
  }
  
  void evacuatePool(PiecePool pool) {
    for (int i = pool.pieces.size() - 1; i >= 0; i--) {
      Piece piece = pool.pieces.get(i);
      
      PVector evacLocation = getOutPiecePos(piece);
      PiecePool evacPool = findPoolContainingPoint(evacLocation);
      forceSendPieceToPool(piece, evacPool);
    }
    
    pool.pieces = new ArrayList<Piece>();
  }
  
  // --
  
  void initiateBoardSetup() {
    // maps init
    int[] mapOfBlack, mapOfWhite;
    
    // check piecepool L/R homes
    PiecePool homeLeft = piecePools.get(0);
    PiecePool homeRight = piecePools.get(1);
    boolean piecesInHomes = (homeLeft.pieces.size() + homeRight.pieces.size()) == 30;
    
    // send to homes
    if (!piecesInHomes) {
      // generatePiecePoolMaps output
      mapOfBlack = new int[] {
        15, 0
      };
      
      // generatePiecePoolMaps output
      mapOfWhite = new int[] {
        0, 15
      };
    }
    
    // set up maps (at first index OR if they aren't set)
    else switch(Settings.BOARD_PILLARS_PER_SECTION) {
      // generatePiecePoolMaps output
      case 3: {
        mapOfBlack = new int[] { 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 3, 0, 0, 5, 0, 0, 5 };
        mapOfWhite = new int[] { 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 3, 0, 5, 5, 0 };

        break;
      }
      
      // generatePiecePoolMaps output
      case 4: {
        mapOfBlack = new int[] { 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 3, 0, 0, 0, 0, 0, 0, 5, 0, 0, 5 };
        mapOfWhite = new int[] { 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 5, 5, 0 };

        break;
      }
      
      // generatePiecePoolMaps output
      case 5: {
        mapOfBlack = new int[] { 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 5 };
        mapOfWhite = new int[] { 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 5, 0 };

        break;
      }
      
      // generatePiecePoolMaps output
      case 6: {
        mapOfBlack = new int[] { 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 5 };
        mapOfWhite = new int[] { 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 5, 0 };
        
        break;
      }
      
      // generatePiecePoolMaps output
      case 7: {
        mapOfBlack = new int[] { 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 5 };
        mapOfWhite = new int[] { 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 5, 0 };

        break;
      }
      
      // generatePiecePoolMaps output
      case 8: {
        mapOfBlack = new int[] { 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 5 };
        mapOfWhite = new int[] { 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 5, 0 };

        break;
      }
      
      
// generatePiecePoolMaps output
      case 9: {
        mapOfBlack = new int[] { 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 5 };
        mapOfWhite = new int[] { 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 5, 0 };

        break;
      }
      
      // more...
      
      // --
      
      default: {
        setupBoard = false;
        setupBoard_index = 0;
        
        return;
      }
    }
    
    initializeBoardSetup(mapOfBlack, mapOfWhite);
    //generatePiecePoolMaps(true);
  }
  
  void initializeBoardSetup(int[] mapOfBlack, int[] mapOfWhite) {
    setupBoard = true;
    setupBoard_index = 0;
    
    setupBoard_mapOfBlack = mapOfBlack;
    setupBoard_mapOfWhite = mapOfWhite;
  }
  
  class BoardSetupPiece { // helper class
    color col;
    boolean placed = false;
    
    Piece instance;
    int[] map;
  }
  
  void manageBoardSetup() {
    if (setupBoard) {
      // loop condition
      int setupBoard_amountOfTimes = 2;
      int setupBoard_indexMax = setupBoard_amountOfTimes * setupBoard_framesPerPiece * piecesPerColor;
      
      // recall maps
      int[] mapOfBlack = setupBoard_mapOfBlack;
      int[] mapOfWhite = setupBoard_mapOfWhite;
      
      // pools info
      int amountOfPools = mapOfBlack.length;
      int poolIndex_max = piecesPerColor;
      
      // main logic
      if (setupBoard_index % setupBoard_framesPerPiece == 0) {
        // loop for making sure a piece is placed this "frame"
        //boolean blackPlaced = false;
        //boolean whitePlaced = false;
        
        boolean eitherPlaced = false;
        while (!eitherPlaced) {
          // pieces init
          int pieceIndex = (setupBoard_index / setupBoard_framesPerPiece) % poolIndex_max;
          
          BoardSetupPiece blackCurrent = new BoardSetupPiece();
          blackCurrent.col = Palette.PIECE_DARK;
          blackCurrent.instance = blackPieces.get(pieceIndex);
          blackCurrent.map = mapOfBlack;
          
          BoardSetupPiece whiteCurrent = new BoardSetupPiece();
          whiteCurrent.col = Palette.PIECE_LIGHT;
          whiteCurrent.instance = whitePieces.get(pieceIndex);
          whiteCurrent.map = mapOfWhite;
          
          boolean bothPlaced = false;
          
          // move pieces
          for (int col = 0; col < 2; col++) {
            for (int mapIndex = 0; mapIndex < amountOfPools; mapIndex++) {
              PiecePool pool = piecePools.get(mapIndex % piecePools.size());
              int poolAmount = pool.pieces.size();
              
              // pieces movement
              
              BoardSetupPiece piece = col == 0 ? blackCurrent : whiteCurrent; // set piece
              BoardSetupPiece otherPiece = col == 1 ? blackCurrent : whiteCurrent; // set piece
              
              if (!piece.placed) {
                int poolGoal = piece.map[mapIndex];
                
                // if there's other colored pieces
                boolean poolIsStack = pool instanceof PiecePoolStack || pool instanceof PiecePoolHome;
                if (poolIsStack && poolGoal > 0 && pool.getColor(piece.col) != piece.col) {
                  evacuatePool(pool);
                  pool.setColor(piece.col);
                }
                
                // if this pool needs help
                poolGoal += pool.piecesOfColorInPool(otherPiece.col); // account for multiple colors of pieces in free pools
                if (poolAmount < poolGoal) {
                  // already did its part here
                  if (piece.placed) break;
                  
                  // doing its part
                  else if (pool != piece.instance.parent) {
                    forceSendPieceToPool(piece.instance, pool);
                    piece.placed = true;
                  }
                }
              }
              
              // loop condition
              
              bothPlaced = blackCurrent.placed && whiteCurrent.placed;
              if (bothPlaced) break;
            } // end for
            
            if (bothPlaced) break;
          } // end for
          
          eitherPlaced = blackCurrent.placed || whiteCurrent.placed;
          
          boolean stillGoing = setupBoard_index < setupBoard_indexMax;
          if (!bothPlaced && stillGoing) setupBoard_index++;
          else break;
        } // end while
        
      } // end if
      
      // --
      
      // still going
      if (setupBoard_index < setupBoard_indexMax) setupBoard_index++;
      
      // finished setting up
      else {
        setupBoard = false;
        setupBoard_index = 0;
      }
    }
  }
  
  int[][] generatePiecePoolMaps() {
    return generatePiecePoolMaps(false);
  }
  
  int[][] generatePiecePoolMaps(boolean print) {
    int amountOfPools = piecePools.size();
    int[] mapOfBlack = new int[amountOfPools];
    int[] mapOfWhite = new int[amountOfPools];
    
    for (int i = 0; i < amountOfPools; i++) {
      int mapIndex = i;
      PiecePool pool = piecePools.get(i);
      
      mapOfBlack[mapIndex] = 0;
      mapOfWhite[mapIndex] = 0;
      
      boolean poolIsStack = pool instanceof PiecePoolStack || pool instanceof PiecePoolHome;
      if (poolIsStack) {
        if (pool.getColor(Palette.PIECE_DARK) == Palette.PIECE_DARK) {
          mapOfBlack[mapIndex] = pool.pieces.size();
        }
        
        else if (pool.getColor(Palette.PIECE_LIGHT) == Palette.PIECE_LIGHT) {
          mapOfWhite[mapIndex] = pool.pieces.size();
        }
      }
      
      else {
        for (Piece p : pool.pieces) {
          if (p.col == Palette.PIECE_DARK) mapOfBlack[mapIndex]++;
          else if (p.col == Palette.PIECE_LIGHT) mapOfWhite[mapIndex]++;
        }
      }
    }
    
    // output
    if (print) {
      String mapOfBlack_string = "        mapOfBlack = new int[] { ";
      String mapOfWhite_string = "        mapOfWhite = new int[] { ";
      for (int i = 0; i < amountOfPools; i++) {
        String endLine = i < amountOfPools - 1 ? ", " : " };";
        
        mapOfBlack_string += mapOfBlack[i] + endLine;
        mapOfWhite_string += mapOfWhite[i] + endLine;
      }
      
      println("\n---\n");
      println("      // generatePiecePoolMaps output");
      println("      case " + str(Settings.BOARD_PILLARS_PER_SECTION) + ": {");
      println(mapOfBlack_string + "\n" + mapOfWhite_string);
      println("\n        break;\n      }");
      println("\n---\n");
    }
    
    return new int[][] { mapOfBlack, mapOfWhite };
  }
}
