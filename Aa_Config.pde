   ////////////////////
//////////////////////////

/* +------------------+
   | BACKGAMMON v2.0a |
   |                  |
   | > PRESS PLAY     |
   +------------------+ */

//////////////////////////
   ////////////////////


// -- Config --


static class Settings {
  // mode
  static final int BOARD_SETUP_MODE = 0; // 0: Default
                                         // 1: ??? (not implemented, and it crashes)
  // screen
  static final float SCREEN_MIN_RATIO         = 2;    // to adjust for best scaling
  static final float SCREEN_SIDES_MIN_PERCENT = 0.12; // side gradients, percent of shorter screen dimension
  
  // saving
  static final String SAVING_FILENAME = "save.sav"; // saves all piecepools
  
  // board
  static final float BOARD_SHELF_THIN_PERCENT     = 0.01; // width percent
  static final float BOARD_SHELF_THICK_PERCENT    = 0.07; // height percent
  static final float BOARD_SHELF_MIDDLE_PERCENT   = 0.6;  // width percent
  static final int   BOARD_PILLARS_PER_SECTION    = 6;    // triangle pools/pillars per quadrant
  static final int   BOARD_SETUP_FRAMES_PER_PIECE = 3;    // amount of frames between each piece(s) sending loop (min 1...obviously)
  
  // matrix
  static final float MATRIX_DEFAULT_ROTATION = HALF_PI; // HALF_PI (landscape) or -HALF_PI (reverse landscape)
  
  // pieces
  static final float PIECE_TAP_RADIUS_PERCENT       = 1.2;     // "tappability" of a piece (factor to radius of possible selection)
  static final int   PIECES_PER_COLOR               = 15;      // only used for home spacing (+static reference), this doesn't determine the piece amount
  static final float PIECES_SIZE_PERCENT            = 1 / 4.4; // piece size as a percent of stackWidth (in PiecePoolStack constructor)
  static final int   PIECES_STACK_AMOUNT            = 5;       // for spacing between pieces (stacks on triangles)
  static final int   PIECE_UID_LENGTH               = 10;      // character length of a piece's UID (I don't know if UID is actually ever...um, used...but whatever it stays)
  static final float PIECE_SEND_PIXEL_THRES         = 1;       // distance to target position for sending to complete
  static final float PIECE_SEND_OUT_RANDOMNESS      = 0.3;     // float from 0 - 1 (low number is less random, higher number is more)
  static final int   PIECE_OVERFLOW_FADEIN_FRAMES   = 5;       // amount of frames it takes for the overflow indicator to fade in
  
  // dice
  static final float DICE_SIZE_ALLOCATION  = 0.65 * (1 - BOARD_SHELF_MIDDLE_PERCENT); // width percent
  static final float DICE_PADDING_PERCENT  = 0.02 * DICE_SIZE_ALLOCATION;             // width percent
  static final float DICE_SIZE_PERCENT     = 0.50 * DICE_SIZE_ALLOCATION;             // width percent
  static final float DICE_OUTLINE_PERCENT  = 0.12;                                    // dice size percent
  static final float DICE_ROUNDING_PERCENT = 0.20;                                    // dice size percent
  
  static final int   DICE_RANDOM_RANGE            = BOARD_PILLARS_PER_SECTION; // number of faces on dice
  static final float DICE_FRICTION                = 0.05;                      // amount of friction for all dice
  static final float DICE_DOUBLES_FRICTION_FACTOR = 0.5;                       // factor applied to friction when doubles happen
  
  // board reset button
  static final int   BOARDRESET_HOLD_FRAMES      = 90;                               // amount of holding frames required to reset
  static final float BOARDRESET_SIZE_PERCENT     = 0.65 * BOARD_SHELF_THICK_PERCENT; // height percent
  static final float BOARDRESET_OUTLINE_PERCENT  = DICE_OUTLINE_PERCENT;             // button size percent
  static final float BOARDRESET_ROUNDING_PERCENT = 0.10;                             // button size percent
  
  // progress bar
  static final float PROGRESSBAR_THIN_ALLOCATION = 1 - BOARD_SHELF_MIDDLE_PERCENT - DICE_SIZE_ALLOCATION; // width percent
  static final float PROGRESSBAR_THIN_PERCENT    = 0.08 * PROGRESSBAR_THIN_ALLOCATION;                    // width percent
  static final float PROGRESSBAR_LONG_PERCENT    = 0.850 * BOARD_SHELF_THICK_PERCENT;                      // height percent
  
  static final float PROGRESSBAR_ROUNDING_PERCENT = 0.50 * PROGRESSBAR_THIN_PERCENT; // width percent
  static final float PROGRESSBAR_OUTLINE_PERCENT  = 0.00 * PROGRESSBAR_THIN_PERCENT; // width percent
  
