//d2k2 24.09.2009  shows values from the TPA81 
//prestage for putting the sensor on the scan turrent

import processing.serial.*;

Serial myPort;  // Create object from Serial class
String myString;

final int arrx = 4;
final int arry = 4;

int dx, dy;
int[][]  val  = new int[arrx][arry];
String[] list = null;

boolean run = false;

int mi=65536, ma=0;
//int mi=20, ma=40;

void setup()
{
  size(400, 400, P2D);

  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 115200);
  myPort.bufferUntil('\n');
}

void serialEvent(Serial myPort)
{
  if ( myPort.available() > 0)
  {
    myString = myPort.readStringUntil('\n');

    if (myString != null)
    {
      myString = myString.trim();
      list = split(myString, ' ');

      if (list.length != arrx*arry)
      {
        System.out.print("list: ");
        System.out.print(list.length);
        System.out.print(" arr: ");
        System.out.print(arrx*arry);
        System.out.println(" incomplete");
        return;
      }

      for (int i=0; i<list.length; i++)
      {
        int x = i%arrx,
            y = i/arrx;

        val[x][y] = Integer.parseInt(list[i]);

        if (val[x][y] < mi) mi = val[x][y];
        if (val[x][y] > ma) ma = val[x][y];
      }
    }
    else
      return;
  }
}

float mymap(int x)
{
  float mu = 25000.0,
        sigma = 10210.0,
        factor = 6400012.0;

  return 1./(sqrt(2*PI)*sigma) * exp(-.5*pow((x-mu)/sigma,2));
}

void draw()
{
    rectMode(CORNER);
    //noStroke();
    noFill();

    dx = width/arrx;
    dy = height/arry;

    for (int x=0; x<arrx; x++)
      for (int y=0; y<arry; y++)
      {
        //float col = map(val[x*4+y],min(val),max(val),0,255);
        float col = map(val[x][y],mi,ma,0,255);
        //float col = mymap(val[x*4+y]);
        //System.out.print(val[x*4+y]);
        //System.out.print(col);

        fill(color(0.0,col,0.0));
        rect(x*dx,y*dy,dx,dy);
      }
}

void keyPressed() {
  if( key == '3')
   run = true;
}
