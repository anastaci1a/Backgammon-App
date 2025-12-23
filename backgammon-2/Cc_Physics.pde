// -- Physics Engine --


static class Physics {
  static class Box {
    boolean physicsActive;
    
    int id;         // ID to prevent double collision resolution
    PVector pos;    // Position of the center of the box
    PVector vel;    // Linear velocity
    float rot;      // Current rotation (radians)
    float rotVel;   // Rotational velocity (radians per frame)
    float friction; // 0..1, linear and angular damping
    PVector size;   // Box width/height
    
    // All boxes in the scene (for collision checks)
    ArrayList<Box> allBoxes;
    
    // For convenience, define a mass and moment of inertia for torque calcs
    // (For a uniform square of side 'size', mass m, moment of inertia ~ m*size^2/6 around center)
    // We can tweak or keep them constant to taste:
    float mass = 1.0;
    float inertia = 1.0; // e.g. (mass * size * size) / 6 or / 2, etc.
    
    PVector[] boundsCorners; // corners of bounding box (top left, bottom right)
                             // [LEGACY SUPPORT]
    
    /**
     * Construct a Box with given parameters.
     */
    
    
    Box(int _id, PVector _pos, PVector _vel, PVector _size, float _rot, float _rotVel,
        float _friction, ArrayList<Box> _allBoxes) {
      physicsActive = true;
      
      id = _id;
      
      pos = _pos.copy();
      vel = _vel.copy();
      size = _size;
      
      rot = _rot;
      rotVel = _rotVel;
      friction = _friction;
      
      allBoxes = _allBoxes;
      
      boundsCorners = null;
      
      // Set inertia to something reasonable for a box:
      //inertia = (mass * size * size) / 2.0;
      float w = size.x;
      float h = size.y;
      inertia = mass * (w * w + h * h) / 12.0;
    }
  
    /**
     * Called every frame to handle physical simulation:
     * 1) Damping
     * 2) Integrate position & rotation
     * 3) Bounce off boundaries
     * 4) Collision checks with other boxes
     */
    void managePhysics() {
      if (physicsActive) {
        // 1) Apply frictional damping (simple approach)
        vel.mult(1 - friction);
        rotVel *= (1 - friction);
    
        // 2) Integrate position & rotation
        pos.add(vel);
        rot += rotVel;
        rot %= TWO_PI;
        
        // 3) Bounce off area boundaries [LEGACY SUPPORT]
        bounceOffEdges();
    
        // 3) Check collisions with other boxes
        for (Box b : allBoxes) {
          // Avoid self-collision
          if (b == this) continue;
          
          // Avoid double collision checks
          if (id <= b.id && b.physicsActive) continue;
          
          // Check if these two boxes are overlapping
          CollisionInfo info = checkOBBCollision(this, b);
          if (info.colliding) {
            // Solve collision
            resolveCollision(this, b, info);
          }
        }
      }
    }
    
    /**
     * Simple bounding logic: checks if any corner is out of the bounding area.
     * If so, shift the box back in and reflect velocity.
     * [LEGACY SUPPORT]
     */
    void bounceOffEdges() {
      if (boundsCorners != null) { // must be set manually
        PVector[] corners = getCorners();
        PVector min = boundsCorners[0].copy();
        PVector max = boundsCorners[1].copy();
        
        PVector shift = new PVector(0, 0);
        
        boolean collidedX = false;
        boolean collidedY = false;
        
        // Check all corners against boundaries
        for (PVector c : corners) {
          // Left boundary
          if (c.x < min.x) {
            collidedX = true;
            float diff = min.x - c.x;
            if (abs(diff) > abs(shift.x)) {
              shift.x = diff;
            }
          }
          // Right boundary
          else if (c.x > max.x) {
            collidedX = true;
            float diff = max.x - c.x;
            if (abs(diff) > abs(shift.x)) {
              shift.x = diff;
            }
          }
          // Top boundary
          if (c.y < min.y) {
            collidedY = true;
            float diff = min.y - c.y;
            if (abs(diff) > abs(shift.y)) {
              shift.y = diff;
            }
          }
          // Bottom boundary
          else if (c.y > max.y) {
            collidedY = true;
            float diff = max.y - c.y;
            if (abs(diff) > abs(shift.y)) {
              shift.y = diff;
            }
          }
        }
        
        // If corners are out of bounds, shift the center
        if (collidedX || collidedY) {
          pos.add(shift);
          
          // Reflect velocity for a basic bounce
          if (collidedX) {
            vel.x *= -1;
            // Optionally reduce rotational velocity slightly
            rotVel *= 0.9; 
          }
          if (collidedY) {
            vel.y *= -1;
            rotVel *= 0.9;
          }
        }
      }
    }
    
