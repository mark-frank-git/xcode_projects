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

#include "SerialPort.h"
#include <fcntl.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <IOKit/serial/ioss.h>


const int kBadFD  = -1;
// ############################# Class Constructor ###############################
// Class Constructor -- Constructor for the SerialPort class.
//
// Input:                       None
//
// Output:                      None
//
// Notes:
// ############################# Class Constructor ###############################
SerialPort::SerialPort()
:m_fileDescriptor(kBadFD)
{
  return;
}

// ############################# Class Destructor ###############################
// Class Destructor -- Destructor for the SerialPort class.
//
// Input:                       None
//
// Output:                      None
//
// Notes:
// ############################# Class Destructor ###############################
SerialPort::~SerialPort()
{
  ClosePort();
  return;
}

// ############################# Public Method ###############################
// Open the serial port
//
// Input:           None
//
// Output:          None
//
// Modified:        m_fileDescriptor
//
// Notes:
// ############################# Public Method ###############################
bool SerialPort::OpenPort(const char *portName)
{
  m_fileDescriptor          = OpenSerialPort(portName);
  if(m_fileDescriptor<0)
  {
    return false;
  }
  m_originalPortAttributes  = GetPortAttributes(m_fileDescriptor);
  if(!SetPortAttributes(m_fileDescriptor, m_originalPortAttributes))
  {
    close(m_fileDescriptor);
    m_fileDescriptor        = kBadFD;
    return false;
  }
  return true;
}


// ############################# Public Method ###############################
// Close the serial port
//
// Input:           None
//
// Output:          None
//
// Modified:        m_fileDescriptor
//
// Notes:
// ############################# Public Method ###############################
void SerialPort::ClosePort()
{
  if(m_fileDescriptor>0)
  {
    CloseSerialPort(m_fileDescriptor, m_originalPortAttributes);
    m_fileDescriptor  = kBadFD;
  }
}


// ############################# Private Method ###############################
// Write the input string to the serial port
//
// Input:           stringToWrite   : String to write to port
//
// Output:          None
//
// Return           true on no error
//
// Notes:
// ############################# Private Method ###############################
bool SerialPort::WriteString(const char* stringToWrite) const
{
  if(m_fileDescriptor<0)
  {
    return false;
  }
  // Send the string to the port
  int numBytes = (int)write(m_fileDescriptor, stringToWrite, strlen(stringToWrite));
  if (numBytes == -1)
  {
    printf("Error writing to serial port\n");
    return false;
  }

  return true;
}

// ############################# Public Method ###############################
// Read a string from the serial port
//
// Input:           None
//
// Output:          inputString : Received string
//
// Return           true on no error
//
// Notes:
// ############################# Public Method ###############################
bool SerialPort::ReadString(char*      inputString,
                            const int  stringLen)
                            const
{
  if(m_fileDescriptor<0)
  {
    return false;
  }
  // Read characters into our buffer until we get a CR
  char *bufPtr  = inputString;
  int numBytes  = 0;
  int index     = 0;
  int numTries  = 2;
  do
  {
    int maxRead  = (int)(stringLen - (bufPtr - inputString));
    numBytes     = (int)read(m_fileDescriptor, bufPtr, maxRead);
    if (numBytes == -1)
    {
      printf("Error reading from serial port");
      return false;
    }
    else if (numBytes > 0)
    {
      bufPtr   += numBytes;
      index    += numBytes;
      numTries  = 0;
    }
    if(HasOK(inputString))
    {
      break;
    }
    numTries--;
  } while (numBytes > 0 || numTries>0);
  //Add trailing \0
  if(index<(stringLen-1))
  {
    inputString[index]  = '\0';
  }
  return true;
}

// ############################# Private Method ###############################
// Open the serial port
//
// Input:           bsdPath   : Path to device file for opening, e.g., "/dev/cu.KeySerial1"
//
// Output:          None
//
// Return           Open file descriptor
//
// Modified:        m_fileDescriptor
//
// Notes:
// ############################# Private Method ###############################
int SerialPort::OpenSerialPort(const char *bsdPath) const
{
  // Open the serial port read/write, with no controlling terminal, and don't wait for a connection.
  // The O_NONBLOCK flag also causes subsequent I/O on the device to be non-blocking.
  // See open(2) <x-man-page://2/open> for details.
  
  int fileDescriptor = open(bsdPath, O_RDWR | O_NOCTTY);
  if (fileDescriptor == kBadFD)
  {
    return fileDescriptor;
  }
  
  // Note that open() follows POSIX semantics: multiple open() calls to the same file will succeed
  // unless the TIOCEXCL ioctl is issued. This will prevent additional opens except by root-owned
  // processes.
  // See tty(4) <x-man-page//4/tty> and ioctl(2) <x-man-page//2/ioctl> for details.
  
  if (ioctl(fileDescriptor, TIOCEXCL) == kBadFD)
  {
    printf("Error setting TIOCEXCL on %s\n", bsdPath);
    return kBadFD;
  }
  
  // Now that the device is open, clear the O_NONBLOCK flag so subsequent I/O will block.
  // See fcntl(2) <x-man-page//2/fcntl> for details.
  
  if (fcntl(fileDescriptor, F_SETFL, 0) == -1) {
    printf("Error clearing O_NONBLOCK %s\n", bsdPath);
    return kBadFD;
  }
  return fileDescriptor;
}

