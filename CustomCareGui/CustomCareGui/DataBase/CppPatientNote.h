//
//  CppPatientNote.h
//  CustomCareGui
//
//  Created by Mark Frank on 1/21/15.
//  Copyright (c) 2015 MarkFrank. All rights reserved.
//

#ifndef __CustomCareGui__CppPatientNote__
#define __CustomCareGui__CppPatientNote__

#include <string>

typedef std::string              cppString;
class CppPatientNote
{
public:
  //! Class Constructor, destructor
  CppPatientNote();
  ~CppPatientNote();
 
//Public properties
  cppString         patientNote;
  cppString         patientNoteAddedDate;
  cppString         patientNoteAddedBy;
};

#endif /* defined(__CustomCareGui__CppPatientNote__) */
