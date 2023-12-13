final static int scale = 1;

int levelIDX = 0;

int[] gravstatus;

boolean[] floorhere;

boolean[] deathhere;

boolean[] goalhere;

boolean proto_gg = false;

PImage[] directions, playerWalk;

PImage flag, protognd, protodeath;
PGraphics backgroundPrerender;

boolean[] inputs = {false, false, false, false, false};

int locX;
float velX;
int locY;
float velY;
int lColX, tColY,
    mColX, mColY,
    rColX, bColY;
    
void resetLevel() {
  velX = 0;
  velY = 0;
  locX = levelSpawn[levelIDX][0];
  locY = levelSpawn[levelIDX][1];
  gravstatus = levelGS[levelIDX];
  floorhere = levelF[levelIDX];
  deathhere = levelD[levelIDX];
  goalhere = levelG[levelIDX];
  // Render background
  backgroundPrerender = createGraphics(240, 160);
  backgroundPrerender.beginDraw();
  for (int x = 0; x < 30; x++)
    for (int y = 0; y < 20; y++)
      backgroundPrerender.image(directions[gravstatus[x + y * 30]], x * 8, y * 8, 8, 8);
  for (int x = 0; x < 30; x++)
    for (int y = 0; y < 20; y++)
      if (floorhere[x + y * 30])
        backgroundPrerender.image(protognd, x * 8, y * 8, 8, 8);
  for (int x = 0; x < 30; x++)
    for (int y = 0; y < 20; y++)
      if (deathhere[x + y * 30])
        backgroundPrerender.image(protodeath, x * 8, y * 8, 8, 8);
  for (int x = 0; x < 30; x++)
    for (int y = 0; y < 20; y++)
      if (goalhere[x + y * 30])
        backgroundPrerender.image(flag, x * 8, y * 8, 8, 8);
  backgroundPrerender.endDraw();
}

void settings() {
  size(240 * scale, 160 * scale);
}

void setup() {
  settings(); // Processing 2 workaround
  noSmooth();
  frameRate(60);
  lColX = locX / 8;
  tColY = locY / 8;
  locX += 4;
  locY += 4;
  mColX = locX / 8;
  mColY = locY / 8;
  locX -= 4;
  locY -= 4;
  rColX = lColX + 1;
  bColY = tColY + 1;
  println("loading images...");
  directions = new PImage[4];
  directions[0] = loadImage("d.gif");
  directions[1] = loadImage("l.gif");
  directions[2] = loadImage("u.gif");
  directions[3] = loadImage("r.gif");
  playerWalk = new PImage[2];
  playerWalk[0] = loadImage("playerWalk1.gif");
  playerWalk[1] = loadImage("playerWalk2.gif");
  flag = loadImage("flag.gif");
  protognd = loadImage("gnd_proto.gif");
  protodeath = loadImage("oof.gif");
  resetLevel();
}

int jmpTmr = -1;
int oGrav = 0;
int animTmr = 0;
int oldAnimTmr = 0;
boolean flip = false;
int r = 0;
int tR = 0;