    /**
     * Returns the 4 corners of this box's square in world space.
     */
    PVector[] getCorners() {
      PVector[] corners = new PVector[4];
      
      // Half-size (distance from center to any edge)
      PVector half = size.copy().div(2);
      
      // Local corner coordinates before rotation
      PVector c0 = new PVector(-half.x, -half.y);
      PVector c1 = new PVector( half.x, -half.y);
      PVector c2 = new PVector( half.x,  half.y);
      PVector c3 = new PVector(-half.x,  half.y);
      
      // Rotate each corner and then translate
      corners[0] = rotateAndTranslate(c0, pos, rot);
      corners[1] = rotateAndTranslate(c1, pos, rot);
      corners[2] = rotateAndTranslate(c2, pos, rot);
      corners[3] = rotateAndTranslate(c3, pos, rot);
      
      return corners;
    }
    
    /**
     * Checks collision between two oriented bounding boxes (A & B).
     * Returns CollisionInfo (colliding, normal, depth, contactPoint).
     */
    CollisionInfo checkOBBCollision(Box A, Box B) {
      CollisionInfo info = new CollisionInfo();
      info.colliding = false;
      info.normal = new PVector();
      info.depth = Float.MAX_VALUE;
      info.contactPoint = new PVector();
      
      // Get corners
      PVector[] aCorners = A.getCorners();
      PVector[] bCorners = B.getCorners();
  
      // Gather the 4 axes (2 from A, 2 from B)
      ArrayList<PVector> axes = new ArrayList<PVector>();
      axes.add(edgeNormal(aCorners[0], aCorners[1])); 
      axes.add(edgeNormal(aCorners[1], aCorners[2]));
      axes.add(edgeNormal(bCorners[0], bCorners[1]));
      axes.add(edgeNormal(bCorners[1], bCorners[2]));
      
      // For each axis, project both boxes and check overlap
      for (PVector axis : axes) {
        float[] projA = projectPolygon(aCorners, axis);
        float[] projB = projectPolygon(bCorners, axis);
  
        float overlap = getOverlap(projA[0], projA[1], projB[0], projB[1]);
        if (overlap <= 0) {
          // No overlap -> no collision
          info.colliding = false;
          return info;
        } else {
          if (overlap < info.depth) {
            info.colliding = true;
            info.depth = overlap;
  
            // Ensure normal points from A->B
            PVector ab = PVector.sub(B.pos, A.pos);
            if (ab.dot(axis) < 0) {
              axis.mult(-1);
            }
            info.normal = axis.copy();
          }
        }
      }
      
      // Estimate a contact point (simple midpoint of centers)
      info.contactPoint.set(
        (A.pos.x + B.pos.x) * 0.5f,
        (A.pos.y + B.pos.y) * 0.5f
      );
      
      return info;
    }
  
