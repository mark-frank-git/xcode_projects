//
//  CppProgram.cpp
//  CustomCareGui
//
//  Created by Mark Frank on 1/12/15.
//  Copyright (c) 2015 MarkFrank. All rights reserved.
//

#include "CppProgram.h"

// ############################# Class Constructor #################################
// CppProgram -- Constructor for the CppProgram class
// Input:               None
// Output:              None
// ############################# Class Constructor #################################
CppProgram::CppProgram()
           :m_waveShape("Sharp"),
            m_freq1("100."),
            m_freq2("100."),
            m_current("100"),
            m_duration("2"),
            m_polarity("Positive")
{
  return;
}

// ############################# Class Destructor #################################
// CppProgram -- Destructor for the CppProgram class
// Input:               None
// Output:              None
// ############################# Class Constructor #################################
CppProgram::~CppProgram()
{
  return;
}
