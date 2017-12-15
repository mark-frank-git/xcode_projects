//
//  CsvWriter.cpp
//  CustomCareGui
//
//  Created by Mark Frank on 1/5/15.
//  Copyright (c) 2015 MarkFrank. All rights reserved.
//

#include "CsvWriter.h"
#include <iostream>
#include <sstream>

using namespace std;
// ############################# Class Constructor #################################
// CsvWriter -- Constructor for the CsvWriter class
// Input:               None
// Output:              None
// ############################# Class Constructor #################################
CsvWriter::CsvWriter()
{
  return;
}

// ############################# Class Destructor #################################
// ~CsvWriter -- Destructor for the CsvWriter class
// Input:               None
// Output:              None
// ############################# Class Constructor #################################
CsvWriter::~CsvWriter()
{
  return;
}

// ############################# Public Method #####################################
// writeCsvFile -- Read the protocols to a csv file
// Input:               fileName  : File to write protocols
//                      protocols : Vector of protocols
// Output:              None
// Return:              true on no error
// ############################# Class Constructor #################################
bool CsvWriter::writeCsvFile(const char *fileName, vectorOfProtocols &protocols)
{
  ofstream outfile(fileName);
  if(!outfile.is_open())
  {
    return false;
  }
  writeHeader(outfile);
  //Write the protocols
  for(int i=0; i<protocols.size(); i++)
  {
    writePrograms(i, protocols[i].m_protocolName, protocols[i].m_protocolNote,
                     protocols[i].m_protocolType, protocols[i].m_programs,     outfile);
  }
  outfile.close();
  return true;
}

// ############################# Private Method ####################################
// writeHeader -- Writes a header to the output stream
// Input:               outfile  : output stream
// Output:              None
// Return:              None
// ############################# Class Constructor #################################
void CsvWriter::writeHeader(ofstream &outfile) const
{
  outfile << "User,Title,Level 1,Level 2 ,Wave,Freq 1,Freq 2,Current,Time,Units,Polarity,RapControl,User-Standard";
  outfile << endl;
}

// ############################# Private Method ####################################
// writePrograms -- Writes a set of programs to the output stream
// Input:               protocolNumber  : number of protocol number
//                      protocolName    : name of protocol
//                      protocolNote    : note for this protocol
//                      programs        : vector of programs
//                      outfile         : stream to write programs
// Output:              None
// Return:              A protocol
// ############################# Class Constructor #################################
void CsvWriter::writePrograms(const int                protocolNumber,
                              const std::string&       protocolName,
                              const std::string&       protocolNote,
                              const std::string&       protocolType,
                              const vectorOfPrograms&  programs,
                                    ofstream&          outfile)
                              const
{
  std::string numberString    = protocolStringFromNumber(protocolNumber);
  for(int i=0; i<programs.size(); i++)
  {
    std::string programString = numberString;
    programString            += std::to_string(i+1);
    outfile << programString << ",Program ";
    int startIndex            = 0;
    outfile << subNameFrom(protocolName, startIndex)          << "       ,Section ";
    outfile << subNameFrom(protocolName, startIndex)          << "       ,Sub-Prg ";
    outfile << subNameFrom(protocolName, startIndex)          << "       ,";
    outfile << getWaveshapeFromString(programs[i].m_waveShape)<< ", ";
    outfile << programs[i].m_freq1     << ", " << programs[i].m_freq2 << ", ";
    outfile << programs[i].m_current   << ", " << programs[i].m_duration << ", " << "Minutes,";
    outfile << getPolarityFromString(programs[i].m_polarity)  << ", ";
    outfile << "Notrapid"              << ", " << protocolNote;
    outfile << ", "                    << protocolType        << endl;
  }
}

// ############################# Private Method ####################################
// protocolStringFromNumber -- Returns a protocol string from a protocol number
// Input:               protocolNumber  : protocol number
// Output:              None
// Return:              Protocol string
// ############################# Class Constructor #################################
std::string CsvWriter::protocolStringFromNumber(const int protocolNumber)
                                                const
{
  int hundreds              = protocolNumber/100;
  int tens                  = (protocolNumber - hundreds*100)/10;
  int ones                  = (protocolNumber - hundreds*100 - tens*10);
  hundreds++;
  tens++;
  ones++;
  std::string numberString  = std::to_string(hundreds);
  numberString             += "-";
  numberString             += std::to_string(tens);
  numberString             += "-";
  numberString             += std::to_string(ones);
  numberString             += "-";
  return numberString;
}

const int kMAX_NAME    = 32;
// ############################# Private Method ####################################
// sectionNameFrom -- Return program, section, sub-program name given the protocol name
// Input:               protocolName  : protocol name
// Input/Output:        startIndex    : index to start looking for section, last index on output
// Return:              Section name
// Note:                An example protocol name is "P:MB:A"
//                      Some of the fields may be missing, like "P:MB"
// ############################# Class Constructor #################################
std::string CsvWriter::subNameFrom(const std::string& protocolName,
                                                 int& startIndex)
                                       const
{
  char nameChars[kMAX_NAME];
  if(startIndex >= protocolName.size())
  {
    nameChars[0] = ' ';
    nameChars[1] = '\0';
  }
  else
  {
    int k         = 0;
    nameChars[0]  = '\0';
    while( startIndex<protocolName.size() && protocolName[startIndex] != ':' && k<kMAX_NAME)
    {
      nameChars[k]      = protocolName[startIndex];
      startIndex++;
      k++;
    }
    startIndex++;
    nameChars[k]        = '\0';
  }
  std::string subName   = nameChars;
  return subName;
}

// ############################# Private Method ####################################
// getWaveshapeFromString -- Gets the waveshap from the input string
// Input:     inputString:  Input string
// Output:    None
// Return:    The polarity string
// To Do:     Make this more robust (DoesContainString)
// ############################# Class Constructor #################################
std::string CsvWriter::getWaveshapeFromString(const std::string& inputString)const
{
  std::string rtnString = "";
  if(inputString == "Sharp")
  {
    rtnString = "Sharp ";
  }
  else if(inputString == "Mild")
  {
    rtnString = "Mild  ";
  }
  else if(inputString == "Gentle")
  {
    rtnString = "Gentle";
  }
  else if(inputString == "Pulse")
  {
    rtnString = "Pulse ";
  }
  return rtnString;
}


// ############################# Private Method ####################################
// getPolarityFromString -- Gets the polarity from the input string
// Input:     inputString:  Input string
// Output:    None
// Return:    The polarity string
// ############################# Class Constructor #################################
std::string CsvWriter::getPolarityFromString(const std::string& inputString)const
{
  std::string rtnString = "";
  if(inputString == "Alternating")
  {
    rtnString = "Alternate";
  }
  else if(inputString == "Positive")
  {
    rtnString = "Positive ";
  }
  else if(inputString == "Negative")
  {
    rtnString = "Negative ";
  }
  return rtnString;
}

