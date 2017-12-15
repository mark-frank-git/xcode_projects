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
#include "CppProtocol.h"

typedef std::vector<CppProtocol> vectorOfProtocols;
typedef std::vector<std::string> vectorOfStrings;
class CsvReader
{
public:
//! Class Constructor, destructor
  CsvReader();
  ~CsvReader();
  
//! Reading in csv file
  bool readCsvFile(const char *fileName);
  
private:
  int   getWordsInLine      (std::ifstream& infile, std::vector<std::string>& allWords)  const;
  bool  getProtocolName     (const vectorOfStrings& allWords, std::string& protocolName) const;
  bool  getNewProgram       (const vectorOfStrings& allWords, CppProgram& newProgram)    const;
  bool  getProtocolType     (const vectorOfStrings& allWords, std::string& protocolType) const;
  void  extractWord         (std::string& longName, const size_t startLocn)              const;
  float getFloatFromString  (const std::string& inputString)                             const;
  int   getIntFromString    (const std::string& inputString)                             const;
  std::string  getWaveShapeFromString(const std::string& inputString)                    const;
  std::string  getPolarityFromString (const std::string& inputString)                    const;

  int               m_numberProtocols;
  vectorOfProtocols m_protocols;
  vectorOfStrings   m_protocolNames;
  
  
public:
  //! Getting results from reading in file
  const int numberProtocols()            {return m_numberProtocols;}
  const vectorOfStrings& protocolNames() {return m_protocolNames;}
  const CppProtocol& getProtocolAtIndex(const unsigned long  index) const;
};

#endif /* defined(__CustomCareGui__CsvReader__) */
