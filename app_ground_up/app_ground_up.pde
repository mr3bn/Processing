import processing.serial.*;

int g_width = 2200;
int g_height = 1400;
float[] lines = new float[3];
float[] buttons = new float[5];
float[] text_x = new float[2];
float[] text_y = new float[5];
float[] text_y_centers = new float[3];
String time;
int minutes_in, seconds_in;
String printMin, printSec;
int time_index = 0;

String printDuration = "";
String printAltitude = "";
String printTemperature = "";
String printHumidity = "";
String printWind = "";
String printPressure = "";

float alt_pane_x = 20;
float alt_pane_y = 20;
float alt_pane_width = (g_width/2) - 20;
float alt_pane_height = g_height-80;
cGraph altitude_pane = new cGraph(alt_pane_x, alt_pane_y, alt_pane_width, alt_pane_height, 4);

float time_pane_x = (g_width/2) + 50;
float time_pane_y = 20;
float time_pane_width = (g_width/2) - 100;
float time_pane_height = (g_height/2) - 10;
cGraph time_pane = new cGraph(time_pane_x, time_pane_y, time_pane_width, time_pane_height, 1);

float button_width = (g_width - 100) / 12;
float button_height = (g_height/20);

float remaining_horizontal_space = g_width - (20 + alt_pane_width);
float remaining_vertical_space = g_height - (time_pane_height + 50 + button_height);
float text_width = remaining_horizontal_space / 3;
float text_height = remaining_vertical_space / 6;

int max_time = (int) time_pane_width;

cDataArray altitude_store = new cDataArray(max_time);
cDataArray seconds_store = new cDataArray(max_time);

cDataArray temperature_store = new cDataArray(max_time);
cDataArray a_temperature_store = new cDataArray(max_time);
cDataArray t_temperature_store = new cDataArray(max_time);

cDataArray humidity_store = new cDataArray(max_time);
cDataArray a_humidity_store = new cDataArray(max_time);
cDataArray t_humidity_store = new cDataArray(max_time);

cDataArray wind_store = new cDataArray(max_time);
cDataArray a_wind_store = new cDataArray(max_time);
cDataArray t_wind_store = new cDataArray(max_time);

cDataArray pressure_store = new cDataArray(max_time);
cDataArray a_pressure_store = new cDataArray(max_time);
cDataArray t_pressure_store = new cDataArray(max_time);

Serial port;

void setup() {
  size(g_width, g_height, P2D);
  port = new Serial(this, port.list()[0], 9600);
  rectMode(CORNER);
  
  for(int i = 0; i < 5; i++) {
    buttons[i] = (((float)(i)/5)*time_pane_width) + time_pane_x;
    rect(buttons[i], time_pane_y + time_pane_height + 30, button_width, button_height, 15);
  } 
  
  text_x[0] = float(g_width/2);
  text_x[1] = float((3*g_width)/4);
  
  for(int i = 0; i < 5; i++) {
    text_y[i] = ((((float)i*remaining_vertical_space)/5) + time_pane_height + 50 + button_height);
  }
  
  for(int i = 0; i < 3; i++) {
    text_y_centers[i] = ((text_y[i+1] + text_y[i+2]) / 2);
  }
}

