/************************************************************************
 *                                                                      *
 * This subclass of object implements a class for interfacing the the   *
 * custom care unit.  That is, it sends commands and gets output from   *
 * the custom care unit.                                                *
 *                                                                      *
 * File:CCInterface.h                                                   *
 *                                                                      *
 * Revision history:                                                    *
 *  1. September 01, 2014 - Started.                                    *
 ************************************************************************/

#include "CCInterface.h"
#include "SerialPort.h"
#include "CCCmdStrings.h"
#include <string>
#include <stdlib.h>
#include <unistd.h>                   //For sleep function

const int kMaxCmdLength   = 1024;
const int kMaxRespLength  = 24;
// ############################# Class Constructor ###############################
// Class Constructor -- Constructor for the CCInterface.h class.
//
// Input:                       None
//
// Output:                      None
//
// Notes:
// ############################# Class Constructor ###############################
CCInterface::CCInterface()
            :m_serialPort(0),
             m_serialValid(false)
{
}

// ############################# Class Destructor ###############################
// Class Destructor -- Destructor for the CCInterface class.
//
// Input:                       None
//
// Output:                      None
//
// ############################# Class Destructor ###############################
CCInterface::~CCInterface()
{
  delete m_serialPort;
  m_serialPort  = NULL;
  return;
}

// ############################# Public Method ###############################
// Initializes the interface
//
// Input:                       None
//
// Output:                      None
//
// Notes:
// ############################# Public Method ###############################
eErrorCodes CCInterface::init()
{
  if(m_serialPort == NULL)
  {
    m_serialPort    = new SerialPort();
    if(!m_serialPort->OpenPort("/dev/cu.KeySerial1"))
    {
      return ePortNotReady;
    }
    if(!WakeUpUnit())
    {
      return eCustomCareNotReady;
    }
    m_serialValid   = GetSerialNumber(m_serialNumber);
    if(!m_serialValid)
    {
      return eCustomCareNotReady;
    }
    if(!EnableUnit(m_serialNumber))
    {
      return eCustomCareNotReady;
    }
  }
  return eNoError;
}


// ############################# Public Method ##################################
// closePort - Close the Port
//
// Input:                       None
//
// Output:                      None
//
// ############################# Class Destructor ###############################
void CCInterface::closePort()
{
  delete m_serialPort;
  m_serialPort  = NULL;
  return;
}

// ############################# Public Method ###############################
// Sets the time in the unit
//
// Input:           year, month, day, etc.  See defs below.
//
// Output:          None
//
// Return           true on no error
// ############################# Public Method ###############################
bool CCInterface::SetDateAndTime(const int year,        //!< Year in 2 digits
                                 const int month,       //!< Month from 1 to 12
                                 const int day,         //!< Day of month
                                 const int dayOfWeek,   //!< Day of week
                                 const int hour,        //!< Hour from 0 to 23
                                 const int minute,      //!< Minute from 0 to 59
                                 const int second)      //!< Second from 0 to 59
                                 const
{
  char dateString[kMaxCmdLength];
  dateString[0]   = '\0';
  strcat(dateString, kSetDateAndTimeStr);
  AddIntegerToString(dateString, year);
  AddIntegerToString(dateString, month);
  AddIntegerToString(dateString, day);
  AddIntegerToString(dateString, dayOfWeek);
  AddIntegerToString(dateString, hour);
  AddIntegerToString(dateString, minute);
  AddIntegerToString(dateString, second);
  strcat(dateString, "\r");
  if(!m_serialPort->WriteString(dateString))
  {
    return false;
  }
  return CheckForOkResponse();
}