    /**
     * Resolves collision between two colliding boxes, applying impulse
     * to separate them and updating each box's linear & angular velocity.
     */
    void resolveCollision(Box A, Box B, CollisionInfo info) {
      if (!info.colliding) return;
      
      // Check masses for infinite
      boolean A_infinite = Float.isInfinite(A.mass) || !A.physicsActive;
      boolean B_infinite = Float.isInfinite(B.mass) || !B.physicsActive;
      
      // 1) Positional correction
      if (A_infinite && B_infinite) {
        // Both immovable => do nothing. 
        // (They shouldn't push each other at all.)
        return;
      }
      else if (A_infinite && !B_infinite) {
        // Move B entirely by the full overlap
        PVector separation = PVector.mult(info.normal, info.depth);
        B.pos.add(separation);
      }
      else if (!A_infinite && B_infinite) {
        // Move A entirely by the full overlap
        PVector separation = PVector.mult(info.normal, info.depth);
        A.pos.sub(separation);
      }
      else {
        // Both finite => standard half-and-half
        float correction = info.depth * 0.5f;
        PVector separation = PVector.mult(info.normal, correction);
        A.pos.sub(separation);
        B.pos.add(separation);
      }
      
      // 2) Relative velocity (including rotation)
      PVector rA = PVector.sub(info.contactPoint, A.pos);
      PVector rB = PVector.sub(info.contactPoint, B.pos);
      
      PVector vA = getContactVelocity(A, rA);
      PVector vB = getContactVelocity(B, rB);
      PVector vRel = PVector.sub(vB, vA);
      
      float vn = vRel.dot(info.normal);
      if (vn > 0) return; // already separating
      
      // 3) Impulse
      float e = 0f; // restitution
      float raCrossN = cross2D(rA, info.normal);
      float rbCrossN = cross2D(rB, info.normal);
      
      // If infinite mass => 1/m = 0 => won't receive velocity change
      float invMassA = A_infinite ? 0 : (1f / A.mass);
      float invMassB = B_infinite ? 0 : (1f / B.mass);
      
      float invInertiaA = A_infinite ? 0 : (1f / A.inertia);
      float invInertiaB = B_infinite ? 0 : (1f / B.inertia);
      
      float invMassSum = (invMassA + invMassB)
                       + (raCrossN*raCrossN)*invInertiaA
                       + (rbCrossN*rbCrossN)*invInertiaB;
      
      float j = -(1 + e)*vn / invMassSum;
      
      // 4) Apply linear impulse
      PVector impulse = PVector.mult(info.normal, j);
      A.vel.sub(PVector.mult(impulse, invMassA));
      B.vel.add(PVector.mult(impulse, invMassB));
      
      // 5) Angular impulses
      float torqueA = cross2D(rA, impulse);
      float torqueB = cross2D(rB, impulse);
      A.rotVel -= torqueA * invInertiaA;
      B.rotVel += torqueB * invInertiaB;
    }
  }
  
  // -------------------------------------------------------------------------
  //  Utility
  // -------------------------------------------------------------------------
  
  /**
   * Generates/adds four "edge" Boxes (immovable walls) for a rectangular boundary.
   * [COLLISION HAS AN ISSUE THAT MAKES THIS UNUSABLE]
   *
   * @param allBoxes         The ArrayList of boxes to add edge boxes to.
   * @param boundaryCorners  A size-2 array of PVectors: [0] = top-left corner, [1] = bottom-right corner
   * @param thickness        The thickness of each wall (e.g. 10 pixels)
   * @return                 An ArrayList<Box> containing the four edge boxes
   */
  static ArrayList<Box> addBoundaryEdges(ArrayList<Box> allBoxes, PVector[] boundaryCorners, float thickness) {
    ArrayList<Box> edges = new ArrayList<Box>();
    
    // Extract boundary min/max
    float minX = boundaryCorners[0].x;
    float minY = boundaryCorners[0].y;
    float maxX = boundaryCorners[1].x;
    float maxY = boundaryCorners[1].y;
    
    // Calculate total boundary width/height
    float boundaryWidth  = maxX - minX;
    float boundaryHeight = maxY - minY;
    
    // Precompute midpoints
    float centerX = (minX + maxX) * 0.5f;
    float centerY = (minY + maxY) * 0.5f;
    
    // We'll set all walls to friction = 0, velocity = (0,0), rotation = 0, etc.
    
    // 1) LEFT WALL
    PVector leftPos  = new PVector(minX - thickness * 0.5f, centerY);
    // Tall, thin wall: thickness wide, but covers entire boundary in height (plus a bit if you want)
    PVector leftSize = new PVector(thickness, boundaryHeight + thickness);
    Box leftWall = addBox(leftPos, new PVector(0, 0), leftSize,
                          0, 0, 0,
                          allBoxes);
    leftWall.mass    = Float.POSITIVE_INFINITY;
    leftWall.inertia = Float.POSITIVE_INFINITY;
    edges.add(leftWall);
    
    // 2) RIGHT WALL
    PVector rightPos  = new PVector(maxX + thickness * 0.5f, centerY);
    PVector rightSize = new PVector(thickness, boundaryHeight + thickness);
    Box rightWall = addBox(rightPos, new PVector(0, 0), rightSize,
                           0, 0, 0,
                           allBoxes);
    rightWall.mass    = Float.POSITIVE_INFINITY;
    rightWall.inertia = Float.POSITIVE_INFINITY;
    edges.add(rightWall);
    
    // 3) TOP WALL
    PVector topPos  = new PVector(centerX, minY - thickness * 0.5f);
    PVector topSize = new PVector(boundaryWidth + thickness, thickness);
    Box topWall = addBox(topPos, new PVector(0, 0), topSize,
                         0, 0, 0,
                         allBoxes);
    topWall.mass    = Float.POSITIVE_INFINITY;
    topWall.inertia = Float.POSITIVE_INFINITY;
    edges.add(topWall);
    
    // 4) BOTTOM WALL
    PVector bottomPos  = new PVector(centerX, maxY + thickness * 0.5f);
    PVector bottomSize = new PVector(boundaryWidth + thickness, thickness);
    Box bottomWall = addBox(bottomPos, new PVector(0, 0), bottomSize,
                            0, 0, 0,
                            allBoxes);
    bottomWall.mass    = Float.POSITIVE_INFINITY;
    bottomWall.inertia = Float.POSITIVE_INFINITY;
    edges.add(bottomWall);
    
    
    return edges;
  }
  
