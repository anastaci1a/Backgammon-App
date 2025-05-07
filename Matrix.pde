CustomMatrix matrix;
void configureMatrix() {
  float defaultRotation = Settings.MATRIX_DEFAULT_ROTATION;

  matrix = new CustomMatrix(defaultRotation);
}


class CustomMatrix {
  boolean rotate;
  float rotateAmount;
  
  float screenWidthDiscrepancy;

  CustomMatrix(float _rotateAmount) {
    rotate = screenWidth > screenHeight;
    
    rotateAmount = -_rotateAmount;
    
    screenWidthDiscrepancy = 0;
    
    while (rotateAmount < 0) rotateAmount += TWO_PI;
    rotateAmount %= TWO_PI;

    if (rotate) {
      float halfPiRotations = int(rotateAmount / HALF_PI);
      if (halfPiRotations % 2 == 1) {
        int screenWidth_buffer = screenWidth;

        screenWidth = screenHeight;
        screenHeight = screenWidth_buffer;
      }
    }
    
    // --
    
    int newScreenWidth = int(min(
      screenHeight / Settings.SCREEN_MIN_RATIO,
      screenWidth - (screenWidth * Settings.SCREEN_SIDES_MIN_PERCENT)
    ));
    
    screenWidthDiscrepancy = newScreenWidth - screenWidth;
    screenWidth = newScreenWidth;
  }

  // --

  void manage() {
    if (rotate) {
      matrixTranslate(width / 2, height / 2);
      matrixRotate(rotateAmount);
      matrixTranslate(-height / 2, -width / 2);
    }
      
    if (screenWidthDiscrepancy != 0) {
      matrixTranslate(-screenWidthDiscrepancy / 2, 0);
    }
  }

  void matrixTranslate(float x, float y) {
    translate(x, y);
    
    mouse.pos.sub(x, y);
  }

  void matrixRotate(float rad) {
    rotate(rad);
    
    mouse.pos.rotate(-rad);
  }
  
  void matrixScale(float x, float y) {
    scale(x, y);
    
    mouse.pos.x /= x;
    mouse.pos.y /= y;
  }
}