  // animations
  static final int  ANIM_FRAMECOUNT_QUICK  = 15; // i.e. when heldPiece snaps in place
  static final int  ANIM_FRAMECOUNT_FAST   = 35; // i.e. when a piece gets sent out
  static final int  ANIM_FRAMECOUNT_MEDIUM = 45; // i.e. auto setup
  static final int  ANIM_FRAMECOUNT_INOUT  = 50; // i.e. when dice return to base positions
  static final Ease ANIM_EASE_QUICK        = Ease.OUT_EXPO;    // see above
  static final Ease ANIM_EASE_FAST         = Ease.OUT_QUINT;   // ^^^^^^^^^
  static final Ease ANIM_EASE_MEDIUM       = Ease.OUT_CUBIC;   // ^^^^^^^^^
  static final Ease ANIM_EASE_INOUT        = Ease.INOUT_QUINT; // ^^^^^^^^^
  
  // particles
  static final float PARTICLE_MAGICAL_SIZE_PERCENT = 0.5 * DICE_SIZE_PERCENT; // width percent
  
  static final int   PARTICLE_SCOREGOOD_LIFESPAN = 90;
  static final int   PARTICLE_SCOREBAD_LIFESPAN  = 60;
  
  static final int   PARTICLE_SCOREGOOD_FX_AMOUNT = 50;
  static final int   PARTICLE_SCOREBAD_FX_AMOUNT  = 25;
  
  static final float PARTICLE_SCORE_TEXT_SIZE_PERCENT   = 0.8 * DICE_SIZE_PERCENT;  // width percent
  static final float PARTICLE_SCOREGOOD_FX_SIZE_PERCENT = 0.1 * DICE_SIZE_PERCENT;  // ^^^^^^^^^^^^^
  static final float PARTICLE_SCOREBAD_FX_SIZE_PERCENT  = 0.3 * DICE_SIZE_PERCENT;  // ^^^^^^^^^^^^^
  
  //static final int  PARTICLE_CONFETTI_AMOUNT_MAX  = 1000;          // max amount of confetti (max doubles)
  //static final Ease PARTICLE_CONFETTI_AMOUNT_EASE = Ease.IN_QUART; // ease to map amount of confetti
  
  
  // vibrate
  static final long VIBRATE_AMOUNT_PIECE_PICKUP = 40;  // when piece is picked up
  static final long VIBRATE_AMOUNT_PIECE_DROP   = 20;  // when piece is dropped in a color-alike or empty pool
  static final long VIBRATE_AMOUNT_PIECE_GETOUT = 100; // when piece gets out
  static final int  VIBRATE_DELAY_PIECE_GETOUT  = 8;   // ("GETOUT": "AMOUNT" is the amount to vibrate twice, "DELAY" is the frame delay between each)
  
  static final long VIBRATE_AMOUNT_DICE_BOUNCE = 40;
  
  static final long VIBRATE_AMOUNT_BOARDRESET_MIN = 5;
  static final long VIBRATE_AMOUNT_BOARDRESET_MAX = 15;
  
  // --
  
  // gradient (no longer necessary but it's part of the program forever ...)
  static final boolean TOP_GRADIENT_SHOW    = false;
  static final float   TOP_GRADIENT_PERCENT = 0.20;
}


static class Palette {
  static final color BACKGROUND         = #816944;
  static final color SHELF              = #664D26;
  static final color SHELF_DARK         = #47361b;
  static final color SHELF_DARKER       = #3d2f17;
  
  static final color PIECE_LIGHT        = #fff0bc;
  static final color PIECE_DARK         = #241c17;
  static final color PIECE_OUTLINE      = #000000;
  
  static final color PILLAR_LIGHT       = #bcab6b;
  static final color PILLAR_LIGHTER     = #e0d29f;
  static final color PILLAR_DARK        = #603626; // #3e2d24;
  static final color PILLAR_DARKER      = #42251A; // #241811;
  
  static final color DICE               = #ffffff;
  static final color DICE_OUTLINE       = #000000;
  
  static final color BOARDRESET_OUTLINE = #000000;
  
  static final color SCOREUP_TEXT       = #24FF8F;
  static final color SCOREUP_FX         = #88E8B7;
  static final color SCOREDOWN_TEXT     = #FA2D2D;
  static final color SCOREDOWN_FX       = #A20707;
  
  static final color PROGRESSBAR_LIGHT   = #FFFFFF;
  static final color PROGRESSBAR_PREVIEW = #A5A5A5;
  static final color PROGRESSBAR_DARK    = #000000;
  static final color PROGRESSBAR_OUTLINE = BOARDRESET_OUTLINE;
}


static class Constants {
  static final String ALPHANUMERALS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
}
