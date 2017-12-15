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
          :m_numberRows(0)
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

const int kMIN_WORDS_IN_LINE  = 5;
const int kDATE_LOCN          = 1;
const int kAMOUNT_LOCN        = 2;
const int kTYPE_LOCN          = 3;
const int kSERVICE_LOCN       = 4;
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
  m_numberRows            = 0;
  m_dates.clear();            //Vector of dates
  m_amounts.clear();          //Vector of payment amounts
  m_types.clear();            //Vector of types, Patient/Insurance
  m_names.clear();            //Patient or insurance names
  m_services.clear();         //vector of services: Tx or Supps
  m_memos.clear();            //vector of memos
  m_notes1.clear();           //vector of notes
  m_notes2.clear();           //vector of notes
  while(getWordsInLine(infile, allWords) >= kMIN_WORDS_IN_LINE)
  {
    m_dates.push_back(allWords[kDATE_LOCN]);
    m_amounts.push_back(allWords[kAMOUNT_LOCN]);
    string typeString;
    string nameString;
    getTypeAndName(allWords[kTYPE_LOCN], typeString, nameString);
    m_types.push_back(typeString);
    m_names.push_back(nameString);
    string serviceString;
    getServiceString(allWords[kSERVICE_LOCN], serviceString);
    m_services.push_back(serviceString);
    string blankString  = " ";
    if(allWords.size()>kSERVICE_LOCN+2)
    {
      m_memos.push_back(allWords[kSERVICE_LOCN+1]);
    }
    else
    {
      m_memos.push_back(blankString);
    }
    if(allWords.size()>kSERVICE_LOCN+3)
    {
      m_notes1.push_back(allWords[kSERVICE_LOCN+2]);
    }
    else
    {
      m_notes1.push_back(blankString);
    }
    if(allWords.size()>kSERVICE_LOCN+4)
    {
      m_notes2.push_back(allWords[kSERVICE_LOCN+1]);
    }
    else
    {
      m_notes2.push_back(blankString);
    }

    m_numberRows++;
    allWords.clear();
  }
  infile.close();
  if(m_numberRows > 0)
    return true;
  else
    return false;
}

// ############################# Public Method #####################################
// readCsvFile -- Write the csv file
// Input:               fileName  : File to read in
// Output:              None
// Return:              true on no error
// ############################# Class Constructor #################################
bool CsvReader::writeCsvFile(const char* fileName)
{
  ofstream outfile(fileName);
  for(int i=0; i<m_numberRows; i++)
  {
    string line = m_dates[i]    + "," +
                  m_amounts[i]  + "," +
                  m_types[i]    + "," +
                  m_names[i]    + "," +
                  m_services[i] + "," +
                  m_memos[i]    + "," +
                  m_notes1[i]   + "," +
                  m_notes2[i];
    outfile << line << endl;
  }
  outfile.close();
  if(m_numberRows > 0)
    return true;
  else
    return false;
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

const int kMAX_NAME = 512;
// ############################# Private Method ####################################
// getTypeAndName -- Get the type and name of the input string
// Input:     typeAndName:   type + name
// Output:    typeString:    type
// Output:    nameString:    name
// Return:    true if we found the name
// Notes:     None
// ############################# Class Constructor #################################
bool CsvReader::getTypeAndName(const string& typeAndName, string& typeString, string& nameString)const
{
  char nameChars[kMAX_NAME];
  for(int i=0; i<kMAX_NAME; i++)
  {
    nameChars[i]  = '\0';
  }
  nameChars[0]    = ' ';
  string patientString("Patient");
  string insString("INS:");
  string statementString("Statement Pt");
  string paymentString("Payment:");
  string paymentPtString("Payment Pt.");
  string srdsString("SRDS");
  typeString          = " ";
  bool foundString    = true;
  if(typeAndName.find(patientString)!=string::npos)
  {
    typeString        = patientString;
  }
  else if(typeAndName.find(insString)!=string::npos)
  {
    typeString        = insString;
  }
  else if(typeAndName.find(statementString)!=string::npos)
  {
    typeString        = statementString;
  }
  else if(typeAndName.find(paymentString)!=string::npos)
  {
    typeString        = paymentString;
  }
  else if(typeAndName.find(paymentPtString)!=string::npos)
  {
    typeString        = paymentPtString;
  }
  else if(typeAndName.find(srdsString)!=string::npos)
  {
    typeString        = patientString;
    nameString        = srdsString;
    foundString       = false;
  }
  else
  {
    typeString        = typeAndName;
    nameString        = " ";
    foundString       = false;
  }
  if(foundString)
  {
    size_t nameStart    = typeString.size()+1;
    size_t nameLength   = 0;
    if(typeAndName.size() >= nameStart)
    {
      nameLength   = typeAndName.size() - nameStart;
    }
    typeAndName.copy(nameChars, nameLength, nameStart);
    nameString          = nameChars;
  }
  return false;
}
// ############################# Private Method ####################################
// getServiceString -- Get the service string
// Input:     inputString:   string containing service
// Output:    serviceString: output service string
// Return:    true if we found the service
// Notes:     None
// ############################# Class Constructor #################################
bool CsvReader::getServiceString(const string& inputString, string& serviceString)const
{
  string txString("Tx");
  string suppString("Supp");
  if(inputString.find(suppString)!=string::npos)
  {
    serviceString = suppString + ": " + inputString;
  }
  else
  {
    serviceString = txString + ": " + inputString;
  }
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

