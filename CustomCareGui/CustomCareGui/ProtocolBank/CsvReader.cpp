//
//  CsvReader.cpp
//  CustomCareGui
//
//  Created by Mark Frank on 1/5/15.
//  Copyright (c) 2015 MarkFrank. All rights reserved.
//

#include "CsvReader.h"
#include <iostream>
#include <sstream>

using namespace std;
// ############################# Class Constructor #################################
// CsvReader -- Constructor for the CsvReader class
// Input:               None
// Output:              None
// ############################# Class Constructor #################################
CsvReader::CsvReader()
          :m_numberProtocols(0)
{
  return;
}

// ############################# Class Destructor #################################
// ~CsvReader -- Destructor for the CsvReader class
// Input:               None
// Output:              None
// ############################# Class Constructor #################################
CsvReader::~CsvReader()
{
  return;
}

const int kWORDS_IN_LINE  = 12;
// ############################# Public Method #####################################
// readCsvFile -- Read the csv file
// Input:               fileName  : File to read in
// Output:              None
// Return:              true on no error
// ############################# Class Constructor #################################
bool CsvReader::readCsvFile(const char* fileName)
{
  ifstream infile(fileName);
  string line;
  //Read header line
  if(!getline(infile, line))
    return false;
  //read all of the words in each line into allWords
  vector<string> allWords;
  int numberLines         = 0;
  m_numberProtocols       = 0;
  string oldProtocolName  = "";
  m_protocolNames.clear();
  m_protocols.clear();
  CppProgram  newProgram;
  CppProtocol newProtocol;
  while(getWordsInLine(infile, allWords) >= kWORDS_IN_LINE)
  {
    string protocolName;
    if(!getProtocolName(allWords, protocolName))
      break;
    if(!getNewProgram(allWords, newProgram))
      break;
    string protocolType;
    getProtocolType(allWords, protocolType);
    if(protocolName != oldProtocolName)
    {
      m_numberProtocols++;
      m_protocolNames.push_back(protocolName);
      if(oldProtocolName != "")
      {
        m_protocols.push_back(newProtocol);
      }
      newProtocol.ClearPrograms();
      newProtocol.SetProtocolName(protocolName);
      newProtocol.SetProtocolType(protocolType);
      oldProtocolName = protocolName;
    }
    newProtocol.AddNewProgram(newProgram);
    numberLines++;
    allWords.clear();
  }
  m_protocols.push_back(newProtocol);
  infile.close();
  if(numberLines > 0)
    return true;
  else
    return false;
}

// ############################# Public Method #####################################
// getProtocolAtIndex -- Return the protocol at the given index
// Input:               index  : Index into protocols array
// Output:              None
// Return:              A protocol
// ############################# Class Constructor #################################
const CppProtocol&  CsvReader::getProtocolAtIndex(const unsigned long index) const
{
  return m_protocols[index];
}

// ############################# Private Method ####################################
// getWordsInLine -- Get the words in the input line, and store in output vector
// Input:     infile:   input file pointer
// Output:    allWords: all of the words in the line
// Return:    number of words parsed
// ############################# Class Constructor #################################
int CsvReader::getWordsInLine(ifstream& infile, vector<string>& allWords) const
{
  int numberWords = 0;
  string line;
  if(getline(infile, line))
  {
    stringstream strstr(line);
    string word = "";
    while(getline(strstr, word, ','))
    {
      allWords.push_back(word);
      numberWords++;
    }
  }
  return numberWords;
}

const int kPROGRAM_LOCN     = 1;
const int kLENGTH_PROGRAM   = 8;    // 8 characters in "Program "
const int kSECTION_LOCN     = 2;
const int kLENGTH_SECTION   = 8;    // 8 characters in "Section "
const int kSUBPROGRAM_LOCN  = 3;
const int kLENGTH_SUBPROGRAM= 8;    // 8 characters in "Sub-Prg "
// ############################# Private Method ####################################
// getProtocolName -- Get the protocol name from the vector of words in the line
// Input:     allWords:     all of the words in the line
// Output:    protocolName: The name of the protocol
// Return:    true if we found the name
// Notes:     The protocol name is made by concatenating the fields with a ":" between
// ############################# Class Constructor #################################
bool CsvReader::getProtocolName(const vector<string>& allWords, string& protocolName)const
{
  protocolName        = allWords[kPROGRAM_LOCN];
  extractWord(protocolName, kLENGTH_PROGRAM);
  string section      = allWords[kSECTION_LOCN];
  extractWord(section, kLENGTH_SECTION);
  protocolName        = protocolName + ':' + section;
  string subProgram   = allWords[kSUBPROGRAM_LOCN];
  extractWord(subProgram, kLENGTH_SUBPROGRAM);
  if(subProgram[0] != ' ')    //Check for blank sub-programs
  {
    protocolName      = protocolName + ':' + subProgram;
  }
  return true;
}

