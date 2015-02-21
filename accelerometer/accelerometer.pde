// Maurice Ribble 
// 6-28-2009
// http://www.glacialwanderer.com/hobbyrobotics

// This takes data off the serial port and graphs it.
// There is an option to log this data to a file.

// I wrote an arduino app that sends data in the format expected by this app.
// The arduino app sends accelerometer and gyroscope data.

import processing.serial.*;
int Y_AXIS = 5;

// Globals
int g_winW             = 820;   // Window Width
int g_winH             = 600;   // Window Height
boolean g_dumpToFile   = false;  // Dumps data to c:\\output.txt in a comma seperated format (easy to import into Excel)
boolean g_enableFilter = false;  // Enables simple filter to help smooth out data.

cDataArray g_xAccel    = new cDataArray(100);
cDataArray g_yAccel    = new cDataArray(100);
cDataArray g_zAccel    = new cDataArray(100);
cGraph g_graph         = new cGraph(10, 190, 800, 400);
Serial g_serial;
PFont  g_font;
p
void setup()
{
  size(g_winW, g_winH, P2D);

  println(Serial.list());
  g_serial = new Serial(this, Serial.list()[0], 115200, 'N', 8, 1.0);
  g_font = loadFont("ArialMT-20.vlw");
  textFont(g_font, 20);
  
  // This draws the graph key info
  strokeWeight(1.5);
  stroke(255, 0, 0);     line(20, 430, 35, 430);
  stroke(0, 255, 0);     line(20, 450, 35, 450);
  stroke(0, 0, 255);     line(20, 470, 35, 470);

  fill(0, 0, 0);
  text("xAccel", 40, 440);
  text("yAccel", 40, 460);
  text("zAccel", 40, 480);
}

//boolean watchZ = false;
void draw()
{
  // We need to read in all the avilable data so graphing doesn't lag behind
  while (g_serial.available() > 0)
  {
    processSerialData();
  }

  strokeWeight(1);
  fill(255, 255, 255);
  g_graph.drawGraphBox();
  
  strokeWeight(1.5);
  stroke(255, 0, 0);
  g_graph.drawLine(g_xAccel, -Y_AXIS, Y_AXIS);
  stroke(0, 255, 0);
  g_graph.drawLine(g_yAccel, -Y_AXIS, Y_AXIS);
  stroke(0, 0, 255);
  g_graph.drawLine(g_zAccel, -Y_AXIS, Y_AXIS);
/*  stroke(255, 255, 0);
  g_graph.drawLine(g_vRef, 0, 2048);
  stroke(255, 0, 255);
  g_graph.drawLine(g_xRate, 0, 2048);
  stroke(0, 255, 255);
  g_graph.drawLine(g_yRate, 0, 2048);*/  
}

// This reads in one set of the data from the serial port
String myString = "";
void processSerialData()
{
  while (g_serial.available() > 0) 
  {
    char newChar = g_serial.readChar();
    //text(newChar, 40, 480);
    if(newChar != '\n')
      myString += newChar;

    if(newChar == '\n')    
    {   
      if(myString.length() != 53)
      {
        //text(myString.length(), 40, 500);        
        myString = "";
        break;
      }

    //text(myString, 40, 520);
    //stroke(0, 0, 0);
    strokeWeight(0);
    fill(200,200,200);
    rectMode(CORNERS);
    rect(150, 490, 300, 420);

  // This reads in one set of data
  float xAccel = Float.parseFloat(myString.substring(17,23).trim());    
  float yAccel = Float.parseFloat(myString.substring(23,29).trim());
  float zAccel = Float.parseFloat(myString.substring(29,35).trim()); 
  
  //int xCal = Integer.parseInt(myString.substring(35,41).trim());    
  //int yCal = Integer.parseInt(myString.substring(41,47).trim());
  //int zCal = Integer.parseInt(myString.substring(47,53).trim()); 

  //float xAcc = (xAccel - xCal ) * 0.0037;
  //float yAcc = (yAccel - yCal ) * 0.0037;
  //float zAcc = (zAccel - zCal ) * 0.0037;

    g_xAccel.addVal(xAccel);
    g_yAccel.addVal(yAccel);
    g_zAccel.addVal(zAccel);

  fill(0, 0, 0);
  text(xAccel, 200, 440);
  text(yAccel, 200, 460);
  text(zAccel, 200, 480);

    myString = "";
    }
    
  }
}
// This class helps mangage the arrays of data I need to keep around for graphing.
class cDataArray
{
  float[] m_data;
  int m_maxSize;
  int m_startIndex = 0;
  int m_endIndex = 0;
  int m_curSize;
  
  cDataArray(int maxSize)
  {
    m_maxSize = maxSize;
    m_data = new float[maxSize];
  }
  
  void addVal(float val)
  {
    if (g_enableFilter && (m_curSize != 0))
    {
      int indx;
      
      if (m_endIndex == 0)
        indx = m_maxSize-1;
      else
        indx = m_endIndex - 1;
      
      m_data[m_endIndex] = getVal(indx)*.5 + val*.5;
    }
    else
    {
      m_data[m_endIndex] = val;
    }
    
    m_endIndex = (m_endIndex+1)%m_maxSize;
    if (m_curSize == m_maxSize)
    {
      m_startIndex = (m_startIndex+1)%m_maxSize;
    }
    else
    {
      m_curSize++;
    }
  }
  
  float getVal(int index)
  {
    return m_data[(m_startIndex+index)%m_maxSize];
  }
  
  int getCurSize()
  {
    return m_curSize;
  }
  
  int getMaxSize()
  {
    return m_maxSize;
  }
}

// This class takes the data and helps graph it
class cGraph
{
  float m_gWidth, m_gHeight;
  float m_gLeft, m_gBottom, m_gRight, m_gTop;
  
  cGraph(float x, float y, float w, float h)
  {
    m_gWidth     = w;
    m_gHeight    = h;
    m_gLeft      = x;
    m_gBottom    = g_winH - y;
    m_gRight     = x + w;
    m_gTop       = g_winH - y - h;
  }
  
  void drawGraphBox()
  {
    stroke(0, 0, 0);
    rectMode(CORNERS);
    rect(m_gLeft, m_gBottom, m_gRight, m_gTop);
  }
  
  void drawLine(cDataArray data, float minRange, float maxRange)
  {
    float graphMultX = m_gWidth/data.getMaxSize();
    float graphMultY = m_gHeight/(maxRange-minRange);
    
    //if(data.getCurSize() < 1) return;
    
    float x0 = m_gLeft;
    float y0 = m_gBottom-((data.getVal(0)-minRange)*graphMultY);

//    if(data.getCurSize() > 100) watchZ = true;
    for(int i=0; i<data.getCurSize()-1; ++i)
    {
      //x0 = i*graphMultX+m_gLeft;
      //y0 = m_gBottom-((data.getVal(i)-minRange)*graphMultY);
      float x1 = (i+1)*graphMultX+m_gLeft;
      float y1 = m_gBottom-((data.getVal(i+1)-minRange)*graphMultY);
      line(x0, y0, x1, y1);
      x0 = x1;
      y0 = y1;
    }
  }
}
