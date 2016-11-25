#include <SoftwareSerial.h>
#include <Wire.h>
int mpu = 0x68; // I2C of the MPU-6050
float AcX, AcY, AcZ, Tmp, GyX, GyY, GyZ;
float Ac;
float AngDif;
const int motorPin =9;
int buff_amount = 20;
float sample_buffer [20];
int index = 0;
int isFog = 0;
int initStatus = 0;
float lastVal = 0;
float maxValue = -10000;
float minValue = -12000;
float maxTime = 0;
float lastMaxTime = -5000;
void setup() {
  pinMode(motorPin, OUTPUT);
 Wire.begin();
 Wire.beginTransmission(mpu);
 Wire.write(0x6B);
 Wire.write(0);
 Wire.endTransmission(true);
 Serial.begin(115200);
 

 maxValue = -10000;
 minValue = -12000;
 maxTime = 0;
 lastMaxTime = -5000;
 index = 0;
 initStatus = 0;
}
void actuate_motor() {
     analogWrite(motorPin, 245);
  delay(2000);  //light led for 5 secs //changed 5000 to 2000
     analogWrite(motorPin, 0);
}
void loop() {
 start_label:
 
 float timer = millis();
 Wire.beginTransmission(mpu);
 Wire.write(0x3B);
 Wire.endTransmission(false);
 Wire.requestFrom(mpu, 14, true);
 AcX = Wire.read()<<8|Wire.read();
 AcY = Wire.read()<<8|Wire.read();
 AcZ = Wire.read()<<8|Wire.read();
 Tmp = Wire.read()<<8|Wire.read();
 GyX = Wire.read()<<8|Wire.read();
 GyY = Wire.read()<<8|Wire.read();
 GyZ = Wire.read()<<8|Wire.read();
 float total = 0;
 if (index < 20) {
  sample_buffer[index] = AcY;
  index += 1;
  goto start_label;
 } else {
  for (int i=0; i<buff_amount-1; i++) {
    sample_buffer[i] = sample_buffer[i+1];  //shift the queue
    total += sample_buffer[i];
  }
  sample_buffer[19] = AcY; //add new value
  total += sample_buffer[19];
 }
 AcY = total/ (float) buff_amount;
  // put your main code here, to run repeatedly:
  
  if (AcY < -15000 && AcY > -20000 && initStatus == 0)  //consistent starting value
  {
      initStatus = 1;
      lastVal = AcY;
      goto start_label;
  }
  
  if (initStatus == 0)
  {
      lastVal = AcY;
      goto start_label;
  }
  
  if (AcY > -12000 && lastVal < -12000) //starting max shift
  {
      //find last min
      maxValue = AcY;
      maxTime = timer;
  } else if (AcY > -12000) //max shift
      {
        if (AcY > maxValue)
        {
          maxValue = AcY;
          maxTime = timer;
        }
      }
  else if (AcY < -12000 && lastVal > -12000) //end of max shift or start of min shift
      {
        //find last max
        if (lastMaxTime < 0)
        {
            lastMaxTime = maxTime;
            maxValue = -10000;
        }
        else {
            float timeDiff = maxTime - lastMaxTime;
            if (timeDiff < 700 && minValue > -25000) //changed 500 to 700
            {
              actuate_motor();
            }
            lastMaxTime = maxTime;
            maxValue = -10000;
            minValue = -12000;
        }
      }
      //minValue = AcY;
   else if (AcY < -12000) // min shift
      {
          if (AcY < minValue)
          {
              minValue = AcY;
          }
      }
      lastVal = AcY;
 Serial.print(AcX);
 Serial.print(",");
 Serial.print(AcY);
 Serial.print(",");
 Serial.print(AcZ);
 Serial.print(",");
 Serial.print(Tmp);
 Serial.print(",");
 Serial.print(GyX);
 Serial.print(",");
 Serial.print(GyY);
 Serial.print(",");
 Serial.print(GyZ);
 Serial.print(",");
 Serial.println(timer);
 delay(5);
 
}
