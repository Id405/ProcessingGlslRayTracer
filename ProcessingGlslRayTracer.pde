import java.awt.AWTException; //TODO make this not in processing LMAO
import java.awt.Robot;

PShader TR;
Robot rb;

float fov = 70;
float gamma = 1.5;

float maxsteps = 100;
float margin = 0.01;
float samples = 1;
float progressiveSamples = 25; //Run more shader samples when progressively rendering because averaging in the shader is much more perfomant than averaging in using floatImage

float transx = 0;
float transy = -5;
float transz = 0;

float rotationX = 0;
float rotationY = 0;
float rotationZ = 0;

boolean lock = true;
boolean fullscreen = false;
boolean progressiveSampling = true;

PGraphics graphics;
FloatImage sampledImage;
int sampleCount = 0;

float moveSpeed = 0.5;
float rotSpeed = 0.05;
float sensitivity = 0.001;

int robotMoveAmountX;
int robotMoveAmountY;


void setup() {
  size(800, 800, P2D);
  //fullScreen(P2D);
  //fullscreen = true;

  TR = loadShader("Tracer.glsl");
  TR.set("maxsteps", maxsteps);
  TR.set("margin", margin);

  TR.set("iResolution", float(width), float(height));
  TR.set("transl", transx, transy, transz);
  TR.set("rotation", rotationX, rotationY, rotationZ);
  TR.set("samples", samples);
  TR.set("fov", 0.5 * tan(radians(90 - fov/2)));

  if (progressiveSampling) {
    graphics = createGraphics(width, height, P2D);
    graphics.shader(TR);
    resetSampling();
  }

  try
  {
    rb = new Robot();
  }
  catch (AWTException e)
  {
    println("Robot class not supported by your system!");
    exit();
  }

  if (lock) {
    noCursor();
  }
}

void draw() {
  background(100, 150, 100);
  TR.set("iResolution", float(width), float(height));
  TR.set("transl", transx, transy, transz);
  TR.set("rotation", rotationX, rotationY, rotationZ);
  TR.set("fov", 0.5 * tan(radians(90f - fov/2f)));
  TR.set("frameCount", float(frameCount));
  TR.set("samples", samples);
  TR.set("transform", 2.2);
  println("FPS: " + frameRate + " Samples: " + (sampleCount * samples));

  if (keyPressed && lock) {
    if (key == 'w') {
      transRotate(new PVector(0, 1, 0));
    } else if (key == 's') {
      transRotate(new PVector(0, -1, 0));
    } else if (key == 'a') {
      transRotate(new PVector(-1, 0, 0));
    } else if (key == 'd') {
      transRotate(new PVector(1, 0, 0));
    } else if (key == ' ') {
      transz += moveSpeed;
    } else if (key == 'c') {
      transz -= moveSpeed;
    } else if (keyCode == UP) {
      rotationX += rotSpeed;
    } else if (keyCode == DOWN) {
      rotationX -= rotSpeed;
    } else if (keyCode == LEFT) {
      rotationZ += rotSpeed;
    } else if (keyCode == RIGHT) {
      rotationZ -= rotSpeed;
    }
  }

  if (lock) {
    surface.setLocation(displayWidth/2-width/2-3, displayHeight/2-height/2-26); //fix this terrible code

    int dX = mouseX-pmouseX+robotMoveAmountX;
    int dY = mouseY-pmouseY+robotMoveAmountY;

    if (fullscreen) {
      robotMoveAmountX = mouseX-displayWidth/2;
      robotMoveAmountY = mouseY-displayHeight/2;
    } else {
      robotMoveAmountX = mouseX-width/2;
      robotMoveAmountY = mouseY-height/2;
    }

    rb.mouseMove(displayWidth/2, displayHeight/2);

    rotationX -= dY*sensitivity;
    rotationZ -= dX*sensitivity;

    if (frameCount == 1) {
      rotationX = 0;
      rotationZ = 0;
    }
  }

  if (progressiveSampling && !lock) {
    resetShader();
    TR.set("samples", progressiveSamples);
    TR.set("transform", 2.2);
    graphics.beginDraw();
    graphics.rect(0, 0, width, height);
    graphics.endDraw();
    addSample(graphics.get()); //Must use .get() to prevent a reference being made
    image(sampledImage.getImage(), 0, 0);
  } else {
    shader(TR);
    rect(0, 0, width, height);
  }
}

void keyReleased() {
  if (key == 'g') {
    lock = !lock;
    if (lock) {
      robotMoveAmountX = -(mouseX-width/2);
      robotMoveAmountY = -(mouseY-height/2);
      noCursor();
      resetSampling();
    } else {
      cursor();
      resetSampling();
    }
  }
}

void transRotate(PVector vec3) {
  PVector zRot = new PVector(vec3.x, vec3.y);
  zRot.rotate(rotationZ);
  vec3 = new PVector(zRot.x, zRot.y, vec3.z);

  PVector yRot = new PVector(vec3.y, vec3.z);
  yRot.rotate(rotationX);
  vec3 = new PVector(vec3.x, yRot.x, yRot.z);

  transy += moveSpeed * vec3.y;
  transx += moveSpeed * vec3.x;
  transz += moveSpeed * vec3.z;
}

void addSample(PImage img) { //TODO make averaging of image run in the background while sampling happens continously
  FloatImage fImg = new FloatImage(img);

  sampledImage.average((float) sampleCount / (float) (sampleCount+1), fImg);
  sampleCount++;
}

void resetSampling() {
  if (progressiveSampling) {
    //graphics.beginDraw();
    //graphics.shader(TR);
    //TR.set("samples", progressiveSamples);
    //TR.set("transform", 0);
    //graphics.rect(0, 0, width, height);
    //graphics.endDraw();
    sampledImage = new FloatImage(graphics.get());
    sampleCount = 0;
  }
}
