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
  
  void addPreset(ParticlePreset preset) {
    ArrayList<Particle> particlesToAdd = getParticlePreset(preset);
    addParticles(particlesToAdd);
  }
  
  void addParticles(ArrayList<Particle> particlesToAdd) {
    particles.addAll(particlesToAdd);
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
    noStroke();
    fill(col);
    
    circle(size);
  }
}


enum ParticlePreset {
  MAGICALS
}
ArrayList<Particle> getParticlePreset(ParticlePreset preset) {
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
    
    float diceSize = Settings.DICE_SIZE_PERCENT * board.size.x;
    size = diceSize * Settings.PARTICLE_MAGICAL_SIZE_PERCENT;
    
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