void draw() {
  background(200, 200, 200);
  while(port.available() > 0) {
    processSerialData();
  }
  strokeWeight(2);
  fill(255, 255, 255);
  altitude_pane.drawGraphBox();
  time_pane.drawGraphBox();
  strokeWeight(7);
  stroke(255, 0, 0);
  altitude_pane.drawPoints(a_temperature_store, altitude_store);
  time_pane.drawPoints(seconds_store, t_temperature_store);
  stroke(0, 255, 0);
  altitude_pane.drawPoints(a_humidity_store, altitude_store);
  time_pane.drawPoints(seconds_store, t_humidity_store);
  stroke(0, 0, 255);
  altitude_pane.drawPoints(a_wind_store, altitude_store);
  time_pane.drawPoints(seconds_store, t_wind_store);
  stroke(0, 0, 0);
  altitude_pane.drawPoints(a_pressure_store, altitude_store);
  time_pane.drawPoints(seconds_store, t_pressure_store);
  
  //draw text boxes here
  textAlign(LEFT);
  textSize(32);
  fill(0, 0, 0);
  text(printDuration, text_x[0], text_y_centers[0], text_width, text_height);
  text(printAltitude, text_x[1], text_y_centers[0], text_width, text_height);
  text(printTemperature, text_x[0], text_y_centers[1], text_width, text_height);
  text(printHumidity, text_x[1], text_y_centers[1], text_width, text_height);
  text(printWind, text_x[0], text_y_centers[2], text_width, text_height);
  text(printPressure, text_x[1], text_y_centers[2], text_width, text_height);
}

String str = "";

void processSerialData() {

  float altitude;
  float temperature;
  float a_temperature;
  float t_temperature;
  float humidity;
  float a_humidity;
  float t_humidity;
  float wind;
  float a_wind;
  float t_wind;
  float pressure;
  float pressure_adj;
  float a_pressure;
  float t_pressure;
  
  printDuration = "Flight duration - ";
  printAltitude = "Altitude: ";
  printTemperature = "Temperature: ";
  printHumidity = "Humidity: ";
  printWind = "Wind speed: ";
  printPressure = "Air pressure: ";

  while(port.available() > 0) {
    char c = port.readChar();
    if(c != '\n') {
      str += c;
    }
    else if(c == '\n') {
      
      /**serial output of "processing_test" is time (HH:MM:SS), altitude, temperature, humidity, windSpeed, pressure
      * altitude range is 0-400, this is the DOMAIN for the ALTIDUDE graph
      * temperature range is 0-30
      * humidity range is 0-100
      * wind range is 0-10
      * pressure range is 950-1020
      * graph range for altitude domain are the horizontal bounds of graph1, 10-610
      * graph range for the time domain are the vertical bounds of graph2, 425-825
      * all variables except altitude need to be mapped to both altitude and time domains; altitude can remain 0-400
      **/
      
      String[] str_nums = split(str, ",");
      time = str_nums[0];
      //hour = float(time.split(":")[0]);
      //minute = float(time.split(":")[1]);
      //second = float(time.split(":")[2]);
      
      time_index++;
      seconds_store.addValue(((time_index + 1) % time_pane_width));
      minutes_in = time_index / 60;
      if(minutes_in < 10) {
        printMin = "0" + str(minutes_in);
      }
      else {
        printMin = str(minutes_in);
      }
      seconds_in = time_index % 60;
      if(seconds_in < 10) {
        printSec = "0" + str(seconds_in);
      }
      else {
        printSec = str(seconds_in);
      }
      String time_elapsed = printMin + ":" + printSec;
      printDuration += time_elapsed;
      
      altitude = float(str_nums[1]);
      printAltitude += str(altitude);
      printAltitude += " m";
      altitude_store.addValue(altitude);
      
      temperature = float(str_nums[2]);
      printTemperature += str(temperature);
      printTemperature += " C";
      temperature_store.addValue(temperature);
      a_temperature = ((temperature*alt_pane_width)/120);
      a_temperature_store.addValue(a_temperature);
      t_temperature = ((temperature*time_pane_height)/30);
      t_temperature_store.addValue(t_temperature);
      
      humidity = float(str_nums[3]);
      printHumidity += str(humidity);
      printHumidity += "%";
      humidity_store.addValue(humidity);
      a_humidity = ((humidity*alt_pane_width)/400) + (alt_pane_width/4);
      a_humidity_store.addValue(a_humidity);
      t_humidity = ((humidity*time_pane_height)/100);
      t_humidity_store.addValue(t_humidity);
      
      wind = float(str_nums[4]);
      wind_store.addValue(wind);
      printWind += str(wind);
      printWind += " m/s";
      a_wind = ((wind*alt_pane_width)/40) + (alt_pane_width/2);
      a_wind_store.addValue(a_wind);
      t_wind = ((wind*time_pane_height)/10);
      t_wind_store.addValue(t_wind);
      
      pressure = float(str_nums[5]);
      pressure_adj = pressure - 950;
      pressure_store.addValue(pressure);
      printPressure += str(pressure);
      printPressure += " Pa";
      a_pressure = ((pressure_adj*alt_pane_width)/280) + ((3*alt_pane_width)/4);
      a_pressure_store.addValue(a_pressure);
      t_pressure = ((pressure_adj*time_pane_height)/70);
      t_pressure_store.addValue(t_pressure);
      
      println();
      
      str = "";
      break;
    }
  }
}