// ############################# Public Method ###############################
// Sets the expiration date in the unit
//
// Input:           year, month, day, etc.  See defs below.
//
// Output:          None
//
// Return           true on no error
// ############################# Public Method ###############################
bool CCInterface::SetExpirationDate(const int year,   //!< Year in 2 digits
                                        const int month,  //!< Month from 1 to 12
                                        const int day)    //!< Day of month
                                        const
{
  char dateString[kMaxCmdLength];
  dateString[0]   = '\0';
  strcat(dateString, kSetExpirationDateStr);
  AddIntegerToString(dateString, year);
  AddIntegerToString(dateString, month);
  AddIntegerToString(dateString, day);
  strcat(dateString, "\r");
  if(!m_serialPort->WriteString(dateString))
  {
    return false;
  }
  return CheckForOkResponse();  
}

// ############################# Public Method ###############################
// Sets the mode number and corresponding title
//
// Input:     mode  : Mode number
//            title : Mode title
//
// Output:          None
//
// Return           true on no error
// ############################# Public Method ###############################
bool CCInterface::SetModeAndTitle(const int   mode,   //!< Mode #
                                  const char *title)  //!< Title to display
                                  const
{
  char modeString[kMaxCmdLength];
  modeString[0]   = '\0';
  strcat(modeString, kSetCurrentModeStr);
  strcat(modeString, itoa(mode));
  strcat(modeString, "\r");
  if(!m_serialPort->WriteString(modeString))
  {
    return false;
  }
  if(!CheckForOkResponse())
  {
    return false;
  }
  //Now, write mode title
  modeString[0]   = '\0';
  strcat(modeString, kSetCurrentModeTitleStr);
  strcat(modeString, itoa(mode));
  strcat(modeString, "=");
  strcat(modeString, title);
  strcat(modeString, "\r");
  if(!m_serialPort->WriteString(modeString))
  {
    return false;
  }
  return CheckForOkResponse();
}

// ############################# Public Method ###############################
// Sets the treatment data
//
// Input:   number    : Number of the treatment
//          treatment : Structure of treatment data
//
// Output:              : None
//
// Return           true on no error
// ############################# Public Method ###############################
bool CCInterface::SetTreatmentData(const int            number,
                                   const DataTreatment& treatment) const
{
  char treatmentString[kMaxCmdLength];
  treatmentString[0]   = '\0';
  strcat(treatmentString, kSetTreatmentParameterStr);
  strcat(treatmentString, itoa(number));
  strcat(treatmentString, "=");
  strcat(treatmentString, treatment.m_waveShape);
  strcat(treatmentString, ",");
  strcat(treatmentString, itoa(treatment.m_f1));
  strcat(treatmentString, ",");
  strcat(treatmentString, itoa(treatment.m_f2));
  strcat(treatmentString, ",");
  strcat(treatmentString, itoa(treatment.m_current));
  strcat(treatmentString, ",");
  strcat(treatmentString, itoa(treatment.m_time));
  strcat(treatmentString, ",");
  strcat(treatmentString, treatment.m_polarity);
  strcat(treatmentString, ",A\r");
  if(!m_serialPort->WriteString(treatmentString))
  {
    return false;
  }
  return CheckForOkResponse();
}

// ############################# Public Method ###############################
// Sets the maximum number of minutes that can be used by patient
//
// Input:     minutes  : Max minutes
//
// Output:          None
//
// Return           true on no error
// ############################# Public Method ###############################
bool CCInterface::SetMaximumTreatmentTime(
                                  const int   minutes)  //!< # minutes
                                  const
{
  char minuteString[kMaxCmdLength];
  minuteString[0]   = '\0';
  strcat(minuteString, kSetMaxTreatmentMinsStr);
  strcat(minuteString, itoa(minutes));
  strcat(minuteString, "\r");
  if(!m_serialPort->WriteString(minuteString))
  {
    return false;
  }
  return CheckForOkResponse();
}