void draw() {
  pushMatrix();
  scale(scale);
  if (proto_gg) {
    textSize(64);
    textAlign(CENTER, CENTER);
    text("GG", 120, 80);
    popMatrix();
    return;
  }
  if (goalhere[mColX + mColY * 30]) {
    levelIDX++;
    if (levelIDX == levelCnt) proto_gg = true;
    else resetLevel();
  }
  oldAnimTmr = animTmr;
  if (tR > r) r+=30;
  if (tR < r) r-=30;
  if (tR == r) {
    r = r % 360;
    r += 360;
    r = r % 360;
    tR = tR % 360;
    tR += 360;
    tR = tR % 360;
  }
  println(frameRate);
  if (gravstatus[mColX + mColY * 30] != oGrav) {
    jmpTmr = 0;
    switch (oGrav) {
      case 3: {
        switch(gravstatus[mColX + mColY * 30]) {
          case 3: break;
          case 2: {
            tR = 180;
            break;
          }
          case 1: {
            if (flip)
              tR = 450;
            else 
              tR = 90;
            break;
          }
          default: {
            tR = 360;
            break;
          }
        }
        break;
      }
      case 2: {
        switch(gravstatus[mColX + mColY * 30]) {
          case 2: break;
          case 3: {
            tR = 270;
            break;
          }
          case 1: {
            tR = 90;
            break;
          }
          default: {
            if (flip)
              tR = 0;
            else 
              tR = 360 ;
            break;
          }
        }
        break;
      }
      case 1: {
        switch(gravstatus[mColX + mColY * 30]) {
          case 3: {
            if (flip)
              tR = 270;
            else
              tR = -90;
            break;
          }
          case 2: {
            tR = 180;
            break;
          }
          case 1: break;
          default: {
            tR = 0;
            break;
          }
        }
        break;
      }
      default: {
        switch(gravstatus[mColX + mColY * 30]) {
          case 3: {
            tR = -90;
            break;
          }
          case 2: {
            if (flip)
              tR = -180;
            else 
              tR = 180;
            break;
          }
          case 1: {
            tR = 90;
            break;
          }
          default: break;
        }
        break;
      }
    }
  }
  switch(gravstatus[mColX + mColY * 30]) {
    case 3: {
      if (floorhere[rColX + mColY * 30]) jmpTmr = -1;
      else if (jmpTmr != 0) jmpTmr--;
      if (jmpTmr == -3) jmpTmr = 0;
      velX += 0.3;
      velY *= 9;
      velY /= 13;
      if (jmpTmr != 0 && inputs[4]) {
        velX = -3;
        if (jmpTmr < 0) jmpTmr = 8;
      }
      if (inputs[0]) {
        velY --;
        flip = true;
        animTmr++;
      }
      if (inputs[2]) {
        velY ++;
        flip = false;
        animTmr++;
      }
      break;
    }
    case 2: {
      if (floorhere[mColX + tColY * 30]) jmpTmr = -1;
      else if (jmpTmr != 0) jmpTmr--;
      if (jmpTmr == -3) jmpTmr = 0;
      velY -= 0.3;
      velX *= 9;
      velX /= 13;
      if (jmpTmr != 0 && inputs[4]) {
        velY = 3;
        if (jmpTmr < 0) jmpTmr = 8;
      }
      if (inputs[1]) {
        velX --;
        flip = true;
        animTmr++;
      }
      if (inputs[3]) {
        velX ++;
        flip = false;
        animTmr++;
      }
      break;
    }
    case 1: {
      if (floorhere[lColX + mColY * 30]) jmpTmr = -1;
      else if (jmpTmr != 0) jmpTmr--;
      if (jmpTmr == -3) jmpTmr = 0;
      velX -= 0.3;
      velY *= 9;
      velY /= 13;
      if (jmpTmr != 0 && inputs[4]) {
        velX = 3;
        if (jmpTmr < 0) jmpTmr = 8;
      }
      if (inputs[0]) {
        velY --;
        flip = false;
        animTmr++;
      }
      if (inputs[2]) {
        velY ++;
        animTmr++;
        flip = true;
      }
      break;
    }
    default: {
      if (floorhere[mColX + bColY * 30]) jmpTmr = -1;
      else if (jmpTmr != 0) jmpTmr--;
      if (jmpTmr == -3) jmpTmr = 0;
      velY += 0.3;
      velX *= 9;
      velX /= 13;
      if (jmpTmr != 0 && inputs[4]) {
        velY = -3;
        if (jmpTmr < 0) jmpTmr = 8;
      }
      if (inputs[1]) {
        velX --;
        flip = false;
        animTmr++;
      }
      if (inputs[3]) {
        velX ++;
        flip = true;
        animTmr++;
      }
      break;
    }
  }
  oGrav = gravstatus[mColX + mColY * 30];
  if (velY > 8) velY = 8;
  if (velY < -8) velY = -8;
  if (velX > 8) velX = 8;
  if (velX < -8) velX = -8;
  locX += round(velX);
  locY += round(velY);
  lColX = locX / 8;
  tColY = locY / 8;
  locX += 4;
  locY += 4;
  mColX = locX / 8;
  mColY = locY / 8;
  locX -= 4;
  locY -= 4;
  rColX = lColX + 1;
  bColY = tColY + 1;
  if (deathhere[mColX + mColY * 30]) {
    velX = 0;
    velY = 0;
  } else {
    if (floorhere[mColX + mColY * 30]) {
      switch (gravstatus[mColX + mColY * 30]) {
        case 3: {
          locX = lColX * 8;
          velX = min(0, velX);
          break;
        }
        case 2: {
          locY = bColY * 8;
          velY = max(0, velY);
          break;
        }
        case 1: {
          locX = rColX * 8;
          velX = max(0, velX);
          break;
        }
        default: {
          locY = tColY * 8;
          velY = min(0, velY);
          break;
        }
      }
    } else {
      if (mColX <= 0) {
        locX = 7;
        lColX = 0;
        mColX = 1;
        rColX = 1;
      }
      if (mColX >= 29) {
        locX = 225;
        lColX = 28;
        mColX = 28;
        rColX = 29;
      }
      if (floorhere[lColX + mColY * 30]) {
        locX = rColX * 8;
        velX = max(0, velX);
      }
      if (floorhere[rColX + mColY * 30]) {
        locX = lColX * 8;
        velX = min(0, velX);
      }
      if (mColY <= 0) {
        locY = 7;
        tColY = 0;
        mColY = 1;
        bColY = 1;
      }
      if (mColY >= 19) {
        locY = 145;
        tColY = 18;
        mColY = 18;
        bColY = 19;
      }
      if (floorhere[mColX + bColY * 30]) {
        locY = tColY * 8;
        velY = min(0, velY);
      }
      if (floorhere[mColX + tColY * 30]) {
        locY = bColY * 8;
        velY = max(0, velY);
      }
    }
  }
  noStroke();
  image(backgroundPrerender, 0, 0, 240, 160);
  fill(255);
  pushMatrix();
  translate(locX, locY);
  translate(4, 4);
  rotate(radians(r));
  translate(-4, -4);
  if (flip) {
    scale(-1,1);
    translate(-8,0);
  }
  if (animTmr == oldAnimTmr)
    animTmr = 0;
  if (animTmr >= 10)
    animTmr -= 10;
  if (animTmr >= 5 || jmpTmr >= 0) 
    image(playerWalk[1], 0, 0, 8, 8);
  else 
    image(playerWalk[0], 0, 0, 8, 8);
  popMatrix();
  if (deathhere[mColX + mColY * 30]) resetLevel();
  popMatrix();
}

void keyPressed() {
  switch (key) {
    case 'w':
    case 'W': {
      inputs[0] = true;
      break;
    }
    case 'a':
    case 'A': {
      inputs[1] = true;
      break;
    }
    case 's':
    case 'S': {
      inputs[2] = true;
      break;
    }
    case 'd':
    case 'D': {
      inputs[3] = true;
      break;
    }
    default: {
      inputs[4] = true;
      break;
    }
  }
}

void keyReleased() {
  switch (key) {
    case 'w':
    case 'W': {
      inputs[0] = false;
      break;
    }
    case 'a':
    case 'A': {
      inputs[1] = false;
      break;
    }
    case 's':
    case 'S': {
      inputs[2] = false;
      break;
    }
    case 'd':
    case 'D': {
      inputs[3] = false;
      break;
    }
    default: {
      inputs[4] = false;
      break;
    }
  }
}
