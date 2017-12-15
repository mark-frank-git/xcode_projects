//
//  CppProtocol.h
//  CustomCareGui
//
//  Created by Mark Frank on 1/17/15.
//  Copyright (c) 2015 MarkFrank. All rights reserved.
//

#ifndef __CustomCareGui__CppProtocol__
#define __CustomCareGui__CppProtocol__

#include <string>
#include <vector>
#include "CppProgram.h"                               //!< One program in the protocol

typedef std::vector<CppProgram> vectorOfPrograms;
//! Class for defining a single protocol from the bank
class CppProtocol
{
public:
  //! Class Constructor, destructor
  CppProtocol();
  ~CppProtocol();
  
  //! Setting parameters
  void SetProtocolName(        const std::string& name);
  void SetProtocolInstructions(const std::string& instructions);
  void SetProtocolNote(        const std::string& note);
  void SetProtocolType(        const std::string& newType);
  void AddNewProgram  (        const CppProgram& newProgram);
                                                      //!< Add a new program to the protocol
  void ClearPrograms  ();                             //!< clear out the programs
  
public:
  std::string       m_protocolName;                   //!< Name of this protocol
  std::string       m_protocolInstructions;           //!< Line 2 on custom care unit
  std::string       m_protocolNote;                   //!< Note for this protocol
  std::string       m_protocolType;                   //!< "Standard" or "User Defined"
  vectorOfPrograms  m_programs;                       //!< The programs
};

#endif /* defined(__CustomCareGui__CppProtocol__) */
