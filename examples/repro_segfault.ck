// synchronize to period
.5::second => dur T;
T - (now % T) => now;

// connect patch
SinOsc s => dac;
.25 => s.gain;

// scale (in semitones)
[ 0, 2, 4, 7, 9 ] @=> int scale[];

// set the duration for the program to run
1::second => dur totalDuration;

// mark the start time
now => time startTime;

// loop with a time limit
while( now - startTime < totalDuration )
{
    // get note class
    scale[ Math.random2(0,4) ] => float freq;
    // get the final freq    
    Std.mtof( 21.0 + (Math.random2(0,3)*12 + freq) ) => s.freq;

    // advance time
    .25::T => now;
}
 