// -- Board Setup --


void setupBoard(Board b /* assumes board has been initialized */) {
  ArrayList<Shape> components = new ArrayList<Shape>();
  ArrayList<Interactive> interactives = new ArrayList<Interactive>();
  ArrayList<PiecePool> piecePools = new ArrayList<PiecePool>();
  
  // settings percentages in pixels
  float thinShelf = b.size.x * Settings.BOARD_SHELF_THIN_PERCENT;
  float thickShelf = b.size.y * Settings.BOARD_SHELF_THICK_PERCENT;
  
  // modes
  switch(Settings.BOARD_SETUP_MODE) {
    // default (normal board)
    case 0: {
      // -- magic numbers --
      
      
      // board generals
      float boardRounding_percent = 0.02;
      float pieceSize_percent   = Settings.PIECES_SIZE_PERCENT; // percent of max pillar height (piecePoolStack_collectionWidth)
      float guiTextSize_percent = 0.6;                          // percent of piece size
      
      // "quarries" (the little sunken in areas in real boards)
      float quarryWidth_percent = 0.8;
      float quarryHeight_percent = 0.6;
      float quarrySeparation_percent = 0.025;
      float quarryRounding_percent = 0.2;
      
      // middle piece pools
      float piecePoolsMiddle_widthPercent = 1.0; // percent of allocation
      
      // "pillars" (triangles)
      int   pillarAmountPerSection = Settings.BOARD_PILLARS_PER_SECTION;
      float pillarWidth_percent = 0.45;
      float pillarSection_edgePaddingY_percent = 0.03;
      float pillarSection_middlePaddingY_percent = 0.01;
      float pillarHeight_custom = 0.75; // float from 0 - 1 (factor of max pillar height (pillarAllocation): 0 = zero height, 1 = max height)
      float pillarStackWidth_percentOfMax = 0.99;
      
      
      // -- interpreting the magic numbers --
      
      
      // quarries
      
      float quarryWidth = quarryWidth_percent * b.size.x;
      float quarryHeight = quarryHeight_percent * thickShelf;
      float quarrySeparation = quarrySeparation_percent * b.size.x;
      float quarryWidthPadding = ((b.size.x - quarryWidth) / 2) - quarrySeparation;
      float quarryHeightPadding = (thickShelf - quarryHeight) / 2;
      
      float quarryMiddleWidth = Settings.BOARD_SHELF_MIDDLE_PERCENT * b.size.x;
      float quarryMiddleWidthPadding = (b.size.x - quarryMiddleWidth) / 2;
      
      float quarryRounding = quarryRounding_percent * quarryHeight;
      
      
      PVector[] quarryLeft_cornersDelta = new PVector[2];
      quarryLeft_cornersDelta[0] = new PVector(quarryWidthPadding, quarryHeightPadding);                 // top left
      quarryLeft_cornersDelta[1] = quarryLeft_cornersDelta[0].copy().add(quarryWidth / 2, quarryHeight); // bottom right
      
      PVector[] quarryRight_cornersDelta = new PVector[2];
      quarryRight_cornersDelta[0] = new PVector(b.center.x + (quarrySeparation / 2), quarryHeightPadding);                            // top left
      quarryRight_cornersDelta[1] = quarryRight_cornersDelta[0].copy().add((quarrySeparation / 2) + (quarryWidth / 2), quarryHeight); // bottom right
      
      PVector[] quarryMiddle_cornersDelta = new PVector[2];
      quarryMiddle_cornersDelta[0] = new PVector(quarryMiddleWidthPadding, quarryHeightPadding);               // top left
      quarryMiddle_cornersDelta[1] = quarryMiddle_cornersDelta[0].copy().add(quarryMiddleWidth, quarryHeight); // bottom right
      
      
      // pillars
      
      float pillarSectionHeight_beforePadding = b.center.y - (1.5 * thickShelf) - b.corners[0].y;
      float pillarSectionEdgePadding = pillarSection_edgePaddingY_percent * pillarSectionHeight_beforePadding;
      float pillarSectionMiddlePadding = pillarSection_middlePaddingY_percent * pillarSectionHeight_beforePadding;
      float pillarSectionFullPadding = pillarSectionEdgePadding + pillarSectionMiddlePadding;
      float pillarSectionHeight = pillarSectionHeight_beforePadding - pillarSectionFullPadding;
      
      float pillarWidth = pillarWidth_percent * b.size.x;
      float pillarAllocation = pillarSectionHeight / pillarAmountPerSection; // basically max pillar height, no y spacing
      float pillarHeight = pillarHeight_custom * pillarAllocation;
      PVector pillarSize = new PVector(pillarWidth, pillarHeight);
      
      float pillarLeftPadding = thinShelf;
      float pillarTopAdjustment = (pillarAllocation - pillarHeight) / 2;
      
      float pillarRight_deltaX = b.size.x - (2 * thinShelf) - pillarWidth; // this is weird just go with it
                                                                           // (the "2 * thinShelf" part is to cancel out pillarLeftPadding)
      PVector pillarTop_posDelta = new PVector(pillarLeftPadding, thickShelf + pillarTopAdjustment + pillarSectionEdgePadding);
      PVector pillarBottom_posDelta = new PVector(pillarLeftPadding, b.center.y + (thickShelf / 2) + pillarTopAdjustment + pillarSectionMiddlePadding - b.corners[0].y);
      
      float piecePoolStack_collectionHeightDelta = (pillarAmountPerSection * (pillarAllocation - pillarHeight)) / pillarAmountPerSection; // total padding (top + bottom) of individual pillars (to make up for pillarHeight_custom)
      float piecePoolStack_collectionWidth = pillarStackWidth_percentOfMax * (b.center.x - thinShelf); // fed to all PiecePoolStack instances (pools of pillars) for positional calculations
      
      
      // board generals
      
      float boardRounding = boardRounding_percent * b.size.y;
      
      //b.pieceSize = pieceSize_percent * pillarAllocation;
      b.pieceSize = piecePoolStack_collectionWidth * pieceSize_percent;
      b.pieceTapRadius = (Settings.PIECE_TAP_RADIUS_PERCENT * b.pieceSize) / 2;
      
      b.guiTextSize = guiTextSize_percent * b.pieceSize;
      
      
      // middle piece pools
      
      float boardReset_size = Settings.BOARDRESET_SIZE_PERCENT * b.size.y;
      float boardReset_allocation = boardReset_size + (0.6 * b.pieceSize); // just so pieces don't overlap the reset button
      
      float piecePoolsMiddle_fullWidthAllocation = (quarryMiddleWidth - boardReset_allocation) / 2;
      
      float piecePoolsMiddle_width = piecePoolsMiddle_widthPercent * piecePoolsMiddle_fullWidthAllocation;
      float piecePoolsMiddle_paddingX = (1 - piecePoolsMiddle_widthPercent) * piecePoolsMiddle_fullWidthAllocation;
      
      PVector piecePoolsMiddle_size = new PVector(piecePoolsMiddle_width, thickShelf);
      
      PVector piecePoolsMiddle_topLeft = b.center.copy().sub((boardReset_allocation / 2) + piecePoolsMiddle_paddingX + piecePoolsMiddle_size.x, piecePoolsMiddle_size.y / 2);
      PVector piecePoolsMiddle_leftRightDelta = new PVector(piecePoolsMiddle_size.x + boardReset_allocation + (2 * (piecePoolsMiddle_paddingX)), 0);
      
      PVector[] piecePoolsMiddleLeft_corners = new PVector[2];
      piecePoolsMiddleLeft_corners[0] = piecePoolsMiddle_topLeft.copy();
      piecePoolsMiddleLeft_corners[1] = PVector.add(piecePoolsMiddleLeft_corners[0], piecePoolsMiddle_size);
      
      PVector[] piecePoolsMiddleRight_corners = new PVector[2];
      piecePoolsMiddleRight_corners[0] = PVector.add(piecePoolsMiddleLeft_corners[0], piecePoolsMiddle_leftRightDelta);
      piecePoolsMiddleRight_corners[1] = PVector.add(piecePoolsMiddleLeft_corners[1], piecePoolsMiddle_leftRightDelta);
      
      
      // out piece config
      
      float piecePoolsMiddle_shorterSide = min(piecePoolsMiddle_size.x, piecePoolsMiddle_size.y);
      b.outPiece_sendOutRandomness = (Settings.PIECE_SEND_OUT_RANDOMNESS * piecePoolsMiddle_shorterSide) / 2;
      
      
      // -- the actual board config --
      
      
      // board basics
      
      // board base
      Rect boardBase = new Rect(b.corners, Palette.SHELF);
      components.add(boardBase);
      
      // board internal section
      PVector boardInternalSize = new PVector(b.size.x - (thinShelf * 2), b.size.y - (thickShelf * 2));
      PVector[] boardInternalSection_corners = new PVector[2];
      boardInternalSection_corners[0] = new PVector(b.corners[0].x + thinShelf, b.corners[0].y + thickShelf); // top left
      boardInternalSection_corners[1] = boardInternalSection_corners[0].copy().add(boardInternalSize);        // bottom right
      Rect boardInternalSection = new Rect(boardInternalSection_corners, Palette.BACKGROUND, boardRounding);
      components.add(boardInternalSection);
      
      
      // top
      
      // top shelf
      PVector[] topShelf_corners = new PVector[2];
      topShelf_corners[0] = b.corners[0].copy();                           // top left
      topShelf_corners[1] = b.corners[0].copy().add(b.size.x, thickShelf); // bottom right
      Rect topShelf = new Rect(topShelf_corners, Palette.SHELF);
      components.add(topShelf);
      
      // top left quarry
      PVector[] topLeftQuarry_corners = new PVector[2];
      topLeftQuarry_corners[0] = b.corners[0].copy().add(quarryLeft_cornersDelta[0]); // top left
      topLeftQuarry_corners[1] = b.corners[0].copy().add(quarryLeft_cornersDelta[1]); // bottom right
      Rect topLeftQuarry = new Rect(topLeftQuarry_corners, Palette.SHELF_DARK, quarryRounding);
      components.add(topLeftQuarry);
      
      // top left quarry shading
      PVector[] topLeftQuarryShading_corners = new PVector[2];
      topLeftQuarryShading_corners[0] = topLeftQuarry_corners[0].copy(); // top left
      topLeftQuarryShading_corners[1] = topLeftQuarry_corners[1].copy(); // bottom right
      topLeftQuarryShading_corners[0].y = (topLeftQuarryShading_corners[0].y + topLeftQuarryShading_corners[1].y) / 2;
      Rect topLeftQuarryShading = new Rect(topLeftQuarryShading_corners, Palette.SHELF_DARKER, quarryRounding);
      components.add(topLeftQuarryShading);
      
      // top right quarry
      PVector[] topRightQuarry_corners = new PVector[2];
      topRightQuarry_corners[0] = b.corners[0].copy().add(quarryRight_cornersDelta[0]); // top left
      topRightQuarry_corners[1] = b.corners[0].copy().add(quarryRight_cornersDelta[1]); // bottom right
      Rect topRightQuarry = new Rect(topRightQuarry_corners, Palette.SHELF_DARK, quarryRounding);
      components.add(topRightQuarry);
      
      // top right quarry shading
      PVector[] topRightQuarryShading_corners = new PVector[2];
      topRightQuarryShading_corners[0] = topRightQuarry_corners[0].copy(); // top left
      topRightQuarryShading_corners[1] = topRightQuarry_corners[1].copy(); // bottom right
      topRightQuarryShading_corners[0].y = topLeftQuarryShading_corners[0].y;
      Rect topRightQuarryShading = new Rect(topRightQuarryShading_corners, Palette.SHELF_DARKER, quarryRounding);
      components.add(topRightQuarryShading);
      
      // top left piece pool home
      PVector[] topLeftPiecePool_corners = new PVector[2];
      topLeftPiecePool_corners[0] = topLeftQuarryShading_corners[0].copy();
      topLeftPiecePool_corners[1] = topLeftQuarryShading_corners[1].copy();
      topLeftPiecePool_corners[0].y = topShelf_corners[0].y;
      topLeftPiecePool_corners[1].y = topShelf_corners[1].y;
      PiecePool topLeftPiecePool = new PiecePoolHome(b, topLeftPiecePool_corners, false);
      piecePools.add(topLeftPiecePool);
      
      // top right piece pool home
      PVector[] topRightPiecePool_corners = new PVector[2];
      topRightPiecePool_corners[0] = topRightQuarry_corners[0].copy();
      topRightPiecePool_corners[1] = topRightQuarry_corners[1].copy();
      topRightPiecePool_corners[0].y = topShelf_corners[0].y;
      topRightPiecePool_corners[1].y = topShelf_corners[1].y;
      PiecePool topRightPiecePool = new PiecePoolHome(b, topRightPiecePool_corners, true);
      piecePools.add(topRightPiecePool);
      
      
      // middle
      
      // middle shelf
      PVector[] middleShelf_corners = new PVector[2];
      middleShelf_corners[0] = new PVector(0, b.center.y).copy().sub(0, thickShelf / 2); // top left
      middleShelf_corners[1] = middleShelf_corners[0].copy().add(b.size.x, thickShelf);  // bottom right
      Rect middleShelf = new Rect(middleShelf_corners, Palette.SHELF);
      components.add(middleShelf);
      
      // middle shelf accent line
      //PVector[] middleShelfAccent_corners = new PVector[2];
      //middleShelfAccent_corners[0] =  new PVector(0, b.center.y).copy().sub(0, thinShelf / 2);     // top left
      //middleShelfAccent_corners[1] = middleShelfAccent_corners[0].copy().add(b.size.x, thinShelf); // bottom right
      //Rect middleShelfAccent = new Rect(middleShelfAccent_corners, Palette.SHELF_DARK);
      //components.add(middleShelfAccent);
      
      // middle quarry
      PVector[] middleQuarry_corners = new PVector[2];
      middleQuarry_corners[0] = middleShelf_corners[0].copy().add(quarryMiddle_cornersDelta[0]); // top left
      middleQuarry_corners[1] = middleShelf_corners[0].copy().add(quarryMiddle_cornersDelta[1]); // bottom right
      Rect middleQuarry = new Rect(middleQuarry_corners, Palette.SHELF_DARK, quarryRounding);
      components.add(middleQuarry);
      
      // middle quarry shading
      PVector[] middleQuarryShading_corners = new PVector[2];
      middleQuarryShading_corners[0] = middleQuarry_corners[0].copy(); // top left
      middleQuarryShading_corners[1] = middleQuarry_corners[1].copy(); // bottom right
      middleQuarryShading_corners[0].y = (middleQuarryShading_corners[0].y + middleQuarryShading_corners[1].y) / 2;
      Rect middleQuarryShading = new Rect(middleQuarryShading_corners, Palette.SHELF_DARKER, quarryRounding);
      components.add(middleQuarryShading);
      
      // middle piece pool free
      PiecePool middleLeftPiecePool = new PiecePool(b, piecePoolsMiddleLeft_corners);
      PiecePool middleRightPiecePool = new PiecePool(b, piecePoolsMiddleRight_corners);
      piecePools.add(middleLeftPiecePool);
      piecePools.add(middleRightPiecePool);
      
      // out piece piecepools config
      b.outPiece_pool.put(Palette.PIECE_LIGHT, middleLeftPiecePool);
      b.outPiece_pool.put(Palette.PIECE_DARK, middleRightPiecePool);
      
      
      // bottom
      
      // bottom shelf
      PVector[] bottomShelf_corners = new PVector[2];
      bottomShelf_corners[0] = b.corners[1].copy().sub(b.size.x, thickShelf); // top left
      bottomShelf_corners[1] = b.corners[1].copy();                           // bottom right
      Rect bottomShelf = new Rect(bottomShelf_corners, Palette.SHELF);
      components.add(bottomShelf);
      
      // bottom left quarry
      PVector[] bottomLeftQuarry_corners = new PVector[2];
      bottomLeftQuarry_corners[0] = bottomShelf_corners[0].copy().add(quarryLeft_cornersDelta[0]); // top left
      bottomLeftQuarry_corners[1] = bottomShelf_corners[0].copy().add(quarryLeft_cornersDelta[1]); // bottom right
      Rect bottomLeftQuarry = new Rect(bottomLeftQuarry_corners, Palette.SHELF_DARK, quarryRounding);
      components.add(bottomLeftQuarry);
      
      // bottom left quarry shading
      PVector[] bottomLeftQuarryShading_corners = new PVector[2];
      bottomLeftQuarryShading_corners[0] = bottomLeftQuarry_corners[0].copy(); // top left
      bottomLeftQuarryShading_corners[1] = bottomLeftQuarry_corners[1].copy(); // bottom right
      bottomLeftQuarryShading_corners[0].y = (bottomLeftQuarryShading_corners[0].y + bottomLeftQuarryShading_corners[1].y) / 2;
      Rect bottomLeftQuarryShading = new Rect(bottomLeftQuarryShading_corners, Palette.SHELF_DARKER, quarryRounding);
      components.add(bottomLeftQuarryShading);
      
      // bottom right quarry
      PVector[] bottomRightQuarry_corners = new PVector[2];
      bottomRightQuarry_corners[0] = bottomShelf_corners[0].copy().add(quarryRight_cornersDelta[0]); // top left
      bottomRightQuarry_corners[1] = bottomShelf_corners[0].copy().add(quarryRight_cornersDelta[1]); // bottom right
      Rect bottomRightQuarry = new Rect(bottomRightQuarry_corners, Palette.SHELF_DARK, quarryRounding);
      bottomRightQuarry.rounding = quarryRounding;
      components.add(bottomRightQuarry);
      
      // bottom right quarry shading
      PVector[] bottomRightQuarryShading_corners = new PVector[2];
      bottomRightQuarryShading_corners[0] = bottomRightQuarry_corners[0].copy(); // top left
      bottomRightQuarryShading_corners[1] = bottomRightQuarry_corners[1].copy(); // bottom right
      bottomRightQuarryShading_corners[0].y = bottomLeftQuarryShading_corners[0].y;
      Rect bottomRightQuarryShading = new Rect(bottomRightQuarryShading_corners, Palette.SHELF_DARKER, quarryRounding);
      components.add(bottomRightQuarryShading);
      
      // bottom left piece pool home
      PVector[] bottomLeftPiecePool_corners = new PVector[2];
      bottomLeftPiecePool_corners[0] = bottomLeftQuarry_corners[0].copy();
      bottomLeftPiecePool_corners[1] = bottomLeftQuarry_corners[1].copy();
      bottomLeftPiecePool_corners[0].y = bottomShelf_corners[0].y;
      bottomLeftPiecePool_corners[1].y = bottomShelf_corners[1].y;
      PiecePool bottomLeftPiecePool = new PiecePoolHome(b, bottomLeftPiecePool_corners, false);
      piecePools.add(bottomLeftPiecePool);
      
      // bottom right piece pool home
      PVector[] bottomRightPiecePool_corners = new PVector[2];
      bottomRightPiecePool_corners[0] = bottomRightQuarry_corners[0].copy();
      bottomRightPiecePool_corners[1] = bottomRightQuarry_corners[1].copy();
      bottomRightPiecePool_corners[0].y = bottomShelf_corners[0].y;
      bottomRightPiecePool_corners[1].y = bottomShelf_corners[1].y;
      PiecePool bottomRightPiecePool = new PiecePoolHome(b, bottomRightPiecePool_corners, true);
      piecePools.add(bottomRightPiecePool);
      
      
      // "inner sections" (triangle pillar stuffs)
      
      // main piece pools & pillars
      for (int i = 0; i < pillarAmountPerSection; i++) {
        for (int j = 0; j < 2; j++) {   // left/right
          for (int k = 0; k < 2; k++) { // top/bottom
            // pillar position setup
            PVector[] pillar_corners = new PVector[2];
            pillar_corners[0] = b.corners[0].copy().add(0, i * pillarAllocation); // top left
            if (j == 1) pillar_corners[0].x += pillarRight_deltaX;
            if (k == 0) pillar_corners[0].add(pillarTop_posDelta);
            else pillar_corners[0].add(pillarBottom_posDelta);
            pillar_corners[1] = pillar_corners[0].copy().add(pillarSize);         // bottom right
            
            // visuals setup
            int colorSelect = (i + j) % 2; // color oscillation
            color col = colorSelect == 0 ? Palette.PILLAR_DARK : Palette.PILLAR_LIGHTER;
            color shadingCol = colorSelect == 0 ? Palette.PILLAR_DARKER : Palette.PILLAR_LIGHT;
            boolean flip = j == 1;
            
            // pillar triangle
            Triangle pillarTriangle = new Triangle(pillar_corners, col, flip);
            pillarTriangle.shadingCol = shadingCol;
            components.add(pillarTriangle);
            
            
            // piece pool position setup
            PVector[] pillarPiecePool_corners = new PVector[2];
            if (j == 0) { // left
              pillarPiecePool_corners[0] = pillar_corners[0].copy();
              pillarPiecePool_corners[0].x = b.corners[0].x;
              pillarPiecePool_corners[1] = pillar_corners[1].copy();
              pillarPiecePool_corners[1].x = b.size.x / 2;
            } else {      // right
              pillarPiecePool_corners[0] = pillar_corners[0].copy();
              pillarPiecePool_corners[0].x = b.corners[0].x + (b.size.x / 2);
              pillarPiecePool_corners[1] = pillar_corners[1].copy();
              pillarPiecePool_corners[1].x = b.corners[0].x + (b.size.x);
            }
            pillarPiecePool_corners[0].sub(0, piecePoolStack_collectionHeightDelta / 2);
            pillarPiecePool_corners[1].add(0, piecePoolStack_collectionHeightDelta / 2);
            
            // pillar piece pool
            PiecePool pillarPiecePool = new PiecePoolStack(b, pillarPiecePool_corners, flip, piecePoolStack_collectionWidth);
            piecePools.add(pillarPiecePool);
          }
        }
      }
      
      
      // interactives
      
      // reset button
      BoardReset boardReset = new BoardReset(b, b.center.copy());
      interactives.add(boardReset);
      
      // left and right dice pairs
      DiePairPair diePairPair = new DiePairPair(b);
      interactives.add(diePairPair);
      
      
      // piece setup
      
      // board default state (15 per color in their respective homes)
      b.piecesPerColor = 15;
      ArrayList<Piece> allPieces = new ArrayList<Piece>();
      ArrayList<Piece> blackPieces = new ArrayList<Piece>();
      ArrayList<Piece> whitePieces = new ArrayList<Piece>();
      
      PiecePool[] poolsToGrow = new PiecePool[2];
      poolsToGrow[0] = topLeftPiecePool;
      poolsToGrow[1] = topRightPiecePool;
      for (int i = 0; i < b.piecesPerColor; i++) {
        for (int j = 0; j < poolsToGrow.length; j++) {
          color col = j % 2 == 0 ? Palette.PIECE_DARK : Palette.PIECE_LIGHT;
          
          Piece newPiece = poolsToGrow[j].createPiece(col);
          
          allPieces.add(newPiece);
          (j % 2 == 0 ? blackPieces : whitePieces).add(newPiece);
        }
      }
      
      // give piece arrays to board
      b.allPieces = allPieces;
      b.blackPieces = blackPieces;
      b.whitePieces = whitePieces;
      
      
      break;
    }
    
    
    // ?????
    case 1: {
      // ...
      
      break;
    }
  }
  
  // apply to board instance
  b.drawnComponents.addAll(components);
  b.interactives.addAll(interactives);
  b.piecePools.addAll(piecePools);
}
