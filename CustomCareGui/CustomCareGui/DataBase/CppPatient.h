//
//  CppPatient.h
//  CustomCareGui
//
//  Created by Mark Frank on 1/21/15.
//  Copyright (c) 2015 MarkFrank. All rights reserved.
//

#ifndef __CustomCareGui__CppPatient__
#define __CustomCareGui__CppPatient__

#include <string>
#include <vector>
#include "CppProtocol.h"
#include "CppDate.h"
#include "CppPatientNote.h"

typedef std::vector<CppProtocol>    vectorOfProtocols;
typedef std::vector<CppPatientNote> vectorOfNotes;
typedef std::string                 cppString;
class CppPatient
{
public:
  //! Class Constructor, destructor
  CppPatient();
  ~CppPatient();
  
//Public properties

  int               patientNumber;
  cppString         patientLastName;
  cppString         patientFirstName;
  cppString         patientNote;
  cppString         patientZipCode;
  cppString         patientStreetAddress;
  cppString         patientCityName;
  cppString         patientStateName;
  cppString         patientHomePhone;
  cppString         patientCellPhone;
  cppString         patientWorkPhone;
  cppString         patientDoctorName;
  int               patientMaxTreatmentHours;
  int               patientMaxTreatmentMinutes;
  CppDate           patientExpirationDate;
  vectorOfNotes     patientListOfNotes;
  vectorOfProtocols patientListOfProtocols;
};

#endif /* defined(__CustomCareGui__CppPatient__) */
