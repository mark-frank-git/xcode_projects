//
//  CppPatientReader.cpp
//  CustomCareGui
//
//  Created by Mark Frank on 1/21/15.
//  Copyright (c) 2015 MarkFrank. All rights reserved.
//

#include "CppPatientReader.h"
#include <boost/foreach.hpp>
#include <boost/property_tree/xml_parser.hpp>
#include <boost/optional.hpp>
#include <fstream>

// ############################# Class Constructor #################################
// CppPatientReader -- Constructor for the CppPatientReader class
// Input:               None
// Output:              None
// ############################# Class Constructor #################################
CppPatientReader::CppPatientReader()
{
  return;
}

// ############################# Class Destructor #################################
// ~CppPatientReader -- Destructor for the CppPatientReader class
// Input:               None
// Output:              None
// ############################# Class Constructor #################################
CppPatientReader::~CppPatientReader()
{
  return;
}

typedef boost::property_tree::ptree::value_type pValueType;
// ############################# Public Function ###################################
// readPatientFromFile -- Read the patient from an xml file
// Input:       fileName  : The name of the xml file
// Output:      patient   : The patient to store data in
// ############################# Class Constructor #################################
bool CppPatientReader::readPatientFromFile(CppPatient&   patient,
                                           const char*   fileName) const
{
  std::ifstream input(fileName);
  if(!input)
  {
    return false;
  }
  ptree pt;
  read_xml(input, pt);
  return readPatientFromPtree(patient, pt);
 }

// ############################# Public Function ###################################
// readPatientFromFile -- Read a set of patients from an xml file
// Input:       fileName  : The name of the xml file
// Output:      patients  : The vector of patients to store data in
// ############################# Class Constructor #################################
bool CppPatientReader::readPatientsFromFile(vectorOfPatients&   patients,
                                           const char*   fileName) const
{
  std::ifstream input(fileName);
  if(!input)
  {
    return false;
  }
  ptree pt;
  read_xml(input, pt);
  cppString patientsString   = pt.get<cppString>("Patients", "No Patients");

  if(patientsString == "No Patients")
  {
    return false;
  }
  int numberPatients  = 0;
  patients.clear();
  BOOST_FOREACH(pValueType const& pPatient, pt.get_child("Patients") )
  {
    if(pPatient.first == "patient")
    {
      boost::property_tree::ptree pTree = pPatient.second;
      CppPatient newPatient;
      if(readPatientFromPtree(newPatient, pTree))
      {
        numberPatients++;
        patients.push_back(newPatient);
      }
      else
      {
        break;
      }
    }
  }
  return numberPatients>0;
}

// ############################# Public Function ###################################
// readPatientFromPtree -- Read the patient from a property_tree
// Input:       pt      : The input property tree
// Output:      patient : The patient to store data in
// ############################# Class Constructor #################################
bool CppPatientReader::readPatientFromPtree(CppPatient&   patient,
                                            ptree&        pt) const
{
  patient.patientNumber                 = pt.get<int>      ("PatientNumber", -1);
  patient.patientLastName               = pt.get<cppString>("LastName",     "No Name");
  patient.patientFirstName              = pt.get<cppString>("FirstName",    "No Name");
  patient.patientNote                   = pt.get<cppString>("Note",         "No Note");
  patient.patientZipCode                = pt.get<cppString>("ZipCode",      "No Zip");
  patient.patientStreetAddress          = pt.get<cppString>("StreetAddress","No Street");
  patient.patientCityName               = pt.get<cppString>("City",         "No City");
  patient.patientStateName              = pt.get<cppString>("State",        "No State");
  patient.patientHomePhone              = pt.get<cppString>("HomePhone",    "No Phone");
  patient.patientCellPhone              = pt.get<cppString>("CellPhone",    "No Phone");
  patient.patientWorkPhone              = pt.get<cppString>("WorkPhone",    "No Phone");
  patient.patientDoctorName             = pt.get<cppString>("Doctor",       "No Doctor");
  patient.patientMaxTreatmentHours      = pt.get<int>      ("MaxTreatHours",   0);
  patient.patientMaxTreatmentMinutes    = pt.get<int>      ("MaxTreatMins",    0);
  patient.patientExpirationDate.day     = pt.get<int>      ("ExpirationDay",  -1);
  patient.patientExpirationDate.month   = pt.get<int>      ("ExpirationMonth",-1);
  patient.patientExpirationDate.year    = pt.get<int>      ("ExpirationYear", -1);
  
  if(patient.patientNumber == -1 && patient.patientLastName == "No Name")
  {
    return false;
  }
  //Read the list of notes
  cppString notesString                 = pt.get("Notes", "No Notes");
  if(notesString != "No Notes")
  {
    BOOST_FOREACH(pValueType const& pNote, pt.get_child("Notes") )
    {
      if(pNote.first == "note")
      {
        CppPatientNote  newNote;
        boost::property_tree::ptree pTree = pNote.second;
        newNote.patientNote               = pTree.get("Note", "");
        newNote.patientNoteAddedBy        = pTree.get("NoteAddedBy", "");
        newNote.patientNoteAddedDate      = pTree.get("NoteAddedDate", "");
        patient.patientListOfNotes.push_back(newNote);
      }
    }
  }
  
  //Read the protocols
  cppString protocolsString               = pt.get("Protocols", "No Protocols");
  if(protocolsString != "No Protocols")
  {
    BOOST_FOREACH(pValueType const& node, pt.get_child("Protocols") )
    {
      cppString nodeFirst                  = node.first;
      boost::property_tree::ptree subtree  = node.second;
      CppProtocol newProtocol;
      newProtocol.m_protocolName           = subtree.get("ProtocolName",         "No Name");
      newProtocol.m_protocolInstructions   = subtree.get("ProtocolInstructions", "No Instructions");
      newProtocol.m_protocolNote           = subtree.get("ProtocolNote",         "No Note");
      if( node.first == "protocol" )
      {
        //read the programs
        boost::optional<ptree&> child     = subtree.get_child_optional("Programs");
        if(child.is_initialized())
        {
          BOOST_FOREACH(pValueType const& pNode, subtree.get_child( "Programs" ) )
          {
            CppProgram newProgram;
            if( pNode.first == "program" )
            {
              boost::property_tree::ptree pTree = pNode.second;
              newProgram.m_waveShape            = pTree.get("Waveshape", "Sharp");
              newProgram.m_freq1                = pTree.get("Freq1",     "100.");
              newProgram.m_freq2                = pTree.get("Freq2",     "200.");
              newProgram.m_current              = pTree.get("Current",   "100");
              newProgram.m_duration             = pTree.get("Duration",  "1");
              newProgram.m_polarity             = pTree.get("Polarity",   "Negative");
            }
            newProtocol.m_programs.push_back(newProgram);
          }
        }//End loop on programs
      }//if(Programs)
      patient.patientListOfProtocols.push_back(newProtocol);
    }//End loop on protocols
  }//if(protocolsString;
  return true;
}

