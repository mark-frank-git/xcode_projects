//
//  CsvReader.h
//  CustomCareGui
//
//  Created by Mark Frank on 1/5/15.
//  Copyright (c) 2015 MarkFrank. All rights reserved.
//

#ifndef __CustomCareGui__CsvReader__
#define __CustomCareGui__CsvReader__

#include <string>
#include <vector>
#include <fstream>
#include <string>
#include <vector>

typedef std::vector<std::string> vectorOfStrings;
class CsvReader
{
public:
//! Class Constructor, destructor
  CsvReader();
  ~CsvReader();
  
//! Reading in csv file
  bool readCsvFile(const char *fileName);
  bool writeCsvFile(const char* fileName);

private:
  int   getWordsInLine      (std::ifstream& infile, std::vector<std::string>& allWords)  const;
  bool  getTypeAndName      (const std::string& typeAndName,
                                   std::string& typeString,
                             std::string& nameString)                                    const;
  bool  getServiceString    (const std::string& inputString,
                             std::string& serviceString)                           const;
  void  extractWord         (std::string& longName, const size_t startLocn)              const;
  float getFloatFromString  (const std::string& inputString)                             const;
  int   getIntFromString    (const std::string& inputString)                             const;
  std::string  getWaveShapeFromString(const std::string& inputString)                    const;
  std::string  getPolarityFromString (const std::string& inputString)                    const;

  int               m_numberRows;       //Number of rows in file
  vectorOfStrings   m_dates;            //Vector of dates
  vectorOfStrings   m_amounts;          //Vector of payment amounts
  vectorOfStrings   m_types;            //Vector of types, Patient/Insurance
  vectorOfStrings   m_names;            //Patient or insurance names
  vectorOfStrings   m_services;         //vector of services: Tx or Supps
  vectorOfStrings   m_memos;            //vector of memos
  vectorOfStrings   m_notes1;           //vector of first notes
  vectorOfStrings   m_notes2;           //vector of second notes
  
  
public:
  //! Getting results from reading in file
  const int numberRows()            {return m_numberRows;}
};

#endif /* defined(__CustomCareGui__CsvReader__) */
