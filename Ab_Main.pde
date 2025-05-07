// -- Imports --


//import java.util.function.Function; // Java 8 (not android - for the commented easing)
import java.lang.Object;

// android (UNCOMMENT ON ANDROID)
//import android.content.Context;
//import android.os.Vibrator;


// -- Global Vars --


int screenWidth, screenHeight;


// -- Main Methods --


// desktop testing (COMMENT ON MOBILE)
void settings() {
  // ipad air 11" M2
  //float screenRatio = 1.387; // w/h - portrait
  
  // iphone 15
  //float screenRatio = 2.062; // w/h - portrait
  
  // z flip 5
  float screenRatio = 2.445; // w/h - portrait
  
  // moto smthn (Ash)
  //float screenRatio = 21 / 9; // w/h - portrait
  
  // --
  
  float widthAdjustment = 0, heightAdjustment = 0;
  
  // ios dimensions adjustment (subtract)
  //widthAdjustment = 0.08;
  //heightAdjustment = 0;
  
  // android dimensions adjustment
  widthAdjustment = 0;
  heightAdjustment = 0.08;
  
  // --
  
  boolean landscape = true;
  
  // --
  
  screenRatio *= (1 - heightAdjustment) / (1 - widthAdjustment);
  screenHeight = 1500; // [landscape] decent size on laptop
  
  // --
  if (landscape) {
    screenRatio = 1 / screenRatio;
    screenHeight *= screenRatio;
  }
  
  screenWidth = int(screenHeight * (1 / screenRatio));
  size(screenWidth, screenHeight, P2D);
}


void setup() {
  // mobile (UNCOMMENT ON MOBILE) (optional ig: set orientation to landscape in export settings)
  //fullScreen(P2D);
  //screenWidth = width;
  //screenHeight = height;
  
  // --
  
  colorMode(HSB, 360, 100, 100, 255);
  
  configureMatrix();
  prepareBoard();
}


void draw() {
  // background
  background(0, 0, 0);
  
  // pre-matrix
  preMatrixBackground();
  
  // pre-draw
  mouse.setPosition();
  matrix.manage();
  mouse.manage();
  manageAndroid();
  
  // draw
  drawBoard();
}
