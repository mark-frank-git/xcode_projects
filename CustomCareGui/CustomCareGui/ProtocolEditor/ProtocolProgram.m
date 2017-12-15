//
//  ProtocolProgram.m
//  CustomCareGui
//
//  Created by Mark Frank on 12/15/14.
//  Copyright (c) 2014 MarkFrank. All rights reserved.
//

#import "ProtocolProgram.h"

@implementation ProtocolProgram
@synthesize     programSequenceNumber, programWaveShape;
@synthesize     programFreq1,          programFreq2;
@synthesize     programCurrent,        programDuration;
@synthesize     programPolarity;

//********************************************************
//Implement NSCoder initWithCoder
//********************************************************
- (id)initWithCoder:(NSCoder *)aDecoder
{
  self  = [super init];
  if(self)
  {
    self.programSequenceNumber  = [aDecoder decodeIntForKey:@"programSequenceNumber"];
    self.programCurrent         = [aDecoder decodeObjectForKey:@"programCurrent"];
    self.programDuration        = [aDecoder decodeObjectForKey:@"programDuration"];
    self.programFreq1           = [aDecoder decodeObjectForKey:@"programFreq1"];
    self.programFreq2           = [aDecoder decodeObjectForKey:@"programFreq2"];

    self.programWaveShape       = [aDecoder decodeObjectForKey:@"programWaveShape"];
    self.programPolarity        = [aDecoder decodeObjectForKey:@"programPolarity"];
  }
  return self;
}

//********************************************************
//Implement NSCoder encodeWithCoder
//********************************************************
- (void)encodeWithCoder:(NSCoder *)aCoder
{
  [aCoder encodeInteger:self.programSequenceNumber  forKey:@"programSequenceNumber"];
  [aCoder encodeObject:self.programCurrent          forKey:@"programCurrent"];
  [aCoder encodeObject:self.programDuration         forKey:@"programDuration"];
  [aCoder encodeObject:self.programFreq1            forKey:@"programFreq1"];
  [aCoder encodeObject:self.programFreq2            forKey:@"programFreq2"];
  
  [aCoder encodeObject:self.programWaveShape        forKey:@"programWaveShape"];
  [aCoder encodeObject:self.programPolarity         forKey:@"programPolarity"];
}


//********************************************************
//Return a printable text description of protocol
//********************************************************
- (NSString*)textDescription
{
  NSString* description = [[NSString alloc] init];
  description           = [description stringByAppendingString:@" Program Number \t\t: "];
  description           = [description stringByAppendingFormat:@"%d%@", self.programSequenceNumber, @"\n"];
  description           = [description stringByAppendingString:@" Current (micro-A)\t: "];
  description           = [description stringByAppendingFormat:@"%@%@", self.programCurrent, @"\n"];
  description           = [description stringByAppendingString:@" Duration (mins)\t\t: "];
  description           = [description stringByAppendingFormat:@"%@%@", self.programDuration, @"\n"];
  description           = [description stringByAppendingString:@" Freq 1 (Hz)\t\t\t: "];
  description           = [description stringByAppendingFormat:@"%@%@", self.programFreq1, @"\n"];
  description           = [description stringByAppendingString:@" Freq 2 (Hz)\t\t\t: "];
  description           = [description stringByAppendingFormat:@"%@%@", self.programFreq2, @"\n"];
  description           = [description stringByAppendingString:@" Wave Shape\t\t\t: "];
  description           = [description stringByAppendingFormat:@"%@%@", self.programWaveShape, @"\n"];
  description           = [description stringByAppendingString:@" Polarity  \t\t\t: "];
  description           = [description stringByAppendingFormat:@"%@%@", self.programPolarity, @"\n"];
  
  return description;
}


@end
