#ifndef CustomCare_CCInterface_h
#define CustomCare_CCInterface_h
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

enum eGetCommands
{
  eGetCurrentModeReq,               //!< Gets the current mode
  eGetModeTitlesReq,                //!< Gets a list of all mode titles
  eGetUnitUsageReq,                 //!< Gets the unit usage log
  eGetDateAndTimeReq,               //!< Gets the date and time data from unit
  eGetDateAndTimeGroupReq,          //!< Gets date and time group of data??
  eGetDirectionsReq,                //!< Gets the practitioner's directions to patient
  eGetSerialNumberReq,              //!< Gets the unit's serial number
  eGetTreatmentSettingsReq,         //!< Gets the treatment settings
  eGetBatteryVoltageReq,            //!< Gets the battery voltage
  eGetSerialNumberAndFWVersionReq,  //!< Gets the serial number of the unit and firmware version
  eSizeOfGets                       //!< Number of get commands
};
enum eSetCommands
{
  eWakeUpCmd,                       //!< Wakes up unit.  Doesn't appear to work
  eSetCurrentModeCmd,               //!< Sets current mode 1 through 10??  Note setting mode = 1, erases all
  //!< modes since modes must be entered sequentially
  eSetModeDisplayTitlesCmd,         //!< Sets the character title of the mode
  eSetMaxTreatmentMinsCmd,          //!< Sets max treatment time in minutes (0{unlimited treat} to 9999)
  eSetResetUnitUsageCmd,            //!< Resets the unit usage cmd
  eSetTreatmentParameterCmd,        //!< Sets individual treatments
  eSetDateAndTimeCmd,               //!< Sets current date and time
  eSetExpirationDateCmd,            //!< Sets expiration date of treatments
  eSetDirectionsCmd,                //!< Sets the doctor's directions to the patient
  eSetEnableUnitCmd,                //!< Enables comm with unit. Else, only eGetSerialNumberReq works
  eSetLockUnitCmd,                  //!< Locks unit from comm
  eSetDeleteTreatmentsCmd,          //!< Zeros out the current treatments
  eSetToggleEchoCmd,                //!< Toggle echo of comms from off to on, and then from on to off
  eSetResetIdleTimeoutCmd           //!< Resets the idle time-out back to 4 minutes
};

enum eErrorCodes
{
  eNoError,                         //!< No error when init() is run
  ePortNotReady,                    //!< Serial port not ready (e.g., no driver installed)
  eCustomCareNotReady               //!< CustomCare not ready (e.g., went to sleep)
};

struct DataTreatment
{
  char m_waveShape[2];              //!< "G", "M", "S", or "P", gentle, mild, sharp, pulse
  int  m_f1;                        //!< 10 times frequency 1 in Hertz
  int  m_f2;                        //!< 10 times frequency 2 in Hertz
  int  m_current;                   //!< Current in micro-amps from 20 to 720 by 10
  int  m_time;                      //!< Time in minutes
  char m_polarity[2];               //!< "N", "P", "A", negative, positive, alternating
};
// Forward declarations
class SerialPort;

const int kSerialDigits = 8;
class CCInterface
{
  //
  // Public methods:
  //
public:
  /********************************
   * Constructors, destructor     *
   *******************************/
  explicit CCInterface();
  ~CCInterface();
  
  /********************************
   * Initializing the interface   *
   ********************************/
  eErrorCodes init();
  void        closePort();
 
  /********************************
   * Setting parameters in unit   *
   ********************************/
  bool    SetDateAndTime(const int year,            //!< Year in 2 digits
                         const int month,           //!< Month from 1 to 12
                         const int day,             //!< Day of month
                         const int dayOfWeek,       //!< Day of week
                         const int hour,            //!< Hour from 0 to 23
                         const int minute,          //!< Minute from 0 to 59
                         const int second)          //!< Second from 0 to 59
                         const;
  bool    SetExpirationDate(const int year,         //!< Year in 2 digits
                          const int month,          //!< Month from 1 to 12
                          const int day)            //!< Day of month
                          const;
  bool    SetModeAndTitle(const int   mode,         //!< Mode #
                          const char *title)        //!< Title to display
                          const;
  bool    SetTreatmentData(
                          const int            number,
                          const DataTreatment& treatment)
                          const;
  bool    SetMaximumTreatmentTime(                  //!< Max treatment time
                          const int   minutes)
                          const;
  bool    SetDoctorDirections(
                          const int   number,       //!< Number in sequence
                          const char *direction)    //!< Direction to display
                          const;
  bool    LockUnit()      const;                    //!< Lock the unit from further RS-232 commands
  bool    ClearDoctorDirections() const;            //!< Clear all stored directions
  bool    ClearTreatments()       const;            //!< Clear all stored treatments
  
  /********************************
   * Querying the custom care     *
   ********************************/
  bool    GetBatteryVoltage(double& voltage)
                            const;                  //!< Return voltage
  
  /*******************************
   * Sending Commands            *
   *******************************/
  
private:
  SerialPort*  m_serialPort;
  char         m_serialNumber[kSerialDigits+1];     //!< Serial number of unit
  bool         m_serialValid;                       //!< We have a valid serial number
  
  // Private Methods:
  bool        WakeUpUnit() const;                   //!< Send the wake up command
  bool        GetSerialNumber(char* serialString)   //!< Get Serial Number
                              const;
  bool        EnableUnit(const char *serialString)  //!< Enable unit to receive further commands
                         const;
  bool        ResetTimeout()       const;           //!< Reset unit time out
  bool        CheckForOkResponse() const;           //!< Check for OK response
  void        AddIntegerToString(char *inputString, //!< Build up a string from integers
                           const int   twoDigitInt)
                           const;
  const char *itoa(              int val,           //!< Convert integer to string
                           const int base=10)
                           const;

};

#endif
