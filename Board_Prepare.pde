PImage starsBackground;
float  starsBackgroundScale;
Gradient[] gradients;

Board board;


void prepareBoard() {
  // background image
  starsBackground = loadImage("stars_hires.png");
  float starsBackgroundScaleX = (float) width / starsBackground.width;
  float starsBackgroundScaleY = (float) height / starsBackground.height;
  starsBackgroundScale = max(starsBackgroundScaleX, starsBackgroundScaleY);
  
  
  //gradients
  gradients = new Gradient[3];
  
  // gradient 0 (top old one, in config)
  float topGradientPercent = Settings.TOP_GRADIENT_SHOW ? Settings.TOP_GRADIENT_PERCENT : 0;
  float topGradientPixels = screenHeight * topGradientPercent;
  float gradientHeightBias = 1.1;
  
  PVector[] gradient_corners = new PVector[4];
  gradient_corners[0] = new PVector(0, 0);
  gradient_corners[1] = new PVector(screenWidth, topGradientPixels * gradientHeightBias);
  gradients[0] = new Gradient(gradient_corners, Palette.BACKGROUND, Settings.TOP_GRADIENT_SHOW);
  
  // gradient 1 ("left" - black)
  PVector[] leftGrad_corners = new PVector[2];
  leftGrad_corners[1] = new PVector(matrix.screenWidthDiscrepancy, screenHeight);
  leftGrad_corners[0] = new PVector(0, 0);
  Gradient leftGrad = new Gradient(leftGrad_corners, #000000);
  leftGrad.rotateGradient = true;
  leftGrad.recursions = 4;
  gradients[1] = leftGrad;
  
  // gradient 2 ("right" - white)
  PVector[] rightGrad_corners = new PVector[2];
  rightGrad_corners[0] = new PVector(screenWidth, 0);
  rightGrad_corners[1] = new PVector(screenWidth - matrix.screenWidthDiscrepancy, screenHeight);
  Gradient rightGrad = new Gradient(rightGrad_corners, #ffffff);
  rightGrad.rotateGradient = true;
  rightGrad.recursions = 2;
  gradients[2] = rightGrad;
  
  
  // board
  PVector[] board_corners = new PVector[2];
  board_corners[0] = new PVector(0, topGradientPixels);
  board_corners[1] = new PVector(screenWidth, screenHeight);
  board = new Board(board_corners);
  setupBoard(board);
  loadGame();
}


void preMatrixBackground() {
  // background image
  imageMode(CORNERS);
  image(starsBackground, 0, 0, starsBackgroundScale * starsBackground.width, starsBackgroundScale * starsBackground.height);
}


void drawBoard() {
  // instances
  for (Gradient g : gradients) g.display();
  board.manage();
}
