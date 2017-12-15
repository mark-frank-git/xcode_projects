//
//  CppDate.h
//  CustomCareGui
//
//  Created by Mark Frank on 1/21/15.
//  Copyright (c) 2015 MarkFrank. All rights reserved.
//

#ifndef __CustomCareGui__CppDate__
#define __CustomCareGui__CppDate__

class CppDate
{
public:
  //! Class Constructor, destructor
  CppDate();
  ~CppDate();
  
  //Public properties
  
  int               day;
  int               dayOfWeek;
  int               month;
  int               year;
};

#endif /* defined(__CustomCareGui__CppDate__) */
