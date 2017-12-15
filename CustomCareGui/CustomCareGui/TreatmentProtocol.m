//
//  TreatmentProtocol.m
//  CustomCareGui
//
//  Created by Mark Frank on 12/22/14.
//  Copyright (c) 2014 MarkFrank. All rights reserved.
//

#import "TreatmentProtocol.h"
#import "ProtocolProgram.h"

@implementation TreatmentProtocol
@synthesize     protocolName;
@synthesize     protocolNote;
@synthesize     protocolType;
@synthesize     protocolInstructions;
@synthesize     printProtocol;
@synthesize     protocolPrograms; // The set of programs as edited by ProtocolEditorController


//********************************************************
//Implement NSCoder initWithCoder
//********************************************************
- (id)initWithCoder:(NSCoder *)aDecoder
{
  self  = [super init];
  if(self)
  {
    self.protocolSequenceNumber = [aDecoder decodeIntForKey:   @"protocolSequenceNumber"];
    self.protocolName           = [aDecoder decodeObjectForKey:@"protocolName"];
    self.protocolNote           = [aDecoder decodeObjectForKey:@"protocolNote"];
    self.protocolType           = [aDecoder decodeObjectForKey:@"protocolType"];
    self.protocolInstructions   = [aDecoder decodeObjectForKey:@"protocolInstructions"];
    self.printProtocol          = [aDecoder decodeBoolForKey:  @"printProtocol"];
    self.protocolPrograms       = [aDecoder decodeObjectForKey:@"protocolPrograms"];
  }
  return self;
}

//********************************************************
//Implement NSCoder encodeWithCoder
//********************************************************
- (void)encodeWithCoder:(NSCoder *)aCoder
{
  [aCoder encodeInt:self.protocolSequenceNumber   forKey:@"protocolSequenceNumber"];
  [aCoder encodeObject:self.protocolName          forKey:@"protocolName"];
  [aCoder encodeObject:self.protocolNote          forKey:@"protocolNote"];
  [aCoder encodeObject:self.protocolType          forKey:@"protocolType"];
  [aCoder encodeObject:self.protocolInstructions  forKey:@"protocolInstructions"];
  [aCoder encodeBool:self.printProtocol           forKey:@"printProtocol"];
  [aCoder encodeObject:self.protocolPrograms      forKey:@"protocolPrograms"];
}

//********************************************************
//Return a printable text description of protocol
//If addPrograms is set to true, add the programs to the output
//********************************************************
- (NSString*)textDescription:(bool)addPrograms
{
  NSString* description = [[NSString alloc] init];
  if(!self.printProtocol)
  {
    return description;
  }
  description           = [description stringByAppendingString:@"Protocol Number : "];
  description           = [description stringByAppendingFormat:@"%d", self.protocolSequenceNumber];
  description           = [description stringByAppendingString:@",\tName  : "];
  description           = [description stringByAppendingFormat:@"%@", self.protocolName];
  if(self.protocolNote)
  {
    description         = [description stringByAppendingString:@",\tNote : "];
    description         = [description stringByAppendingFormat:@"%@", self.protocolNote];
  }
  description           = [description stringByAppendingString:@",\tType : "];
  description           = [description stringByAppendingFormat:@"%@", self.protocolType];
  if(self.protocolInstructions)
  {
    description         = [description stringByAppendingString:@",\tInstructions : "];
    description         = [description stringByAppendingFormat:@"%@", self.protocolInstructions];
  }
  description           = [description stringByAppendingString:@"\n"];
  if(addPrograms)
  {
    ProtocolProgram* program;
    for(program in self.protocolPrograms)
    {
      description       = [description stringByAppendingString:[program textDescription]];
      description       = [description stringByAppendingString:@"\n"];
    }
  }
  return description;
}


@end
