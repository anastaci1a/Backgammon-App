class ParticleField {
  ArrayList<Particle> particles;
  
  ParticleField() {
    particles = new ArrayList<Particle>();
  }
  
  void manage() {
    for (int i = particles.size() - 1; i >= 0; i--) {
      Particle p = particles.get(i);
      if (p.dead) particles.remove(i);
      else p.manage();
    }
  }
  
  // --
  
  void addPreset(ParticlePreset preset, Object... args) {
    ArrayList<Particle> particlesToAdd = getParticlePreset(preset, args);
    addParticles(particlesToAdd);
  }
  
  void addParticles(ArrayList<Particle> particlesToAdd) {
    ArrayList<Particle> newParticles = new ArrayList<Particle>();
    
    newParticles.addAll(particlesToAdd);
    newParticles.addAll(particles);
    
    particles = newParticles;
  }
}

class Particle {
  PVector pos, vel;
  float rot, rotVel;
  
  float size;
  color col;
  PVector scale;
  
  int lifespan, life;
  boolean dead;
  
  Particle() {
    pos = new PVector(0, 0);
    vel = new PVector(0, 0);
    
    rot = 0;
    rotVel = 0;
    
    size = 1;
    col = color(0, 0, 0);
    scale = new PVector(1, 1);
    
    lifespan = 0;
    life = lifespan;
  }
  
  Particle(PVector _pos, PVector _vel, float _rot, float _rotVel, int _lifespan) {
    pos = _pos.copy();
    vel = _vel.copy();
    
    rot = _rot;
    rotVel = _rotVel;
    
    size = 10;
    col = color(random(360), 100, 100);
    scale = new PVector(1, 1);
    
    lifespan = _lifespan;
    life = lifespan;
  }
  
  void manage() {
    update();
    display();
  }
  
  void update() {
    pos.add(vel);
    rot += rotVel;
    
    dead = life-- <= 0;
  }
  
  void display() {
    pushMatrix();
    translate(pos);
    rotate(rot);
    scale(scale);
    
    drawParticle();
    
    popMatrix();
  }
  
  // --
  
  void drawParticle() {
    float lifeLeftAsPercent = (float) life/lifespan;
    color alphaCol = color(hue(col), saturation(col), brightness(col), alpha(col) * lifeLeftAsPercent);
    
    noStroke();
    fill(alphaCol);
    
    circle(size);
  }
}


enum ParticlePreset {
  MAGICALS,
  SCORE_INDICATOR // REQUIRED args: PVector position, float textSize, boolean flip, int number
}

ArrayList<Particle> getParticlePreset(ParticlePreset preset, Object... args) {
  ArrayList<Particle> particles = new ArrayList<Particle>();
  
  // --
  
  switch (preset) {
    case MAGICALS: {
      int amount = int(random(10));
      for (int i = 0; i < amount; i++) {
        ParticleMagical magical = new ParticleMagical();
        particles.add(magical);
      }
      
      return particles;
    }
    
    case SCORE_INDICATOR: {
      PVector pos = new PVector();
      boolean flip = false;
      int number = 0;
      
      boolean argsSuccess = true;
      try {
        pos      = (PVector) args[0];
        flip     = (Boolean) args[1];
        number   = (Integer) args[2];
      } catch (Exception e) {
        println("getParticlePreset's args could not be parsed.");
        
        argsSuccess = false;
      }
      
      if (argsSuccess) {
        boolean good = number > 0;
        
        // init vars
        
        color fxCol      =  good ? Palette.SCOREUP_FX                          : Palette.SCOREDOWN_FX;
        int   fxLifespan =  good ? Settings.PARTICLE_SCOREGOOD_LIFESPAN        : Settings.PARTICLE_SCOREBAD_LIFESPAN;
        float fxSize     = (good ? Settings.PARTICLE_SCOREGOOD_FX_SIZE_PERCENT : Settings.PARTICLE_SCOREBAD_FX_SIZE_PERCENT) * board.size.x;
        int   fxAmount   =  good ? Settings.PARTICLE_SCOREGOOD_FX_AMOUNT       : Settings.PARTICLE_SCOREBAD_FX_AMOUNT;
        
        float fxVel_mult = (good ? 0.2 : 0.01) * fxSize;
        
        // number particle
        
        float scoreTextSize = Settings.PARTICLE_SCORE_TEXT_SIZE_PERCENT * board.size.x;
        
        Particle particleScore = new ParticleScore(pos, scoreTextSize, flip, number, fxLifespan);
        particles.add(particleScore);
        
        // fx particles (little circles)
        
        for (int i = 0; i < fxAmount; i++) {
          Particle fx = new Particle(
            pos.copy().add(PVector.random2D().mult(random(2) * fxSize)), // pos
            PVector.random2D().mult(random(1) * fxVel_mult),             // vel
            0, 0,                                                        // rot, rotVel
            round(fxLifespan * random(0.1, 0.8))                         // lifespan
          );
          
          fx.col  = fxCol;
          fx.size = fxSize;
          
          particles.add(fx);
        }
      }
      
      return particles;
    }
    
    // --
    
    default: return particles;
  }
}


