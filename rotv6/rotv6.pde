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
Rot rot,rotobject,rotworld;
PeasyCam pCamera;
PMatrix3D baseMat;

void setup()
{
  size(400, 400, P3D);

  //myClient = new Client(this, "fe80::215:8d00:17:a3df%eth1", 2020)
  myClient = new Client(this, "fe80::fdff:ffff:ffff:ffff%eth1",2020);
  println(myClient.ip());
  
  box = new Box(this);
  box.setSize(100,50,20);
  
  baseMat = g.getMatrix(baseMat);

  pCamera = new PeasyCam(this, 300);
  pCamera.lookAt(0, 0, 0, 110);
}

// ClientEvent message is generated when the server 
// sends data to an existing client.
void clientEvent(Client someClient)
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

      if (list.length == 5)
      {
        ts=Float.parseFloat(list[0]);
        q0=Float.parseFloat(list[1]);
        q1=Float.parseFloat(list[2]);
        q2=Float.parseFloat(list[3]);
        q3=Float.parseFloat(list[4]);
        rotobject=new Rot(q0,q1,q2,q3,true);
        rotworld =new Rot(RotOrder.XYZ,pCamera.getRotations()[0],
             pCamera.getRotations()[1],pCamera.getRotations()[2]);
        rot=rotobject.applyInverseTo(rotworld);
        box.rotateTo(rot.getAngles(RotOrder.XYZ));
      }

      System.out.println(myString);
    }
  }
}

void draw()
{
  background(20);
  pushMatrix();
  g.setMatrix(baseMat);
  // stage lighting
  directionalLight(200, 200, 200, 100, 150, -100);
  ambientLight(160, 160, 160);
  popMatrix();
  
  box.draw();
}

void keyPressed() {
}