const int kWAVESHAPE_LOCN   = 4;
const int kFREQ1_LOCN       = 5;
const int kFREQ2_LOCN       = 6;
const int kCURRENT_LOCN     = 7;
const int kDURATION_LOCN    = 8;
const int kPOLARITY_LOCN    = 10;
// ############################# Private Method ####################################
// getNewProgram -- Get the program from the vector of words in the line
// Input:     allWords:     all of the words in the line
// Output:    newProgram:   The new program to load
// Return:    true if we found the program
// ############################# Class Constructor #################################
bool CsvReader::getNewProgram(const vector<string>& allWords, CppProgram& newProgram)const
{
  newProgram.m_waveShape  = getWaveShapeFromString(allWords[kWAVESHAPE_LOCN]);
  newProgram.m_freq1      = allWords[kFREQ1_LOCN];
  newProgram.m_freq2      = allWords[kFREQ2_LOCN];
  newProgram.m_current    = allWords[kCURRENT_LOCN];
  newProgram.m_duration   = allWords[kDURATION_LOCN];
  newProgram.m_polarity   = getPolarityFromString(allWords[kPOLARITY_LOCN]);
  
  return true;
}

const int kTYPE_LOCN        = 13;
// ############################# Private Method ####################################
// getProtocolType -- Get the protocol type from the vector of words in the line
// Input:     allWords:     all of the words in the line
// Output:    protocolType: The name of the protocol
// Return:    true if we found the type
// Notes:     The protocol type is either Standard or User Defined, and may not occur
// ############################# Class Constructor #################################
bool CsvReader::getProtocolType(const vector<string>& allWords, string& protocolType)const
{
  if (allWords.size() < kTYPE_LOCN+1)
    return false;
  protocolType        = allWords[kTYPE_LOCN];
  return true;
}

// ############################# Private Method ####################################
// extractWord -- Extract a word out of a string
// Input:     longName:     long name to extract word (modified on output)
// Input:     startLocn:    start position of word to be extracted
// Return:    none
// Notes:     Replace all occurrences of "-" with ":"
// ############################# Class Constructor #################################
void CsvReader::extractWord(string& longName, const size_t startLocn)const
{
  longName.erase(0, startLocn);
  //Find the first space after name
  size_t firstSpace   = longName.find_first_of(" ", 1);
  //Check for a space in the middle of the name
  size_t nextSpace    = longName.find_first_of(" ", firstSpace+1);
  while((nextSpace != firstSpace+1) && (nextSpace != string::npos))
  {
    firstSpace        = nextSpace;
    nextSpace         = longName.find_first_of(" ", firstSpace+1);
  }
  if(firstSpace != string::npos && nextSpace != string::npos)
  {
    longName.erase(firstSpace, longName.length()-firstSpace);
  }
}

// ############################# Private Method ####################################
// getFloatFromString -- Gets a floating point number from the input string
// Input:     inputString:  Input string
// Output:    None
// Return:    The floating point representation
// ############################# Class Constructor #################################
float CsvReader::getFloatFromString(const std::string& inputString)const
{
  return stof(inputString);
}

// ############################# Private Method ####################################
// getIntFromString -- Gets an integer number from the input string
// Input:     inputString:  Input string
// Output:    None
// Return:    The integer representation
// ############################# Class Constructor #################################
int CsvReader::getIntFromString(const std::string& inputString)const
{
  return stoi(inputString);
}

// ############################# Private Method ####################################
// getWaveShapeFromString -- Gets the waveshape from the input string
// Input:     inputString:  Input string
// Output:    None
// Return:    The waveshape string
// To Do:     Make this more robust (DoesContainString)
// ############################# Class Constructor #################################
std::string CsvReader::getWaveShapeFromString(const std::string& inputString)const
{
  std::string rtnString = "";
  if(inputString == "Gentle")
  {
    rtnString = "Gentle";
  }
  else if(inputString == "Mild  ")
  {
    rtnString = "Mild";
  }
  else if(inputString == "Sharp ")
  {
    rtnString = "Sharp";
  }
  else if(inputString == "Pulse ")
  {
    rtnString = "Pulse";
  }
  return rtnString;
}

// ############################# Private Method ####################################
// getPolarityFromString -- Gets the polarity from the input string
// Input:     inputString:  Input string
// Output:    None
// Return:    The polarity string
// To Do:     Make this more robust (DoesContainString)
// ############################# Class Constructor #################################
std::string CsvReader::getPolarityFromString(const std::string& inputString)const
{
  std::string rtnString = "";
  if(inputString == "Alternate")
  {
    rtnString = "Alternating";
  }
  else if(inputString == "Positive ")
  {
    rtnString = "Positive";
  }
  else if(inputString == "Negative ")
  {
    rtnString = "Negative";
  }
  return rtnString;
}

