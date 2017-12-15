//
//  PatientNote.m
//  CustomCareGui
//
//  Created by Mark Frank on 12/24/14.
//  Copyright (c) 2014 MarkFrank. All rights reserved.
//

#import "PatientNote.h"

@implementation PatientNote

@synthesize     patientNote;
@synthesize     patientNoteAddedDate;
@synthesize     patientNoteAddedBy;

//********************************************************
//Implement NSCoder initWithCoder
//********************************************************
- (id)initWithCoder:(NSCoder *)aDecoder
{
  self  = [super init];
  if(self)
  {
    self.patientNote              = [aDecoder decodeObjectForKey:@"patientNote"];
    self.patientNoteAddedDate     = [aDecoder decodeObjectForKey:@"patientNoteAddedDate"];
    self.patientNoteAddedBy       = [aDecoder decodeObjectForKey:@"patientNoteAddedBy"];
  }
  return self;
}

//********************************************************
//Implement NSCoder encodeWithCoder
//********************************************************
- (void)encodeWithCoder:(NSCoder *)aCoder
{
  [aCoder encodeObject:self.patientNote           forKey:@"patientNote"];
  [aCoder encodeObject:self.patientNoteAddedDate  forKey:@"patientNoteAddedDate"];
  [aCoder encodeObject:self.patientNoteAddedBy    forKey:@"patientNoteAddedBy"];
}

@end
