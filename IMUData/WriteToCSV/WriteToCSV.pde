 
import processing.serial.*;
Serial myPort; //creates a software serial port on which you will listen to Arduino
Table table; //table where we will read in and store values. You can name it something more creative!
 
int numReadings = 500; //keeps track of how many readings you'd like to take before writing the file. 
int readingCounter = 0; //counts each reading to compare to numReadings. 
boolean start = false;
int IsFOG = 0;
 
String fileName;
void setup()
{
  
  table = new Table();
  String portName = Serial.list()[1]; 
  //CAUTION: your Arduino port number is probably different! Mine happened to be 1. Use a "handshake" sketch to figure out and test which port number your Arduino is talking on. A "handshake" establishes that Arduino and Processing are listening/talking on the same port.
  //Here's a link to a basic handshake tutorial: https://processing.org/tutorials/overview/
  
  myPort = new Serial(this, "COM9", 115200); //set up your port to listen to the serial port
   
  table.addColumn("id"); //This column stores a unique identifier for each record. We will just count up from 0 - so your first reading will be ID 0, your second will be ID 1, etc. 
  
  
  //the following are dummy columns for each data value. Add as many columns as you have data values. Customize the names as needed. Make sure they are in the same order as the order that Arduino is sending them!
  table.addColumn("AcX");
  table.addColumn("AcY");
  table.addColumn("AcZ");
  table.addColumn("Tmp");
  table.addColumn("GyX");
  table.addColumn("GyY");
  table.addColumn("GyZ");
  table.addColumn("Timer");
  table.addColumn("IsFOG");
 
}
 
void serialEvent(Serial myPort){
  if(keyPressed == true && keyCode == SHIFT)
  {
    start = true;
    IsFOG = 0;
  }
  String val = myPort.readStringUntil('\n'); //The newline separator separates each Arduino loop. We will parse the data by each newline separator. 

  if (start == true)
  {
    if (val!= null) { //We have a reading! Record it.
    val = trim(val); //gets rid of any whitespace or Unicode nonbreakable space
    println(val); //Optional, useful for debugging. If you see this, you know data is being sent. Delete if  you like. 
    float sensorVals[] = float(split(val, ',')); //parses the packet from Arduino and places the valeus into the sensorVals array. I am assuming floats. Change the data type to match the datatype coming from Arduino. 
    if (sensorVals.length == 8)
    {
      TableRow newRow = table.addRow(); //add a row for this new reading
    newRow.setInt("id", table.lastRowIndex());//record a unique identifier (the row's index)
    
    //record sensor information. Customize the names so they match your sensor column names. 
    newRow.setFloat("AcX", sensorVals[0]);
    newRow.setFloat("AcY", sensorVals[1]);
    newRow.setFloat("AcZ", sensorVals[2]);
    newRow.setFloat("Tmp", sensorVals[3]);
    newRow.setFloat("GyX", sensorVals[4]);
    newRow.setFloat("GyY", sensorVals[5]);
    newRow.setFloat("GyZ", sensorVals[6]);
    newRow.setFloat("Timer", sensorVals[7]);

    newRow.setFloat("IsFOG", IsFOG);
    
    readingCounter++; //optional, use if you'd like to write your file every numReadings reading cycles
    
    //saves the table as a csv in the same folder as the sketch every numReadings. 
    
    }
    
   }
   
  }
  if (keyCode == ENTER && start == true)//The % is a modulus, a math operator that signifies remainder after division. The if statement checks if readingCounter is a multiple of numReadings (the remainder of readingCounter/numReadings is 0)
    {
      println("WORK YOU PIECE OF SHIT FUCK TITS PENIS");
      fileName = str(year()) + str(month()) + str(day()) + str(hour()) + str(minute()) + str(second()); //this filename is of the form year+month+day+readingCounter
      saveTable(table, fileName, "csv"); //Woo! save it to your computer. It is ready for all your spreadsheet dreams. 
      table.clearRows();
      start = false;
    }
   
   //<>//
}
 
void draw()
{ 
   //visualize your sensor data in real time here! In the future we hope to add some cool and useful graphic displays that can be tuned to different ranges of values. 
}

void keyReleased()
{
  if (key == '/'){
      if (IsFOG == 0) IsFOG = 1;
      if (IsFOG == 1) IsFOG = 0;
    }
}