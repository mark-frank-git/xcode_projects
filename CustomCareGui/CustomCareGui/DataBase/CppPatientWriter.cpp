//
//  CppPatientWriter.cpp
//  CustomCareGui
//
//  Created by Mark Frank on 1/21/15.
//  Copyright (c) 2015 MarkFrank. All rights reserved.
//

#include "CppPatientWriter.h"
#include <boost/foreach.hpp>
#include <boost/property_tree/xml_parser.hpp>
#include <fstream>

// ############################# Class Constructor #################################
// CppPatientWriter -- Constructor for the CppPatientWriter class
// Input:               None
// Output:              None
// ############################# Class Constructor #################################
CppPatientWriter::CppPatientWriter()
{
  return;
}

// ############################# Class Destructor #################################
// ~CppPatientWriter -- Destructor for the CppPatientWriter class
// Input:               None
// Output:              None
// ############################# Class Constructor #################################
CppPatientWriter::~CppPatientWriter()
{
  return;
}

// ############################# Public Function ###################################
// writePatientToFile -- Write the patient to an xml file
// Input:       patient   : The patient info
// Input:       fileName  : The name of the xml file
// ############################# Class Constructor #################################
bool CppPatientWriter::writePatientToFile(const CppPatient&   patient,
                                          const char*         fileName) const
{
  std::ofstream output(fileName);
  if(!output)
  {
    return false;
  }
  ptree pt;
  if(!loadPatientIntoPtree(patient, pt))
    return false;
  write_xml(output, pt);

  return true;
}

// ############################# Public Function ###################################
// writePatientsToFile -- Write an array of patient to an xml file
// Input:       patients  : The array of patients
// Input:       fileName  : The name of the xml file
// ############################# Class Constructor #################################
bool CppPatientWriter::writePatientsToFile(const vectorOfPatients& patients,
                                           const char*             fileName)
                                           const
{
  std::ofstream output(fileName);
  if(!output)
  {
    return false;
  }
  if(patients.size() == 0)
  {
    return false;
  }
  ptree pt;
  ptree &patientsTree  = pt.add("Patients", "List of Patients");
  BOOST_FOREACH(CppPatient patient, patients )
  {
    ptree &patientTree = patientsTree.add("patient", "");
    if(!loadPatientIntoPtree(patient, patientTree))
    {
      return false;
    }
  }
  write_xml(output, pt);
  return true;
}

// ############################# Public Function ###################################
// writePatientToFile -- Write the patient to an xml file
// Input:       name  : The name of the protocol
// Output:      None
// ############################# Class Constructor #################################
bool CppPatientWriter::loadPatientIntoPtree(const CppPatient&   patient,
                                                  ptree&        pt)
                                            const
{
  pt.add("PatientNumber",     patient.patientNumber);
  pt.add("LastName",          patient.patientLastName);
  pt.add("FirstName",         patient.patientFirstName);
  pt.add("Note",              patient.patientNote);
  pt.add("ZipCode",           patient.patientZipCode);
  pt.add("StreetAddress",     patient.patientStreetAddress);
  pt.add("City",              patient.patientCityName);
  pt.add("State",             patient.patientStateName);
  pt.add("HomePhone",         patient.patientHomePhone);
  pt.add("CellPhone",         patient.patientCellPhone);
  pt.add("WorkPhone",         patient.patientWorkPhone);
  pt.add("Doctor",            patient.patientDoctorName);
  pt.add("MaxTreatHours",     patient.patientMaxTreatmentHours);
  pt.add("MaxTreatMins",      patient.patientMaxTreatmentMinutes);
  pt.add("ExpirationDay",     patient.patientExpirationDate.day);
  pt.add("ExpirationMonth",   patient.patientExpirationDate.month);
  pt.add("ExpirationYear",    patient.patientExpirationDate.year);
  
  //Write the patient notes
  if(patient.patientListOfNotes.size()>0)
  {
    ptree &notes      = pt.add("Notes", "Patient Notes");
    BOOST_FOREACH(CppPatientNote note, patient.patientListOfNotes )
    {
      ptree &noteTree = notes.add("note", "");
      noteTree.add("NoteNumber", 1);
      noteTree.add("Note",          note.patientNote);
      noteTree.add("NoteAddedBy",   note.patientNoteAddedBy);
      noteTree.add("NoteAddedDate", note.patientNoteAddedDate);
    }
  }
  //Write the protocols
  if(patient.patientListOfProtocols.size()>0)
  {
    ptree &protocols  = pt.add("Protocols", "List of Protocols");
    BOOST_FOREACH(CppProtocol protocol, patient.patientListOfProtocols )
    {
      ptree &protocolTree = protocols.add("protocol", "");
      protocolTree.add("ProtocolName",         protocol.m_protocolName);
      protocolTree.add("ProtocolInstructions", protocol.m_protocolInstructions);
      protocolTree.add("ProtocolNote",         protocol.m_protocolNote);
      if(protocol.m_programs.size()>0)
      {
        ptree &programs     = protocolTree.add("Programs", "List of Programs");
        BOOST_FOREACH(CppProgram program, protocol.m_programs )
        {
          ptree &programTree  = programs.add("program", "");
          programTree.add("Waveshape", program.m_waveShape);
          programTree.add("Freq1",     program.m_freq1);
          programTree.add("Freq2",     program.m_freq2);
          programTree.add("Current",   program.m_current);
          programTree.add("Duration",  program.m_duration);
          programTree.add("Polarity",  program.m_polarity);
        }
      }
    }
  }  
  return true;
}

