import processing.core.*; 
import processing.xml.*; 

import processing.serial.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class tpa extends PApplet {

//d2k2 24.09.2009  shows values from the TPA81 
//prestage for putting the sensor on the scan turrent



Serial myPort;  // Create object from Serial class
String myString;

int[]  val = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1};
String[] list = null;

boolean result = false;
boolean run = false;

int mi=65536, ma=0;

long time;
long lastrun = 0;
long runT;

public void setup()
{
  size(400, 400);

  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 57600);
  myPort.buffer(1);

}

public void draw()
{
  if ( myPort.available() > 0)
  {
    myString = myPort.readStringUntil('\n');

    if (myString != null)
    {
      myString = myString.trim();
      list = split(myString, ' ');

      if (list.length != val.length)
      {
        System.out.println("incomplete");
        return;
      }

      for (int i=0; i<list.length && i<val.length; i++)
        val[i] = Integer.parseInt(list[i]);
    }
    else
      return;

    //System.out.print("listsize: ");
    //System.out.print(val.length);
    //System.out.println(list.length);
    //for (int i=0; i<val.length; i++)
    //{
    //  System.out.print(val[i]);
    //  System.out.print(" ");
    //}
    //System.out.println();

    rectMode(CORNER);
    noStroke();

    int dx=100, dy=100;

    if (min(val) < mi) mi = min(val);
    if (max(val) > ma) ma = max(val);

    for (int y=0; y<4; y++)
      for (int x=0; x<4; x++)
      {
        //float col = map(val[x*4+y],min(val),max(val),0,255);
        float col = map(val[x*4+y],mi,ma,0,255);

        fill(color(0.0f,col,0.0f));
        rect(x*dx,y*dy,dx,dy);
      }
  }
}

public void keyPressed() {
  if( key == '3')
   run = true;
}
  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#C4C4C4", "tpa" });
  }
}
