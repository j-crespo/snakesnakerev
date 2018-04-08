
//Snake and food objects
snake test;
food food1;

//int variables for score and speed
int highScore;
int speed;

//Image objects for arrows
PImage up;
PImage down;
PImage left;
PImage right;

// initialize alpha values at 0
int alpha = 0;
int alpha2 = 0;
int alpha3 = 0;
int alpha4 = 0;

// Imports Minim for audio
import ddf.minim.*;
import ddf.minim.effects.*;

// Calls Serial and Arduino library for hardware interaction
import processing.serial.*;
import cc.arduino.*;

// Creates new Arduino and Minim objects
Arduino arduino;
Minim minim;

// Creates 3 audioplayers in the Minim object
AudioPlayer ded; //death sound
AudioPlayer eat; //eating sound (point scoring)
AudioPlayer bgm; //background music
//AudioPlayer bgm2;
  
//New font object  
PFont myFont;

void setup(){
  
  //setup custom bold font at size 35
  myFont = createFont("Alte DIN 1451 Mittelschrift", 35);
  textFont(myFont);
  
  //starts program in fullscreen
  fullScreen();

  test = new snake();
  food1 = new food();
  
  rectMode(CENTER);
  textAlign(CENTER, CENTER);
  
  // Sets the initial speed to 10
  speed = 10;
  
  smooth();
  
  //Arduino object setup
  arduino = new Arduino(this, Arduino.list()[3], 57600);
  arduino.pinMode(2, Arduino.INPUT);
  arduino.pinMode(12, Arduino.INPUT);
  arduino.pinMode(8, Arduino.INPUT);
  arduino.pinMode(6, Arduino.INPUT);
  
  // Loading specific audio files into audio players
  
  minim = new Minim(this);
  ded = minim.loadFile("sfx_sounds_damage3.wav");
  eat = minim.loadFile("sfx_coin_single2.wav");
  bgm = minim.loadFile("lazerlighteyes.mp3");
  
  // Loops background music track and sets volume lower than other sounds, death and point scoring
  bgm.loop();
  bgm.setGain(-5);
  
  // Loads arrow indicators (show up when a control is pressed)
  down = loadImage("down-arrow.png");
  up = loadImage("up-arrow.png");
  left = loadImage("left-arrow.png");
  right = loadImage("right-arrow.png");
  }

