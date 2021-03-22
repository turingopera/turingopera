import g4p_controls.*;

import ddf.minim.*;
import ddf.minim.ugens.*;

// Goal: convert a Bezier curve with added symbols into a "singing" voice

PFont font;

float[] bPoints = { 
  85, 120, 
  300, 250, 
  325, 490, 
  326, 60, 
  300, 250
};

int steps = 20;
int thisStep = 0;

Minim minim;
AudioOutput out;
SineInstrument sine;

void setup()
{
  font = loadFont("Dialog.bold-48.vlw");
  textFont(font);
  size(500, 500); 
  frameRate(30);
  minim = new Minim(this);  
  out = minim.getLineOut();
  out.setTempo( 180 );

  sine = new SineInstrument(440);
  out.playNote(0, 6, sine);
}

void draw()
{
  background(0);
  stroke(0);
  noFill();
  stroke(200);
  text("step: "+thisStep, 20, 40);

  bezier(bPoints[0], bPoints[1], bPoints[2], bPoints[3], bPoints[4], 
    bPoints[5], bPoints[6], bPoints[7]);

  fill(255);  
  out.playNote(200, 2, sine);
  for (int i = 0; i <= steps; i++) {
    if (i == thisStep)
    {
      float t = i / float(steps);
      float x = bezierPoint(
        bPoints[0], 
        bPoints[2], 
        bPoints[4], 
        bPoints[6], 
        t);
      float y = bezierPoint(
        bPoints[1], 
        bPoints[3], 
        bPoints[5], 
        bPoints[7], 
        t);

      ellipse(x, y, 5, 5);

      sine.wave.setFrequency(height-y);
    }
  }
  thisStep++;
  if (thisStep >= steps) {
    thisStep = 0;
  }
}



class SineInstrument implements Instrument
{
  Oscil wave;
  Line  ampEnv;

  SineInstrument( float frequency )
  {
    // make a sine wave oscillator
    // the amplitude is zero because 
    // we are going to patch a Line to it anyway
    wave   = new Oscil( frequency, 0, Waves.SINE );
    ampEnv = new Line();
    ampEnv.patch( wave.amplitude );
  }

  // this is called by the sequencer when this instrument
  // should start making sound. the duration is expressed in seconds.
  void noteOn( float duration )
  {
    // start the amplitude envelope
    ampEnv.activate( duration, .5f, 0 );
    // attach the oscil to the output so it makes sound
    wave.patch( out );
    println("on");
  }

  // this is called by the sequencer when the instrument should
  // stop making sound
  void noteOff()
  {
    wave.unpatch( out );
    exit();
  }
}







class ToneInstrument implements Instrument
{
  // create all variables that must be used througout the class
  Oscil sineOsc;
  ADSR  adsr;
  int f = 0;

  void draw()
  {
    stroke(200);
    line (0, 0, 40, 40);
  }

  // constructor for this instrument
  ToneInstrument( float frequency, float amplitude )
  {    
    // create new instances of any UGen objects as necessary
    sineOsc = new Oscil( frequency, amplitude, Waves.TRIANGLE );
    adsr = new ADSR( 1, 1, 1, 1, 1 );
    f = int(frequency);
    // patch everything together up to the final output
    sineOsc.patch( adsr );
  }

  // every instrument must have a noteOn( float ) method
  void noteOn( float dur )
  {
    // turn on the ADSR
    adsr.noteOn();
    // patch to the output
    adsr.patch( out );
    fill(255);
    ellipse(400-f, 30, 15, 15);
  }

  // every instrument must have a noteOff() method
  void noteOff()
  {
    // tell the ADSR to unpatch after the release is finished
    adsr.unpatchAfterRelease( out );
    // call the noteOff 
    adsr.noteOff();
    exit();
  }
}
