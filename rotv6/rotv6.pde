import processing.opengl.*;

import peasy.test.*;
import peasy.org.apache.commons.math.*;
import peasy.*;
import peasy.org.apache.commons.math.geometry.*;

import shapes3d.utils.*;
import shapes3d.animation.*;
import shapes3d.*;
import processing.net.*;

Client myClient;

Box box;
Rot nullrot=new Rot(1,0,0,0,false),
        rot=new Rot(1,0,0,0,false);
PeasyCam pCamera;
PMatrix3D baseMat;

void setup()
{
  size(600, 600, P3D);

  //myClient = new Client(this, "fe80::215:8d00:17:a3df%eth1", 2020)
  myClient = new Client(this, "fe80::fdff:ffff:ffff:ffff%eth1",2020);
  //println(myClient.ip());
  
  box = new Box(this);
  box.setSize(100,50,20);
  baseMat = g.getMatrix(baseMat);
  
  pCamera = new PeasyCam(this, 300);
  pCamera.rotateX(PI/2);
  pCamera.lookAt(0, 0, 0, 280);
}

void keyPressed() {
}

// ClientEvent message is generated when the server 
// sends data to an existing client.
void clientEvent(Client myClient)
{
  float ts,q0,q1,q2,q3;
    
  if ( myClient.available() > 0)
  {
    String myString = myClient.readStringUntil('\n');

    if (myString != null)
    {
      String[] list;
      myString = myString.trim();
      list = split(myString, ' ');

      if (list.length >= 5)
      {
        ts=Float.parseFloat(list[0]);
        q0=Float.parseFloat(list[1]);
        q1=Float.parseFloat(list[2]);
        q2=Float.parseFloat(list[3]);
        q3=Float.parseFloat(list[4]);
        rot=new Rot(q0,q1,q2,q3,true);
        rot=rot.applyInverseTo(nullrot); // calculate inverse
      }

      System.out.println(myString);
    }
  }
}

void draw()
{
  background(20);
  
  // stage lighting
  pushMatrix();
  g.setMatrix(baseMat);
  directionalLight(200, 200, 200, 100, 150, -100);
  ambientLight(160, 160, 160);
  popMatrix();
  
  /* to align the axes of the jNode to the processing world 
   * coordinates, we have to:
   *  (a) mirror the z-axis
   *  (b) use the inverse rotation (which is calculated in clientEvent) */
  scale(1,1,-1); // mirror on z-axis
  
  /* apply the rotation */
  rotateX(rot.getAngles(RotOrder.XYZ)[0]);
  rotateY(rot.getAngles(RotOrder.XYZ)[1]);
  rotateZ(rot.getAngles(RotOrder.XYZ)[2]);
  
  drawCoordinates(1);
  
  box.draw();
}

void drawCoordinates(int x)
{
  strokeWeight(x);
  stroke(255,0,0);
  line(0,0,0,400,0,0);
  stroke(0,255,0);
  line(0,0,0,0,400,0);
  stroke(0,0,255);
  line(0,0,0,0,0,400);
}
