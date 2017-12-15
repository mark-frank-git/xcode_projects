//
//  CsvWriter.h
//  CustomCareGui
//
//  Created by Mark Frank on 1/5/15.
//  Copyright (c) 2015 MarkFrank. All rights reserved.
//

#ifndef __CustomCareGui__CsvWriter__
#define __CustomCareGui__CsvWriter__

#include <string>
#include <vector>
#include <fstream>
#include <string>
#include <vector>
#include "CppProtocol.h"

typedef std::vector<CppProtocol> vectorOfProtocols;
typedef std::vector<std::string> vectorOfStrings;
class CsvWriter
{
public:
//! Class Constructor, destructor
  CsvWriter();
  ~CsvWriter();
  
//! Reading in csv file
  bool writeCsvFile(const char *fileName, vectorOfProtocols &protocols);
  
private:
  void writeHeader(  std::ofstream&          outfile) const;
  void writePrograms(const int               protocolNumber,
                    const std::string&       protocolName,
                    const std::string&       protocolNote,
                    const std::string&       protocolType,
                    const vectorOfPrograms&  programs,
                          std::ofstream&     outfile)
                    const;
  std::string protocolStringFromNumber(const int protocolNumber)
                                       const;
  std::string subNameFrom(const std::string& protocolName,
                                        int& startIndex)
                              const;
  std::string getWaveshapeFromString(const std::string& inputString)const;
  std::string getPolarityFromString( const std::string& inputString)const;
};

#endif /* defined(__CustomCareGui__CsvWriter__) */