void draw(){
  
  // sets framerate to the value of speed, which is 10
  frameRate(speed);
  background(0);
  
  // Draws scoreboard
  drawScoreboard();
  
  // Decreases 4 alpha values for 4 arrows by a rate of 50 - 
  // the rate at which the arrows fade away from the screen
  alpha += -50;
  alpha2 += -50;
  alpha3 += -50;
  alpha4 += -50;
  
  // Draws individual arrows for control presses at an opacity value of their alphas
  
  tint(#6bfe8a, alpha);  
  image(left, width/2, 30, 47,40);
  tint(#6e6bfe, alpha2);  
  image(right, width/2, 30, 47,40);
  tint(#fe6bdd, alpha3); 
  image(up, width/2, 30, 40,47);
  tint(#fe6b6b, alpha4); 
  image(down, width/2, 30, 40,47);
  
  // move the snake, display the snake and food / ellipse
  test.move();
  test.display();
  food1.display();
  
  
  // Reads arduino input from pins where pressure pads are hooked up, checks if current direction is not the polar opposite, sets the direction the snake should move it
  // The game would technically kill you if you press left then right or up then down, so this is for error handling purposes
  // Also, sets the arrow transparency value to 100% visible when pressed with each control.
  
  if(arduino.digitalRead(12) == Arduino.HIGH && (test.dir != "right")){
    alpha = 255;
test.dir = "left";

// control switching - tested but not implemented (too complicated)

  //if(test.len > 5)
  //test.dir = "up";
//if(test.len > 10)
  //test.dir = "left";
  }
  
    if(arduino.digitalRead(8) == Arduino.HIGH && (test.dir != "left")){
      alpha2 = 255;
test.dir = "right";
  }
  
  if(arduino.digitalRead(6) == Arduino.HIGH && (test.dir != "down")){
    alpha3 = 255;
test.dir = "up";
  }

  if(arduino.digitalRead(2) == Arduino.HIGH && (test.dir != "up")){
    alpha4 = 255;
test.dir = "down";
  }
  
  // If the food is eaten, reset the position of the new food and make the snake bigger
  
  if( dist(food1.xpos, food1.ypos, test.xpos.get(0), test.ypos.get(0)) <= test.sidelen ){
    food1.reset();
    test.addLink();
  }
  
// If the current score is bigger than the high score, make it the high score
  
  if(test.len > highScore){
    highScore= test.len;
  }
  
  // Gradually increasing the speed with the score - when the score is higher, the game gets faster
  
  if (test.len == 5) {
   speed = 12;
  }
  if (test.len == 10) {
   speed = 14; 
  }
  
  if (test.len == 15) {
   speed = 16; 
  }
  
  if (test.len == 20) {
   speed = 18; 
  }
  
  if (test.len == 25) {
   speed = 20; 
  }
  
}
  


void keyPressed(){
  if(key == CODED){
    
    // Keyboard testing of the snake, with similar error handling as Arduino imput code
    
    if((keyCode == LEFT) && (test.dir != "right")) {
      alpha = 255;
      test.dir = "left";
    }
    if((keyCode == RIGHT) && (test.dir != "left")){
      alpha2 = 255;
      test.dir = "right";
    }
    if((keyCode == UP) && (test.dir != "down")){
      alpha3 = 255;
      test.dir = "up";
    }
    if((keyCode == DOWN) && (test.dir != "up")){
      alpha4 = 255;
      test.dir = "down";
    }
  }
}


void drawScoreboard(){
  
  // All of the scode for code and title  
  // draw scoreboard
  fill(255, 255, 255);
  textSize(50);
  text( "Score: " + test.len, 100, 50);
  
  fill(255, 255, 255);
  textSize(50);
  text( "High Score: " + highScore, 150, 100);
}
  
class food{
  
  // define variables for x and y positions
  float xpos, ypos;
  
  //constructor function for the food, setting the positions randomly
  food(){
    xpos = random(50,width-50);
    ypos = random(50,height-50);
  }
  
  
 void display(){
   
   // draws the food, an ellipse
   fill(255);
   noStroke();
   ellipse(xpos, ypos,40,40);
 }
 
 
 void reset(){
   
  //resets the food to a random position once eaten
    xpos = random(50,width-50);
    ypos = random(50,height-50);
 }   
}

// New snake class

class snake{
  
  // len = length of the snake (and concurrently, amount of points)
  int len;
  
  // size of the snake in pixels
  float sidelen;
  
  //dir = direction the snake will move in
  String dir; 
  ArrayList <Float> xpos, ypos;
  
  // constructor for the snake
  snake(){
    len = 1;
    sidelen = 40;
    dir = "right";
    xpos = new ArrayList();
    ypos = new ArrayList();
    xpos.add( random(width) );
    ypos.add( random(height) );
  }
  
  void move(){
    
   // Makes the snake constantly move
   
   for(int i = len - 1; i > 0; i = i -1 ){
    xpos.set(i, xpos.get(i - 1));
    ypos.set(i, ypos.get(i - 1));  
   } 
   
   // code for changing the direction of the snake
   
   if(dir == "left"){
     xpos.set(0, xpos.get(0) - sidelen);
   }
   if(dir == "right"){
     xpos.set(0, xpos.get(0) + sidelen);
   }
   
   if(dir == "up"){
     ypos.set(0, ypos.get(0) - sidelen);  
   }
   
   if(dir == "down"){
     ypos.set(0, ypos.get(0) + sidelen);
   }
   
   xpos.set(0, (xpos.get(0) + width) % width);
   ypos.set(0, (ypos.get(0) + height) % height);
   
    // check if hit itself and if so cut off the tail
    if( checkHit() == true){
      
      // play death sound
      ded.play();
      
      // rewind the soundfile after it is played
    ded.rewind();
    
    //resets score and snake size to 1
    
      len = 1;
      float xtemp = xpos.get(0);
      float ytemp = ypos.get(0);
      xpos.clear();
      ypos.clear();
      xpos.add(xtemp);
      ypos.add(ytemp);
      
      //resets speed back to 10
      speed = 10;
    }
  }
  
    
  void display(){
    //display the snake
    for(int i = 0; i <len; i++){
      stroke(179, 140, 198);
      //fill(255);
      fill(255, 255, 255, map(i-1, 0, len-1, 250, 50));
      noStroke();
      rect(xpos.get(i), ypos.get(i), sidelen, sidelen);
    }  
  }
  
  // code to add a link to the snake
  void addLink(){
    // play eating sound
    eat.play();
    xpos.add( xpos.get(len-1) + sidelen);
    ypos.add( ypos.get(len-1) + sidelen);
    len++;
    eat.rewind();
  }
  // boolean for checking if hit
   boolean checkHit(){
    for(int i = 1; i < len; i++){
     if( dist(xpos.get(0), ypos.get(0), xpos.get(i), ypos.get(i)) < sidelen){
       return true;
     } 
    } 
    return false;
   } 
}
