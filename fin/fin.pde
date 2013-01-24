//tal sznicer 

import SimpleOpenNI.*;
import processing.opengl.*;
import saito.objloader.*;

OBJModel test;

SimpleOpenNI  context;
boolean       autoCalib=true;
PVector head = new PVector();


//  Sensor position relative to screen in mm
PVector sensorPosition = new PVector(0, 300, -1500);

PVector defaultCameraPosition = new PVector(0, 0, 3000);

PVector currentCameraPosition = defaultCameraPosition;


void setup() {

  background(0);
  size(displayWidth, displayHeight, P3D);
  context = new SimpleOpenNI(this);

  // enable depthMap generation 
  if (context.enableDepth() == false)
  {
    println("Can't open the depthMap, maybe the camera is not connected!"); 
    
    if ( context.openFileRecording("C:\\Users\\tal\\GitHub\\FinalTexperience\\fin\\data\\1.oni") == false)
    {
      println("can't find recording !!!!");
      exit();
      return;
    }

  }

  // enable skeleton generation for all joints
  context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);


  smooth();

  // test
  test = new OBJModel(this, "test.obj", "relative", POLYGON);
  test.enableDebug();
  test.scale(1, -1, -1);
}

void draw() {

  // update the cam
  context.update();

  // draw the skeleton if it's available
  int[] userList = context.getUsers();
  int numTreckedUsers = 0;
  for (int i=0;i<userList.length;i++)  
  {
    if (context.isTrackingSkeleton(userList[i]))
    {
      numTreckedUsers++;
      context.getJointPositionSkeleton(userList[i], SimpleOpenNI.SKEL_HEAD, head);
      head.x = -head.x;
      head.y = -head.y;

      println(head);
    }
  }

beginCamera();
PVector target = new PVector();
if (numTreckedUsers > 0)
{
target = head;
}else {
  target = defaultCameraPosition ;
}

currentCameraPosition.lerp(target,0.1);

  camera(
  //  ((float(mouseX) / width) - 0.5) * 2000,   ((float(mouseY) / height) - 0.5) * 2000,   2000.0, //mouseY / height * 2000, //move camera
  currentCameraPosition.x + sensorPosition.x, currentCameraPosition.y + sensorPosition.y, currentCameraPosition.z + sensorPosition.z, 
  0, 0, 0, //
  0, 1.0, 0);

  scale(1, -1, 1);
  background(0);
  lights();
  directionalLight(255, 255, 255, 0, 1, 0);
  directionalLight(255, 255, 255, 0, 0, 1);
  directionalLight(255, 255, 255, 1, 0, 0);
  perspective(PI / 3, float(width)/float(height), 1, 1000000);

  //XYZ AXIS
pushMatrix();
  pushStyle();  
  int A = 10000;
  strokeWeight(1);
  //X green
  stroke(255, 0, 0);
  line(0, 0, 0, A, 0, 0);
  //y blue
  stroke(0, 255, 0);
  line(0, 0, 0, 0, A, 0);
  //Z red
  stroke(0, 0, 255);
  line(0, 0, 0, 0, 0, A);
  popStyle();
popMatrix();

  // test
  pushMatrix();
  translate(0, 0, 0);
  test.draw();
//  fill(255,0,0);
//  sphere(300);
  popMatrix();

  //sphere

  int N = 7;

  for (int i = 0; i < N; i++)
    for (int j = 0; j < N; j++)
      for (int k = 0; k < N; k++)
      {
        pushMatrix();
        fill(255 * i / N, 255 * j / N, 255 * k / N);
        translate((i-N/2)*500, (j-N/2)*500, (k-N/2)*500);
          box(50);
        popMatrix();
      }

  pushMatrix();
  //translate(head.x, head.y, head.z);  
  sphere(10);
  popMatrix();
  
  endCamera();
}




// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(int userId)
{
  println("onNewUser - userId: " + userId);
  println("  start pose detection");

  if (autoCalib)
    context.requestCalibrationSkeleton(userId, true);
  else    
    context.startPoseDetection("Psi", userId);
}

void onLostUser(int userId)
{
  println("onLostUser - userId: " + userId);
}

void onExitUser(int userId)
{
  println("onExitUser - userId: " + userId);
}

void onReEnterUser(int userId)
{
  println("onReEnterUser - userId: " + userId);
}

void onStartCalibration(int userId)
{
  println("onStartCalibration - userId: " + userId);
}

void onEndCalibration(int userId, boolean successfull)
{
  println("onEndCalibration - userId: " + userId + ", successfull: " + successfull);

  if (successfull) 
  { 
    println("  User calibrated !!!");
    context.startTrackingSkeleton(userId);
  } 
  else 
  { 
    println("  Failed to calibrate user !!!");
    println("  Start pose detection");
    context.startPoseDetection("Psi", userId);
  }
}

void onStartPose(String pose, int userId)
{
  println("onStartPose - userId: " + userId + ", pose: " + pose);
  println(" stop pose detection");

  context.stopPoseDetection(userId); 
  context.requestCalibrationSkeleton(userId, true);
}

void onEndPose(String pose, int userId)
{
  println("onEndPose - userId: " + userId + ", pose: " + pose);
}