class ParticleMagical extends Particle {
  float hue;
  String text;
  
  ParticleMagical() {
    super(
      mouse.pos.copy(),              // pos
      PVector.random2D(),            // vel
      random(TWO_PI),                // rot
      (HALF_PI / 3) * random(-1, 1), // rotVel
      round(random(20, 50))          // lifespan
    );
    
    size = Settings.PARTICLE_MAGICAL_SIZE_PERCENT * board.size.x;
    
    PVector posDelta = PVector.random2D().setMag(random(1.5 * size));
    pos.add(posDelta);
    
    vel.setMag(random(0, size / 5));
    
    hue = random(360);
    text = str(ceil(random(Settings.DICE_RANDOM_RANGE)));
  }
  
  // --
  
  @Override
  void drawParticle() {
    hue = (hue + 5) % 360;
    float alpha = 255 * ((float) life / lifespan);
    col = color(hue, 60, 100, alpha);
    fill(col);
    
    textSize(size);
    textAlign(CENTER, CENTER);
    text(text, 0, 0);
  }
}


class ParticleScore extends Particle {
  String text;
  float textSize;
  color col;
  
  ParticleScore(PVector _pos, float _textSize, boolean flip, int number, int _lifespan) {
    super(
      _pos,                            // pos
      new PVector(0, 0),               // vel
      flip ? PI + HALF_PI : HALF_PI,   // rot
      (HALF_PI / 500) * random(-1, 1), // rotVel
      _lifespan                        // lifespan
    );
    
    boolean good = number > 0;
    //if (good) rotVel = 0; // (no rotation if negative score)
    
    /*              | positive score           | negative score        */
    text     = good ? str(number)              : "– " + str(abs(number));
    col      = good ? Palette.SCOREUP_TEXT     : Palette.SCOREDOWN_TEXT;
    
    textSize = _textSize;
  }
  
  @Override
  void drawParticle() {
    float lifeLeftAsPercent = (float) life/lifespan;
    lifeLeftAsPercent = Ease.OUT_CUBIC.apply(lifeLeftAsPercent);
    
    color alphaCol = color(hue(col), saturation(col), brightness(col), alpha(col) * lifeLeftAsPercent);
    
    noStroke();
    fill(alphaCol);
    
    textAlign(CENTER, CENTER);
    textSize(textSize);
    text(text, 0, 0);
  }
}


//class ParticleConfetti extends Particle {
//  float somersault;
  
//  ParticleConfetti(boolean flip) {
//    super();
    
//    float diceSize = Settings.DICE_SIZE_PERCENT * board.size.x;
//    size = diceSize * Settings.PARTICLE_MAGICAL_SIZE_PERCENT;
//    size = diceSize / 2;
    
//    boolean vFlip = random(1) > 0.5;
    
//    pos = new PVector(screenWidth, screenHeight).mult(0.5); // center
//    PVector deltaPos = new PVector(screenWidth / 4, (screenHeight / 2) + size / 2);
//  }
//}

//ArrayList<Particle> createConfetti(int strength, boolean flip) {
//  ArrayList<Particle> particles = new ArrayList<Particle>();
  
//  float strengthNormalized = map(strength, 1, Settings.DICE_RANDOM_RANGE, 0, 1);
//  Ease amountEase = Settings.PARTICLE_CONFETTI_AMOUNT_EASE;
//  float amount = amountEase.apply(strengthNormalized) * Settings.PARTICLE_CONFETTI_AMOUNT_MAX;
  
//  for (int i = 0; i < amount; i++) {
//    Particle confetti = new ParticleConfetti(flip);
//    particles.add(confetti);
//  }
  
//  return particles;
//}
