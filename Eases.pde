// -- Ease Functions --


// Java 7
enum Ease {
  LINEAR      { @Override float apply(float x) { return x; }},
  
  IN_SINE     { @Override float apply(float x) { return 1 - (float) Math.cos((x * (float) Math.PI) / 2); }},
  OUT_SINE    { @Override float apply(float x) { return (float) Math.sin((x * (float) Math.PI) / 2); }},
  INOUT_SINE  { @Override float apply(float x) { return -((float) Math.cos((float) Math.PI * x) - 1) / 2; }},
  
  IN_QUAD     { @Override float apply(float x) { return x * x; }},
  OUT_QUAD    { @Override float apply(float x) { return 1 - (1 - x) * (1 - x); }},
  INOUT_QUAD  { @Override float apply(float x) { return x < 0.5 ? 2 * x * x : 1 - (float) Math.pow(-2 * x + 2, 2) / 2; }},
  
  IN_CUBIC    { @Override float apply(float x) { return x * x * x; }},
  OUT_CUBIC   { @Override float apply(float x) { return 1 - (float) Math.pow(1 - x, 3); }},
  INOUT_CUBIC { @Override float apply(float x) { return x < 0.5 ? 4 * x * x * x : 1 - (float) Math.pow(-2 * x + 2, 3) / 2; }},
  
  IN_QUART    { @Override float apply(float x) { return x * x * x * x; }},
  OUT_QUART   { @Override float apply(float x) { return 1 - (float) Math.pow(1 - x, 4); }},
  INOUT_QUART { @Override float apply(float x) { return x < 0.5 ? 8 * x * x * x * x : 1 - (float) Math.pow(-2 * x + 2, 4) / 2; }},
  
  IN_QUINT    { @Override float apply(float x) { return x * x * x * x * x; }},
  OUT_QUINT   { @Override float apply(float x) { return 1 - (float) Math.pow(1 - x, 5); }},
  INOUT_QUINT { @Override float apply(float x) { return x < 0.5 ? 16 * x * x * x * x * x : 1 - (float) Math.pow(-2 * x + 2, 5) / 2; }},
  
  IN_EXPO     { @Override float apply(float x) { return x == 0 ? 0 : (float) Math.pow(2, 10 * x - 10); }},
  OUT_EXPO    { @Override float apply(float x) { return x == 1 ? 1 : 1 - (float) Math.pow(2, -10 * x); }},
  INOUT_EXPO  { @Override float apply(float x) { return x == 0 ? 0
                                                      : x == 1 ? 1
                                                      : x < 0.5 ? (float) Math.pow(2, 20 * x - 10) / 2
                                                      : (2 - (float) Math.pow(2, -20 * x + 10)) / 2; }},
  
  IN_CIRC     { @Override float apply(float x) { return 1 - (float) Math.sqrt(1 - (float) Math.pow(x, 2)); }},
  OUT_CIRC    { @Override float apply(float x) { return (float) Math.sqrt(1 - (float) Math.pow(x - 1, 2)); }},
  INOUT_CIRC  { @Override float apply(float x) { return x < 0.5 ? (1 - (float) Math.sqrt(1 - (float) Math.pow(2 * x, 2))) / 2
                                                     : ((float) Math.sqrt(1 - (float) Math.pow(-2 * x + 2, 2)) + 1) / 2; }},
  
  IN_BACK     { @Override float apply(float x) {
                                                final float c1 = 1.70158;
                                                final float c3 = c1 + 1;
                                                return c3 * x * x * x - c1 * x * x;
                                              }},
  OUT_BACK    { @Override float apply(float x) {
                                                final float c1 = 1.70158;
                                                final float c3 = c1 + 1;
                                                return 1 + c3 * (float) Math.pow(x - 1, 3) + c1 * (float) Math.pow(x - 1, 2);
                                              }},
  INOUT_BACK  { @Override float apply(float x) {
                                                final float c1 = 1.70158;
                                                final float c2 = c1 * 1.525;
                                                return x < 0.5
                                                  ? ((float) Math.pow(2 * x, 2) * ((c2 + 1) * 2 * x - c2)) / 2
                                                  : ((float) Math.pow(2 * x - 2, 2) * ((c2 + 1) * (x * 2 - 2) + c2) + 2) / 2;
                                              }};
  
  // --
  
  abstract float apply(float x);
}
  
  

// Java 8
//static class _Ease {
//  static final Function<Float, Float> LINEAR     = (x) -> x;
  