  /**
   * Simple function to add/return a box to allBoxes ArrayList, while setting id.
   */
  static Box addBox(PVector pos, PVector vel, PVector size,
                    float rot, float rotVel, float friction,
                    ArrayList<Box> allBoxes) {
    int id = allBoxes.size();
    Box newBox = new Box(id, pos, vel, size, rot, rotVel, friction, allBoxes);
    
    allBoxes.add(newBox);
    return newBox;
  }
  
  /**
   * Simple container for collision results.
   */
  static class CollisionInfo {
    boolean colliding;
    float depth;          // overlap amount
    PVector normal;       // axis along which boxes overlap
    PVector contactPoint; // approximate contact location
  }
  
  /**
   * Rotate a point around origin by 'angle' and translate by 'offset'.
   */
  static PVector rotateAndTranslate(PVector corner, PVector offset, float angle) {
    float cosA = cos(angle);
    float sinA = sin(angle);
    float rx = corner.x * cosA - corner.y * sinA;
    float ry = corner.x * sinA + corner.y * cosA;
    return new PVector(rx + offset.x, ry + offset.y);
  }
  
  /**
   * Velocity at a contact point = linearVelocity + (rotVel cross r).
   * For 2D, cross => rotVel * perp(r).
   */
  static PVector getContactVelocity(Physics.Box box, PVector r) {
    PVector perp = new PVector(-r.y, r.x);
    PVector rotPart = PVector.mult(perp, box.rotVel);
    return PVector.add(box.vel, rotPart);
  }
  
  /**
   * 2D cross product => scalar.
   */
  static float cross2D(PVector a, PVector b) {
    return a.x * b.y - a.y * b.x;
  }
  
  /**
   * Returns a normalized axis perpendicular to the edge from c1->c2.
   */
  static PVector edgeNormal(PVector c1, PVector c2) {
    PVector edge = PVector.sub(c2, c1);
    float temp = edge.x;
    edge.x = -edge.y;
    edge.y = temp;
    edge.normalize();
    return edge;
  }
  
  /**
   * Projects polygon corners onto an axis => [min, max].
   */
  static float[] projectPolygon(PVector[] corners, PVector axis) {
    float minVal = Float.MAX_VALUE;
    float maxVal = -Float.MAX_VALUE;
    for (PVector c : corners) {
      float dotVal = c.dot(axis);
      if (dotVal < minVal) minVal = dotVal;
      if (dotVal > maxVal) maxVal = dotVal;
    }
    return new float[]{ minVal, maxVal };
  }
  
  /**
   * 1D interval overlap => overlap > 0 => collision.
   */
  static float getOverlap(float minA, float maxA, float minB, float maxB) {
    return min(maxA, maxB) - max(minA, minB);
  }
  
}
