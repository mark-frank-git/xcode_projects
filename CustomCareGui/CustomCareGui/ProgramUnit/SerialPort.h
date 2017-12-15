#ifndef CustomCare_SerialPort_h
#define CustomCare_SerialPort_h
/************************************************************************
 *                                                                      *
 * This subclass of object implements a class for reading and writing   *
 * to a serial port.  Currently, it only supports a serial port         *
 * connected via a Tripp-Lite USB-Serial adapter.                       *
 *                                                                      *
 * File:SerialPort.h                                                    *
 *                                                                      *
 * Revision history:                                                    *
 *  1. August 30, 2014 - Started.                                       *
 ************************************************************************/
#include <string>
#include <termios.h>

class SerialPort
{
  //
  // Public methods:
  //
public:
  /********************************
   * Constructors, destructor     *
   *******************************/
  explicit SerialPort();
  ~SerialPort();
    
  /********************************
   * Opening/Closing              *
   ********************************/
  bool    OpenPort(const char* PortName);
  void    ClosePort();
    
  /*******************************
   * Writing/Reading to/from port*
   *******************************/
  bool    WriteString(const char* stringToWrite) const;
  bool    ReadString (char*       inputString,
                      const int   stringLen)     const;
  
private:
  int     m_fileDescriptor;                 // Pointer to open file descriptor
  struct termios m_originalPortAttributes;  // Original port attributes for restore
  
// Private Methods:
  int            OpenSerialPort(   const char           *bsdPath) const;
  void           CloseSerialPort(  const int             fileDescriptor,
                                   const struct termios &originalPortAttributes)
  const;
  struct termios GetPortAttributes(const int             fileDescriptor) const;
  bool           SetPortAttributes(const int             fileDescriptor,
                                   const struct termios &currentAttributes)
                                   const;
  bool           HasOK            (const
                                   char *inputString) //!< Checks if input string has CR
                                   const;
  int            sindex(const char *s, const char *t) const;

  
};

#endif