//  static final Function<Float, Float> IN_SINE     = (x) -> 1 - (float) Math.cos((x * (float) Math.PI) / 2);
//  static final Function<Float, Float> OUT_SINE    = (x) -> (float) Math.sin((x * (float) Math.PI) / 2);
//  static final Function<Float, Float> INOUT_SINE  = (x) -> -((float) Math.cos((float) Math.PI * x) - 1) / 2;
  
//  static final Function<Float, Float> IN_QUAD     = (x) -> x * x;
//  static final Function<Float, Float> OUT_QUAD    = (x) -> 1 - (1 - x) * (1 - x);
//  static final Function<Float, Float> INOUT_QUAD  = (x) -> x < 0.5 ? 2 * x * x : 1 - (float) Math.pow(-2 * x + 2, 2) / 2;
  
//  static final Function<Float, Float> IN_CUBIC    = (x) -> x * x * x;
//  static final Function<Float, Float> OUT_CUBIC   = (x) -> 1 - (float) Math.pow(1 - x, 3);
//  static final Function<Float, Float> INOUT_CUBIC = (x) -> x < 0.5 ? 4 * x * x * x : 1 - (float) Math.pow(-2 * x + 2, 3) / 2;
  
//  static final Function<Float, Float> IN_QUART    = (x) -> x * x * x * x;
//  static final Function<Float, Float> OUT_QUART   = (x) -> 1 - (float) Math.pow(1 - x, 4);
//  static final Function<Float, Float> INOUT_QUART = (x) -> x < 0.5 ? 8 * x * x * x * x : 1 - (float) Math.pow(-2 * x + 2, 4) / 2;
  
//  static final Function<Float, Float> IN_QUINT    = (x) -> x * x * x * x * x;
//  static final Function<Float, Float> OUT_QUINT   = (x) -> 1 - (float) Math.pow(1 - x, 5);
//  static final Function<Float, Float> INOUT_QUINT = (x) -> x < 0.5 ? 16 * x * x * x * x * x : 1 - (float) Math.pow(-2 * x + 2, 5) / 2;
  
//  static final Function<Float, Float> IN_EXPO     = (x) -> x == 0 ? 0 : (float) Math.pow(2, 10 * x - 10);
//  static final Function<Float, Float> OUT_EXPO    = (x) -> x == 1 ? 1 : 1 - (float) Math.pow(2, -10 * x);
//  static final Function<Float, Float> INOUT_EXPO  = (x) -> x == 0 ? 0
//                                                         : x == 1 ? 1
//                                                         : x < 0.5 ? (float) Math.pow(2, 20 * x - 10) / 2
//                                                         : (2 - (float) Math.pow(2, -20 * x + 10)) / 2;
  
//  static final Function<Float, Float> IN_CIRC     = (x) -> 1 - (float) Math.sqrt(1 - (float) Math.pow(x, 2));
//  static final Function<Float, Float> OUT_CIRC    = (x) -> (float) Math.sqrt(1 - (float) Math.pow(x - 1, 2));
//  static final Function<Float, Float> INOUT_CIRC  = (x) -> x < 0.5 ? (1 - (float) Math.sqrt(1 - (float) Math.pow(2 * x, 2))) / 2
//                                                         : ((float) Math.sqrt(1 - (float) Math.pow(-2 * x + 2, 2)) + 1) / 2;
  
//  static final Function<Float, Float> IN_BACK     = (x) -> {
//                                                            final float c1 = 1.70158;
//                                                            final float c3 = c1 + 1;
//                                                            return c3 * x * x * x - c1 * x * x;
//                                                          };
//  static final Function<Float, Float> OUT_BACK    = (x) -> {
//                                                            final float c1 = 1.70158;
//                                                            final float c3 = c1 + 1;
//                                                            return 1 + c3 * (float) Math.pow(x - 1, 3) + c1 * (float) Math.pow(x - 1, 2);
//                                                          };
//  static final Function<Float, Float> INOUT_BACK  = (x) -> {
//                                                            final float c1 = 1.70158;
//                                                            final float c2 = c1 * 1.525;
//                                                            return x < 0.5
//                                                              ? ((float) Math.pow(2 * x, 2) * ((c2 + 1) * 2 * x - c2)) / 2
//                                                              : ((float) Math.pow(2 * x - 2, 2) * ((c2 + 1) * (x * 2 - 2) + c2) + 2) / 2;
//                                                          };
//}
