//
//  CppProtocol.cpp
//  CustomCareGui
//
//  Created by Mark Frank on 1/17/15.
//  Copyright (c) 2015 MarkFrank. All rights reserved.
//

#include "CppProtocol.h"

// ############################# Class Constructor #################################
// CppProtocol -- Constructor for the CppProtocol class
// Input:               None
// Output:              None
// ############################# Class Constructor #################################
CppProtocol::CppProtocol()
{
  m_protocolName  = "";
  m_programs.clear();
  return;
}

// ############################# Class Destructor #################################
// CppProtocol -- Destructor for the CppProtocol class
// Input:               None
// Output:              None
// ############################# Class Constructor #################################
CppProtocol::~CppProtocol()
{
  m_programs.clear();
  return;
}

// ############################# Public Function ###################################
// SetProtocolName -- Sets the name of the protocol
// Input:       name  : The name of the protocol
// Output:      None
// ############################# Class Constructor #################################
void CppProtocol::SetProtocolName(const std::string& name)
{
  m_protocolName  = name;
  return;
}

// ############################# Public Function ###################################
// SetProtocolInstructions -- Sets the instructions for
// Input:       inst  : The instructions for the protocol
// Output:      None
// ############################# Class Constructor #################################
void CppProtocol::SetProtocolInstructions(const std::string& inst)
{
  m_protocolInstructions  = inst;
  return;
}

// ############################# Public Function ###################################
// SetProtocolNote -- Sets the note for the protocol
// Input:       note  : The note for the protocol
// Output:      None
// ############################# Class Constructor #################################
void CppProtocol::SetProtocolNote(const std::string& note)
{
  m_protocolNote  = note;
  return;
}

// ############################# Public Function ###################################
// SetProtocolType -- Sets the type for the protocol
// Input:       newType  : The type for the protocol
// Output:      None
// ############################# Class Constructor #################################
void CppProtocol::SetProtocolType(const std::string &newType)
{
  m_protocolType  = newType;
  return;
}


// ############################# Public Function ###################################
// AddNewProgram -- Adds a new program to the protocol
// Input:       newProgram  : The new program to add to the programs vector
// Output:      None
// ############################# Class Constructor #################################
void CppProtocol::AddNewProgram(const CppProgram& newProgram)
{
  CppProgram program  = newProgram;
  m_programs.push_back(program);
  return;
}

// ############################# Public Function ###################################
// ClearPrograms -- Clears out the programs in the protocol
// Input:       None
// Output:      None
// ############################# Class Constructor #################################
void CppProtocol::ClearPrograms()
{
  m_programs.clear();
  return;
}