const int kMaxDirectionLength = 40;
// ############################# Public Method ###############################
// Sets the doctor's directions
//
// Input:     number  : Direction number: 1 to nn?? (nn not spec'd in Hatley's doc)
//            title : Mode title
//
// Output:          None
//
// Return           true on no error
// ############################# Public Method ###############################
bool CCInterface::SetDoctorDirections(const int   number,    //!< Number in sequence
                                     const char *direction) //!< Title to display
                                     const
{
  char directionString[kMaxCmdLength];
  directionString[0]  = '\0';
  strcat(directionString, kSetDirectionsStr);
  strcat(directionString, itoa(number));
  strcat(directionString, "=");
  strncat(directionString, direction, kMaxDirectionLength);
  strcat(directionString, "\r");
  if(!m_serialPort->WriteString(directionString))
  {
    return false;
  }
  return CheckForOkResponse();
}

// ############################# Public Method ###############################
// Locks the unit from further RS-232 commands
//
// Input:           None
//
// Output:          None
//
// Return           true on no error
// ############################# Public Method ###############################
bool CCInterface::LockUnit() const  //!< Lock unit from further RS-232 commands
{
  if(!m_serialPort->WriteString(kSetLockUnitStr))
  {
    return false;
  }
  return CheckForOkResponse();
}

// ############################# Public Method ###############################
// Clears all stored doctor's directions
//
// Input:           None
//
// Output:          None
//
// Return           true on no error
// ############################# Public Method ###############################
bool CCInterface::ClearDoctorDirections() //!< Clear all directions
                  const
{
  char clearString[kMaxCmdLength];
  clearString[0]    = '\0';
  strcat(clearString, kClearDirectionsStr);
  strcat(clearString, m_serialNumber);
  strcat(clearString, "\r");
  if(!m_serialPort->WriteString(clearString))
  {
    return false;
  }
  return CheckForOkResponse();
}

static int kNUMBER_CHECKS = 300;
// ############################# Public Method ###############################
// Clears all stored treatments
//
// Input:           None
//
// Output:          None
//
// Return           true on no error
// ############################# Public Method ###############################
bool CCInterface::ClearTreatments() //!< Clear all treatments
                  const
{
  //First reset time out:
  if(!ResetTimeout())
  {
    return false;
  }
  char clearString[kMaxCmdLength];
  clearString[0]    = '\0';
  strcat(clearString, kClearTreatmentsStr);
  strcat(clearString, m_serialNumber);
  strcat(clearString, "\r");
  if(!m_serialPort->WriteString(clearString))
  {
    return false;
  }
  bool responseOK = false;
  for(int i=0; i<kNUMBER_CHECKS; i++)
  {
    responseOK    = CheckForOkResponse();
    if(responseOK)
    {
      break;
    }
    usleep(10000);
  }
  return responseOK;
}

const int kVoltageSize  = 4;
// ############################# Public Method ###############################
// Gets the battery voltage from the unit
//
// Input:           None
//
// Output:          voltage
//
// Return           true on no error
// ############################# Public Method ###############################
bool CCInterface::GetBatteryVoltage(double& voltage)
                                    const                 //!< Return voltage
{
  if(!m_serialPort->WriteString(kGetStrings[eGetBatteryVoltageReq]))
  {
    return false;
  }
  char batteryVoltageString[kMaxRespLength];
  if(!m_serialPort->ReadString(batteryVoltageString, kMaxRespLength))
  {
    return false;
  }
  std::string stdString = batteryVoltageString;
  size_t index          = stdString.find("V");
  if(index == std::string::npos)
  {
    return false;
  }
  //Convert to double
  batteryVoltageString[index] = '\0';
  index                      -= kVoltageSize;
  if(index<=0)
  {
    return false;
  }
  voltage                     = atof(&batteryVoltageString[index]);
  return true;
}

// ############################# Public Method ###############################
// Query the custom care
//
// Input:           getCmd        : Query command
//
// Output:          returnString  : String containing the query results
//
// Return:          true on no error
//
// ############################# Public Method ###############################
bool    QueryCustomCare(const eGetCommands getCmd,
                        char  *            returnString)
{
  return true;
}