// ############################# Private Method ###############################
// Close the serial port with the given file descriptor
//
// Input:       fileDescriptor          : Open file descriptor
//              originalPortAttributes  : Original port attributes
//
// Output:                      None
//
// Notes:
// ############################# Private Method ###############################
void SerialPort::CloseSerialPort(const        int      fileDescriptor,
                                 const struct termios &originalPortAttributes)
                                 const
{
  // Block until all written output has been sent from the device.
  // Note that this call is simply passed on to the serial device driver.
  // See tcsendbreak(3) <x-man-page://3/tcsendbreak> for details.
  if (tcdrain(fileDescriptor) == -1)
  {
    printf("Error waiting for drain\n");
  }
  
  // Traditionally it is good practice to reset a serial port back to
  // the state in which you found it. This is why the original termios struct
  // was saved.
  if (tcsetattr(fileDescriptor, TCSANOW, &originalPortAttributes) == -1)
  {
    printf("Error resetting tty attributes\n");
  }
  
  close(fileDescriptor);
}

// ############################# Private Method ###############################
// Get the port attributes (baud rate, etc.)
//
// Input:           fileDescriptor   : Open file descriptor
//
// Output:          Port attributes
//
// Return           Port attributes
//
// Notes:
// ############################# Private Method ###############################
struct termios SerialPort::GetPortAttributes(const int fileDescriptor) const
{
  struct termios currentAttributes;
  // Get the current options and return them so we can restore the default settings later.
  if (tcgetattr(fileDescriptor, &currentAttributes) == kBadFD)
  {
    printf("Error getting tty attributes\n");
  }
  return currentAttributes;
}

// ############################# Private Method ###############################
// Set the port attributes (baud rate, etc.)
//
// Input:           fileDescriptor   : Open file descriptor
//
// Output:          None
//
// Return           true on no error
//
// Notes:
// ############################# Private Method ###############################
bool SerialPort::SetPortAttributes(const int             fileDescriptor,
                                   const struct termios &currentAttributes)
                                   const
{
  // Set raw input (non-canonical) mode, with reads blocking until either a single character
  // has been received or a one second timeout expires.
  // See tcsetattr(4) <x-man-page://4/tcsetattr> and termios(4) <x-man-page://4/termios> for details.
  struct termios options  = currentAttributes;
  
  cfmakeraw(&options);
  options.c_cc[VMIN]  = 0;
  options.c_cc[VTIME] = 10;
  
  // The baud rate, word length, and handshake options can be set as follows:
  cfsetspeed(&options, B9600);		// Set 9600 baud
  options.c_cflag |= (CS8 	    	// Use 8 bit words
                      //PARENB   | 	   No parity
                      //CCTS_OFLOW |   No CTS flow control of output
                      //CRTS_IFLOW	   No RTS flow control of input
                      );
  // Cause the new options to take effect immediately.
  if (tcsetattr(fileDescriptor, TCSANOW, &options) == -1)
  {
    printf("Error setting tty attributes\n");
    return false;
  }
  // Assert Data Terminal Ready (DTR)
  if (ioctl(fileDescriptor, TIOCSDTR) == -1)
  {
    printf("Error asserting DTR\n");
    return false;
  }
  // Clear Data Terminal Ready (DTR)
  if (ioctl(fileDescriptor, TIOCCDTR) == -1)
  {
    printf("Error clearing DTR\n");
    return false;
  }
  // Set the modem lines depending on the bits set in handshake
  int handshake = TIOCM_DTR | TIOCM_RTS | TIOCM_CTS | TIOCM_DSR;
  if (ioctl(fileDescriptor, TIOCMSET, &handshake) == -1)
  {
    printf("Error setting handshake lines\n");
    return false;
  }
  
  // To read the state of the modem lines, use the following ioctl.
  // See tty(4) <x-man-page//4/tty> and ioctl(2) <x-man-page//2/ioctl> for details.
  
  // Store the state of the modem lines in handshake
  if (ioctl(fileDescriptor, TIOCMGET, &handshake) == -1)
  {
    printf("Error storing handshake lines\n");
    return false;
  }
  
  unsigned long mics = 1UL;
  
  // Set the receive latency in microseconds. Serial drivers use this value to determine how often to
  // dequeue characters received by the hardware. Most applications don't need to set this value: if an
  // app reads lines of characters, the app can't do anything until the line termination character has been
  // received anyway. The most common applications which are sensitive to read latency are MIDI and IrDA
  // applications.
  
  if (ioctl(fileDescriptor, IOSSDATALAT, &mics) == -1)
  {
    // set latency to 1 microsecond
    printf("Error setting read latency\n");
    close(fileDescriptor);
    return false;
  }

  return true;
}

// ############################# Private Method ###############################
// Checks to see if we got an "OK\r\n" return in the input string
//
// Input:           inputString   : String to check
//
// Output:          None
//
// Return           true on CR
//
// TODO:            This is klugey.  Replace with strindex()
// ############################# Private Method ###############################
bool SerialPort::HasOK(
                      const char *inputString) //!< Checks if input string has CR
                      const
{
  if(sindex(inputString, "OK\r\n") != -1)
  {
    return true;
  }
  return false;
}
  
/********************************************************************
   * int sindex(char *s, char*t)                                      *
   *                                                                  *
   *    char    input variables                                       *
   *    -----------------------                                       *
   *   *s = first string                                              *
   *   *t = second string                                             *
   *                                                                  *
   * Find t in s, and return its index.  -1 if not found.             *
 ********************************************************************/
int SerialPort::sindex(const char *s, const char *t)
                       const
{
    int i, j, k;
    
    for(i=0; s[i] != '\0'; i++)
    {
      for(j=i, k=0; t[k] != '\0' && s[j]==t[k]; j++, k++)
        ;
      if(t[k] == '\0')
        return(i);
    }
    return(-1);
}
