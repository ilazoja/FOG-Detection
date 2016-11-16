#include <SoftwareSerial.h>
#include <Wire.h>
int mpu = 0x68; // I2C of the MPU-6050
float AcX, AcY, AcZ, Tmp, GyX, GyY, GyZ;
float Ac;
float AngDif;
int led = 9;

void setup() {
 Wire.begin();
 Wire.beginTransmission(mpu);
 Wire.write(0x6B);
 Wire.write(0);
 Wire.endTransmission(true);
 Serial.begin(9600);
}

void loop() {
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
 Serial.println(GyZ);

 delay(30);

 
}