class cButton {
  float button_width, button_height, button_left, button_bottom, button_right, button_top;
  boolean pressed;
  String text;
  
  cButton(float x, float y, float w, float h, String str, color c) {
    button_width = w;
    button_height = h;
    button_left = x;
    button_bottom = y + h;
    button_right = x + w;
    button_top = y;
    text = str;
  }
  
  void drawButton() {
    stroke(0, 0, 0);
    //fill();
    rectMode(CORNER);
    rect(button_left, button_top, button_width, button_height);
  }
}

class cDataArray {
  float[] data_holder;
  int maxSize;
  int startIndex = 0;
  int endIndex = 0;
  int currentSize = 0;
  
  cDataArray(int m) {
    maxSize = m;
    data_holder = new float[m];
  }
  
  void addValue(float v) {
    data_holder[endIndex] = v;
    
    endIndex = (endIndex + 1) % maxSize;
    
    if(currentSize == maxSize) {
      startIndex = (startIndex + 1) % maxSize;
    }
    else {
      currentSize++;
    }
  }
  
  float getValue(int i) {
    return data_holder[(startIndex + i) % maxSize];
  }
  
  int getCurrentSize() {
    return currentSize;
  }
  
  int getMaxSize() {
    return maxSize;
  }
  
  int getCurrentValue() {
    if(currentSize < maxSize) {
      return currentSize;
    }
    else {
      return startIndex;
    }
  }
}

class cGraph {
  float graph_width, graph_height, graph_left, graph_bottom, graph_right, graph_top;
  int numPanes;
  
  cGraph(float x, float y, float w, float h, int panes) {
    graph_width = w;
    graph_height = h;
    graph_left = x;
    graph_bottom = y + h; 
    graph_right = x + w;
    graph_top = y;
    numPanes = panes;
  }
  
  void drawGraphBox() {
    stroke(0, 0, 0);
    rectMode(CORNER);
    rect(graph_left, graph_top, graph_width, graph_height);
    if(numPanes > 0) {
      float[] lines = new float[numPanes];
      for(int i = 0; i < numPanes; i++) {
        lines[i] = (((float)(i+1)/4)*alt_pane_width) + 20;
        line(lines[i], 20, lines[i], g_height-60);
      }
    }
  }
  void drawPoints(cDataArray x_data, cDataArray y_data) {
    float x;
    float y;
    
    for(int i = 0; i < x_data.getCurrentSize(); i++) {
      x = x_data.getValue(i) + graph_left;
      y = graph_bottom - y_data.getValue(i);
      point(x, y);
    }
  }
  
  void drawLine(cDataArray x_data, cDataArray y_data) {
    float x0;
    float y0;
    float x1;
    float y1;
                                                                                                                                                                                                                                                                                                                                                     for(int i = 0; i < x_data.getCurrentSize() - 1; i++) {
      x0 = x_data.getValue(i) + graph_left;
      y0 = graph_bottom - y_data.getValue(i);
      x1 = x_data.getValue(i+1) + graph_left;
      y1 = graph_bottom - y_data.getValue(i+1);
      line(x0, y0, x1, y1);
    }
  }
}