// ############################# Private Method ###############################
// Send the wake up command to the unit
//
// Input:           None
//
// Output:          None
//
// Return           true on no error
//
// ############################# Private Method ###############################
bool CCInterface::WakeUpUnit() const
{
  if(!m_serialPort->WriteString("\r"))
  {
    return false;
  }
  return CheckForOkResponse();
}

const int kSerialMaxLength  = 48;
const int kSerialMinLength  = 12;
// ############################# Private Method ###############################
// Return the serial number of the custom care unit
//
// Input:           None
//
// Output:          None
//
// Return           True on no error
// ############################# Private Method ###############################
bool CCInterface::GetSerialNumber(char *serialString) const
{
  if(!m_serialPort->WriteString(kGetStrings[eGetSerialNumberReq]))
  {
    return false;
  }
  char serialNumberString[kSerialMaxLength];
  if(!m_serialPort->ReadString(serialNumberString, kSerialMaxLength))
  {
    return false;
  }
  std::string stdString = serialNumberString;
  if(strlen(serialNumberString)<kSerialMinLength)
  {
    return false;
  }
  size_t index          = stdString.find("\r\n");
  if(index != 0)
  {
    return false;
  }
  //Copy into output
  for(int i=0; i<kSerialDigits; i++)
  {
    serialString[i] = serialNumberString[i+2];  //Skip "\r\n"
  }
  serialString[kSerialDigits] = '\0';
  return true;
}

// ############################# Private Method ###############################
// Enable the custom care unit to receive further commands
//
// Input:           serialString  : Serial number string
//
// Output:          None
//
// Return:          true on no error
//
// ############################# Private Method ###############################
bool CCInterface::EnableUnit(const char *serialString)
                             const
{
  char enableString[kMaxCmdLength];
  enableString[0]       = '\0';
  strcat(enableString, kSetEnableUnitStr);
  strcat(enableString, serialString);
  size_t index          = strlen(enableString);
  enableString[index++] = '\r';
  enableString[index++] = '\0';
  if(!m_serialPort->WriteString(enableString))
  {
    return false;
  }
  return CheckForOkResponse();
}

// ############################# Private Method ###############################
// Reset the power off time out of unit
//
// Input:           None
//
// Output:          None
//
// Return           true on no error
// ############################# Private Method ###############################
bool CCInterface::ResetTimeout() const
{
  if(!m_serialPort->WriteString(kSetResetIdleTimeStr))
  {
    return false;
  }
  return CheckForOkResponse();
}

const int kMaxOkString  = 48;
// ############################# Private Method ###############################
// Checks to see if we got an "OK" response from Custom Care
//
// Input:           None
//
// Output:          None
//
// Return           true on OK response
// ############################# Private Method ###############################
bool CCInterface::CheckForOkResponse() const
{
  char okResponseString[kMaxOkString];
  if(!m_serialPort->ReadString(okResponseString, kMaxOkString))
  {
    return false;
  }
  std::string stdString = okResponseString;
  size_t index          = stdString.find("OK");
  if(index == std::string::npos)
  {
    return false;
  }
  return true;
}

const int kTwoDigitSize = 3;
// ############################# Private Method ###############################
// Helper function to build a string from 2 digit integers
//
// Input:           None
//
// Output:          None
//
// Return           true on no error
// ############################# Private Method ###############################
void CCInterface::AddIntegerToString(char *inputString, // Build up a string from integers
                               const int   twoDigitInt)
                               const
{
  char twoDigitString[kTwoDigitSize];
  sprintf(twoDigitString, "%02d", twoDigitInt);
  strcat(inputString, twoDigitString);
}

// ############################# Private Method ###############################
// Helper function to convert an integer to a C string
//
// Input:     val       : input integer
//            base      : for example, 10
//
// Output:    None
//
// Return     converted string
// ############################# Private Method ###############################
const char*  CCInterface::itoa(      int val,
                               const int base)
                               const
{
  static char buf[32] = {0};
  int i = 30;
  for(; val && i ; --i, val /= base)
  {
    buf[i] = "0123456789abcdef"[val % base];
  }
  return &buf[i+1];
}