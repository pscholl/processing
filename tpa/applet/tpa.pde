//d2k2 24.09.2009  shows values from the TPA81 
//prestage for putting the sensor on the scan turrent

import processing.serial.*;

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

void setup()
{
  size(400, 400);

  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 57600);
  myPort.buffer(1);

}

void draw()
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

        fill(color(0.0,col,0.0));
        rect(x*dx,y*dy,dx,dy);
      }
  }
}

void keyPressed() {
  if( key == '3')
   run = true;
}
