//
//  CppPatientReader.h
//  CustomCareGui
//
//  Created by Mark Frank on 1/21/15.
//  Copyright (c) 2015 MarkFrank. All rights reserved.
//

#ifndef __CustomCareGui__CppPatientReader__
#define __CustomCareGui__CppPatientReader__

#include "CppPatient.h"
#include <boost/property_tree/ptree.hpp>
using boost::property_tree::ptree;
typedef std::vector<CppPatient> vectorOfPatients;

class CppPatientReader
{
public:
  //! Class Constructor, destructor
  CppPatientReader();
  ~CppPatientReader();
  
  //Public functions
  bool readPatientFromFile(CppPatient&          patient,
                           const char*          fileName) const;
  bool readPatientsFromFile(vectorOfPatients&   patient,
                            const char*         fileName) const;
private:
  //Private functions
  bool readPatientFromPtree(CppPatient&   patient,
                                 ptree&        pt) const;

};

#endif /* defined(__CustomCareGui__CppPatientReader__) */
