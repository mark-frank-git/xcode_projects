//
//  CppPatientWriter.h
//  CustomCareGui
//
//  Created by Mark Frank on 1/21/15.
//  Copyright (c) 2015 MarkFrank. All rights reserved.
//

#ifndef __CustomCareGui__CppPatientWriter__
#define __CustomCareGui__CppPatientWriter__

#include "CppPatient.h"
#include <boost/property_tree/ptree.hpp>
using boost::property_tree::ptree;
typedef std::vector<CppPatient> vectorOfPatients;

class CppPatientWriter
{
public:
  //! Class Constructor, destructor
  CppPatientWriter();
  ~CppPatientWriter();
  
  //Public functions
  bool writePatientToFile( const CppPatient&       patient,
                           const char*             fileName) const;
  bool writePatientsToFile(const vectorOfPatients& patients,
                           const char*             fileName) const;
private:
  //Private functions
  bool loadPatientIntoPtree(const CppPatient&   patient,
                                       ptree&   pt)
                            const;


};

#endif /* defined(__CustomCareGui__CppPatientWriter__) */
