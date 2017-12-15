//
//  CppProgram.h
//  CustomCareGui
//
//  Created by Mark Frank on 1/12/15.
//  Copyright (c) 2015 MarkFrank. All rights reserved.
//

#ifndef __CustomCareGui__CppProgram__
#define __CustomCareGui__CppProgram__

#include <stdio.h>
#include <string>
//! Class for defining a single program in a protocol
class CppProgram
{
public:
  //! Class Constructor, destructor
  CppProgram();
  ~CppProgram();
  
  //! The enums for wave shape and polarity
  //No longer used?
  /*
  enum eWaveShape
  {
    Gentle,
    Mild,
    Sharp,
    Pulse,
    BadWaveString
  };
  enum ePolarity
  {
    Negative,
    Positive,
    Alternating,
    BadPolarityString
  }; */
  
public:
  std::string m_waveShape;      //!< "Gentle", "Mild", "Sharp", "Pulse"
  std::string m_freq1;          //!< First frequency in Hertz
  std::string m_freq2;          //!< Second frequency in Hertz
  std::string m_current;        //!< Current in micro-amperes
  std::string m_duration;       //!< duration in minutes
  std::string m_polarity;       //!< "Negative", "Positive", "Alternating"
};

#endif /* defined(__CustomCareGui__CppProgram__) */
