import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;


Minim minim;
AudioInput in;

//CHANGE THESE
float  threshold = 1.5;
int waitTime = 4500;

float sum,avg,currHigh;

AudioPlayer[] audioFiles = new AudioPlayer[3];
int currAudio = 0;
int audioCount = 3;
boolean audioPlaying = false;
int hour = 0; //hour var to be adjusted to 12 hour time

boolean barkDetected = false;
int barkCounter = 0;
long barkTime;


PFont font;

void setup()
{
  size(256, 200, P3D);

  minim = new Minim(this);
  // minim.debugOn();

  // get a line in from Minim, default bit depth is 16
  in = minim.getLineIn(Minim.STEREO, 256);//

  //audio files

  audioFiles[0] = minim.loadFile("1.mp3", 2048);
  audioFiles[1] = minim.loadFile("2.mp3", 2048);
  audioFiles[2] = minim.loadFile("3.mp3", 2048);

  font = loadFont("HelveticaNeue-Bold-100.vlw");
}

void draw()
{
  if (barkDetected && audioFiles[currAudio].isPlaying() ) {
    background(0,100,0);
  }  
  else if (barkDetected && !audioFiles[currAudio].isPlaying() ) {
    background(200,100,50);
  } 
  else {
    background(100,0,0);
  }
  
  
  stroke(255);
  
  // audio detection stuff
  
  sum = 0.0;
  for(int i = 0; i < in.bufferSize() - 1; i++)
  {
    sum += in.left.get(i)*100 +  in.right.get(i)*100;
    line(i, 50 + in.left.get(i)*50, i+1, 50 + in.left.get(i+1)*50);
    line(i, 150 + in.right.get(i)*50, i+1, 150 + in.right.get(i+1)*50);
  }

  currHigh = sum/in.bufferSize();
  
  
  if (currHigh > threshold && !audioFiles[currAudio].isPlaying() && (millis() - barkTime > 1000)) {
    //set / reset barkTime
    barkDetected = true;
    barkTime = millis();

    barkCounter++;
    
    hour = hour();
    if (hour >12){ hour = hour -12;} //adjust hour to 12 hour time
    
    
    println("bark detected: " + barkCounter + " time: "+ hour + ":" + minute()+ " second "+ second());
    
    
  } 
  else if (barkDetected && !audioPlaying && !audioFiles[currAudio].isPlaying() && (millis() - barkTime > waitTime) ) {
    //start audio if bark was detected a few seconds ago
    audioPlaying = true;
    audioFiles[currAudio].rewind();
    audioFiles[currAudio].play();
    
    hour = hour();
    if (hour >12){ hour = hour -12;} //adjust hour to 12 hour time
    println("playing audio file: " + currAudio + " time: "+ hour + ":" + minute()+ " second "+ second() );
  } 
  else if (barkDetected && audioPlaying && !audioFiles[currAudio].isPlaying()  ) {
    //audio file is done playing, reset things and increment to next audio file
    resetAudio();
    println("ending audio");
    //increment audiotrack counter
    if (currAudio < audioCount-1) {
      currAudio += 1;
    } 
    else {
      currAudio = 0;
    }
  }

  //display bark count
  textFont(font); 
  textAlign(CENTER);
  int fWidth = (int)textWidth(Integer.toString(barkCounter));
  text(barkCounter,(width/2), (height/2)+35);
}

void resetAudio() {
  barkDetected = false;
  audioPlaying = false;
  audioFiles[currAudio].loop(1);
  audioFiles[currAudio].pause();
}
void stop()
{
  // always close Minim audio classes when you are done with them
  in.close();
  for(int i = 0; i<audioCount; i++) {
    audioFiles[i].close();
  }
  minim.stop();

  super.stop();
}


