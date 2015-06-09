import hypermedia.net.*;

import processing.opengl.*;

import peasy.test.*;
import peasy.org.apache.commons.math.*;
import peasy.*;
import peasy.org.apache.commons.math.geometry.*;

import shapes3d.utils.*;
import shapes3d.animation.*;
import shapes3d.*;

import java.nio.*;
import java.util.Arrays;

Box box;
Rot nullrot=new Rot(1,0,0,0,false),
        rot=new Rot(1,0,0,0,false);
PeasyCam pCamera;
PMatrix3D baseMat;

UDP rx;

void setup()
{
  size(600, 600, P3D);

  try {
    rx = new UDP(this,5050);
    //rx.log(true);
    rx.listen(true);
  } catch (Exception e) {
    System.out.println(e);
    System.exit(-1);
  }

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
int seqnr = 0;
void receive(byte[] message)
{  
  if (message.length != 4*8) {
    System.out.println("nope");
    return;
  }
  
  float scalar,x,y,z;
  int seq = ByteBuffer.wrap( Arrays.copyOfRange(message,0,4) ).order(ByteOrder.LITTLE_ENDIAN).getInt();
  
  if (seq < seqnr) {
    System.err.println("uhoh");
    System.err.println(seq);
    System.err.println(seqnr);
  }
  
  scalar = ByteBuffer.wrap( Arrays.copyOfRange(message,4,8) ).order(ByteOrder.LITTLE_ENDIAN).getFloat();
  x = ByteBuffer.wrap( Arrays.copyOfRange(message,8,12) ).order(ByteOrder.LITTLE_ENDIAN).getFloat();
  y = ByteBuffer.wrap( Arrays.copyOfRange(message,12,16) ).order(ByteOrder.LITTLE_ENDIAN).getFloat();
  z = ByteBuffer.wrap( Arrays.copyOfRange(message,16,20) ).order(ByteOrder.LITTLE_ENDIAN).getFloat();
  
  rot=new Rot(scalar,y,-x,-z,true);
  //rot=rot.applyInverseTo(nullrot); // calculate inverse
}

void draw()
{
  background(20);
  
  //rxpacket();
  
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
  scale(1,1,1); // mirror on z-axis
  
  /* apply the rotation */
  rotateX(rot.getAngles(RotOrder.XYZ)[0]);
  rotateY(rot.getAngles(RotOrder.XYZ)[1]);
  rotateZ(rot.getAngles(RotOrder.XYZ)[2]);
  
  drawCoordinates(1);
  
  box.draw();
//  
//  buf.clear();
//  try {
//    DatagramPacket p = new DatagramPacket(new byte[50], 50);
//    sock.receive(p);
//    System.out.println(p);
//  } catch (Exception e) {
//    System.out.println("mehr");
//    System.out.println(e);
//  }
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
