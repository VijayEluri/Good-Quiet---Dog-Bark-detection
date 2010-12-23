import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;


Minim minim;
AudioInput in;
float  threshold,sum,avg,currHigh;

AudioPlayer[] audioFiles = new AudioPlayer[3];
int currAudio = 0;
int audioCount = 3;
boolean trackStarted = false;

void setup()
{
  size(256, 200, P3D);
 
  minim = new Minim(this);
  minim.debugOn();
 
  // get a line in from Minim, default bit depth is 16
  in = minim.getLineIn(Minim.STEREO, 256);//
  
  //audio files
  
  audioFiles[0] = minim.loadFile("1.mp3", 2048);
  audioFiles[1] = minim.loadFile("2.mp3", 2048);
  audioFiles[2] = minim.loadFile("3.mp3", 2048);

  threshold = 1.5;
}
 
void draw()
{
  if (audioFiles[currAudio].isPlaying()) {
    background(0,100,0);
  } else {
    background(100,0,0);
  
  }
  stroke(255);
  // draw the waveforms
  sum = 0.0;
  for(int i = 0; i < in.bufferSize() - 1; i++)
  {
    sum += in.left.get(i)*100 +  in.right.get(i)*100;
    line(i, 50 + in.left.get(i)*50, i+1, 50 + in.left.get(i+1)*50);
    line(i, 150 + in.right.get(i)*50, i+1, 150 + in.right.get(i+1)*50);
  }

  currHigh = sum/in.bufferSize();
  if (currHigh > threshold && !audioFiles[currAudio].isPlaying()) {
    audioFiles[currAudio].play();
    trackStarted = true;
  } else if (trackStarted &&  !audioFiles[currAudio].isPlaying() ) {
    trackStarted = false;
    audioFiles[currAudio].loop(1);
    audioFiles[currAudio].pause();
    
    //increment audiotrack counter
    if (currAudio < audioCount-1) {
      currAudio += 1;
    } else {
     currAudio = 0; 
    }
  }
  
//  println(audioFiles[currAudio].isPlaying());
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
