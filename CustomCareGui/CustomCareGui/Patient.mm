//
//  Patient.mm
//  CustomCareGui
//
//  Created by Mark Frank on 12/22/14.
//  Copyright (c) 2014 MarkFrank. All rights reserved.
//

#import "Patient.h"
#import "CppPatientWriter.h"
#import "CppPatientReader.h"
//#import "CppPatientPrinter.h"
#import "CppDate.h"
#import "TreatmentProtocol.h"
#import "ProtocolProgram.h"
#import "PatientNote.h"

@implementation Patient
@synthesize     patientNumber;
@synthesize     patientLastName;
@synthesize     patientFirstName;
@synthesize     patientNote;
@synthesize     patientZipCode;
@synthesize     patientStreetAddress;
@synthesize     patientCityName;
@synthesize     patientStateName;
@synthesize     patientHomePhone;
@synthesize     patientCellPhone;
@synthesize     patientWorkPhone;
@synthesize     patientDoctorName;
@synthesize     patientMaxTreatmentHours;
@synthesize     patientMaxTreatmentMinutes;
@synthesize     patientExpirationDate;
@synthesize     patientListOfNotes;
@synthesize     patientListOfProtocols;

//********************************************************
// Initialize the patient
//********************************************************
- (id) init
{
  self                        = [super init];
  patientNumber               = 0;
  patientLastName             = @"";
  patientFirstName            = @"";
  patientNote                 = @"";
  patientStreetAddress        = @"";
  patientCityName             = @"";
  patientStateName            = @"";
  patientHomePhone            = @"";
  patientCellPhone            = @"";
  patientWorkPhone            = @"";
  patientDoctorName           = @"";
  patientZipCode              = @"";
  patientMaxTreatmentHours    = 0;
  patientMaxTreatmentMinutes  = 0;
  patientExpirationDate       = [NSDate date];
  patientListOfNotes          = [[NSMutableArray alloc] init];
  patientListOfProtocols      = [[NSMutableArray alloc] init];
  
  return self;
}

//********************************************************
// Save the patient to file using boost::property_tree
//********************************************************
- (bool)savePatientToFilePath:(NSString *)filePath
{
  CppPatientWriter  writer;
  CppPatient        patient;
  if([self copyPatientToCppPatient:&patient])
    return writer.writePatientToFile(patient, [filePath cStringUsingEncoding:NSUTF8StringEncoding]);
  else
    return false;
}

//********************************************************
// Save the patient to file using boost::property_tree
//********************************************************
- (bool)readPatientFromFilePath:(NSString *)filePath
{
  CppPatientReader  reader;
  CppPatient        patient;
   //Read into C++ patient
  if(!reader.readPatientFromFile(patient, [filePath cStringUsingEncoding:NSUTF8StringEncoding]))
  {
    return false;
  }
  //Copy from C++ to Objective-C
  if(![self copyCppToSelf:&patient])
  {
    return false;
  }
  return YES;
}

//********************************************************
// Get the patient prescription as a string
//********************************************************
- (NSString *)getPatientPrescription:(bool)addPrograms
{
  NSString *prescription = [[NSString alloc] init];
  prescription           = [prescription stringByAppendingString:@"Patient Number  : "];
  prescription           = [prescription stringByAppendingFormat:@"%d\n", self.patientNumber];
  prescription           = [prescription stringByAppendingString:@"First Name      : "];
  prescription           = [prescription stringByAppendingFormat:@"%@\n", self.patientFirstName];
  prescription           = [prescription stringByAppendingString:@"Last Name       : "];
  prescription           = [prescription stringByAppendingFormat:@"%@\n", self.patientLastName];
  prescription           = [prescription stringByAppendingString:@"Street Address  : "];
  prescription           = [prescription stringByAppendingFormat:@"%@\n", self.patientStreetAddress];
  prescription           = [prescription stringByAppendingString:@"City            : "];
  prescription           = [prescription stringByAppendingFormat:@"%@\n", self.patientCityName];
  prescription           = [prescription stringByAppendingString:@"State           : "];
  prescription           = [prescription stringByAppendingFormat:@"%@\n", self.patientStateName];
  prescription           = [prescription stringByAppendingString:@"Home Phone      : "];
  prescription           = [prescription stringByAppendingFormat:@"%@\n", self.patientHomePhone];
  prescription           = [prescription stringByAppendingString:@"Cell Phone      : "];
  prescription           = [prescription stringByAppendingFormat:@"%@\n", self.patientCellPhone];
  prescription           = [prescription stringByAppendingString:@"Work Phone      : "];
  prescription           = [prescription stringByAppendingFormat:@"%@\n", self.patientWorkPhone];
  prescription           = [prescription stringByAppendingString:@"Doctor Name     : "];
  prescription           = [prescription stringByAppendingFormat:@"%@\n\n", self.patientDoctorName];

  TreatmentProtocol* protocol       = [[TreatmentProtocol alloc] init];
  for(protocol in patientListOfProtocols)
  {
    prescription         = [prescription stringByAppendingString:@"Protocol Name   : "];
    prescription         = [prescription stringByAppendingFormat:@"%@\n", protocol.protocolName];
    prescription         = [prescription stringByAppendingString:@"Instructions    : "];
    prescription         = [prescription stringByAppendingFormat:@"%@\n", protocol.protocolInstructions];
    prescription         = [prescription stringByAppendingString:@"Note            : "];
    prescription         = [prescription stringByAppendingFormat:@"%@\n\n", protocol.protocolNote];
    if(addPrograms)
    {
      ProtocolProgram* program        = [[ProtocolProgram alloc] init];
      for(program in protocol.protocolPrograms)
      {
        prescription     = [prescription stringByAppendingString:@" Program Number : "];
        prescription     = [prescription stringByAppendingFormat:@"%d\n", program.programSequenceNumber];
        prescription     = [prescription stringByAppendingString:@" Freq1(Hz)      : "];
        prescription     = [prescription stringByAppendingFormat:@"%@\n", program.programFreq1];
        prescription     = [prescription stringByAppendingString:@" Freq2(Hz)      : "];
        prescription     = [prescription stringByAppendingFormat:@"%@\n", program.programFreq2];
        prescription     = [prescription stringByAppendingString:@" Current(microA): "];
        prescription     = [prescription stringByAppendingFormat:@"%@\n", program.programCurrent];
        prescription     = [prescription stringByAppendingString:@" Duration(mins) : "];
        prescription     = [prescription stringByAppendingFormat:@"%@\n", program.programDuration];
        prescription     = [prescription stringByAppendingString:@" Wave Shape     : "];
        prescription     = [prescription stringByAppendingFormat:@"%@\n", program.programWaveShape];
        prescription     = [prescription stringByAppendingString:@" Polarity       : "];
        prescription     = [prescription stringByAppendingFormat:@"%@\n\n", program.programPolarity];
      }
    }
  }
  return prescription;
}

//********************************************************
// Copy the patient to C++ patient in prep for saving to file
//********************************************************
- (bool)copyPatientToCppPatient:(struct CppPatient *)cppPatient
{
  CppDate           date;
  //Copy from objective C to C++
  cppPatient->patientNumber             = patientNumber;
  cppPatient->patientLastName           = [patientLastName      cStringUsingEncoding:NSUTF8StringEncoding];
  cppPatient->patientFirstName          = [patientFirstName     cStringUsingEncoding:NSUTF8StringEncoding];
  cppPatient->patientNote               = [patientNote          cStringUsingEncoding:NSUTF8StringEncoding];
  cppPatient->patientZipCode            = [patientZipCode       cStringUsingEncoding:NSUTF8StringEncoding];
  cppPatient->patientStreetAddress      = [patientStreetAddress cStringUsingEncoding:NSUTF8StringEncoding];
  cppPatient->patientCityName           = [patientCityName      cStringUsingEncoding:NSUTF8StringEncoding];
  cppPatient->patientStateName          = [patientStateName     cStringUsingEncoding:NSUTF8StringEncoding];
  cppPatient->patientHomePhone          = [patientHomePhone     cStringUsingEncoding:NSUTF8StringEncoding];
  cppPatient->patientCellPhone          = [patientCellPhone     cStringUsingEncoding:NSUTF8StringEncoding];
  cppPatient->patientWorkPhone          = [patientWorkPhone     cStringUsingEncoding:NSUTF8StringEncoding];
  cppPatient->patientDoctorName         = [patientDoctorName    cStringUsingEncoding:NSUTF8StringEncoding];
  cppPatient->patientMaxTreatmentHours  = patientMaxTreatmentHours;
  cppPatient->patientMaxTreatmentMinutes= patientMaxTreatmentMinutes;
  NSDateComponents* comps           = [self componentsFromDate:patientExpirationDate];
  date.year                         = (int)[comps year] - 2000;
  date.month                        = (int)[comps month];
  date.day                          = (int)[comps day];
  date.dayOfWeek                    = (int)[comps weekday];
  cppPatient->patientExpirationDate = date;
  PatientNote *note                 = [[PatientNote alloc] init];
  for(note in patientListOfNotes)
  {
    CppPatientNote cppPatientNote;
    cppPatientNote.patientNote         =[note.patientNote        cStringUsingEncoding:NSUTF8StringEncoding];
    cppPatientNote.patientNoteAddedBy  =[note.patientNoteAddedBy cStringUsingEncoding:NSUTF8StringEncoding];
    cppPatientNote.patientNoteAddedDate=[note.patientNoteAddedDate cStringUsingEncoding:NSUTF8StringEncoding];
    cppPatient->patientListOfNotes.push_back(cppPatientNote);
  }
  TreatmentProtocol* protocol       = [[TreatmentProtocol alloc] init];
  for(protocol in patientListOfProtocols)
  {
    CppProtocol cppProtocol;
    cppProtocol.SetProtocolName([protocol.protocolName cStringUsingEncoding:NSUTF8StringEncoding]);
    cppProtocol.SetProtocolInstructions([protocol.protocolInstructions cStringUsingEncoding:NSUTF8StringEncoding]);
    cppProtocol.SetProtocolNote([protocol.protocolNote cStringUsingEncoding:NSUTF8StringEncoding]);
    ProtocolProgram* program        = [[ProtocolProgram alloc] init];
    for(program in protocol.protocolPrograms)
    {
      CppProgram cppProgram;
      cppProgram.m_freq1            = [program.programFreq1     cStringUsingEncoding:NSUTF8StringEncoding];
      cppProgram.m_freq2            = [program.programFreq2     cStringUsingEncoding:NSUTF8StringEncoding];
      cppProgram.m_current          = [program.programCurrent   cStringUsingEncoding:NSUTF8StringEncoding];
      cppProgram.m_duration         = [program.programDuration  cStringUsingEncoding:NSUTF8StringEncoding];
      cppProgram.m_waveShape        = [program.programWaveShape cStringUsingEncoding:NSUTF8StringEncoding];
      cppProgram.m_polarity         = [program.programPolarity  cStringUsingEncoding:NSUTF8StringEncoding];
      cppProtocol.AddNewProgram(cppProgram);
    }
    cppPatient->patientListOfProtocols.push_back(cppProtocol);
  }
  return true;
}

//********************************************************
// Copy a C++ patient to self
//********************************************************
- (bool)copyCppToSelf:(struct CppPatient *)cppPatient
{
  //Copy from C++ to Objective-C
  patientNumber         = cppPatient->patientNumber;
  patientLastName       = [NSString stringWithCString:cppPatient->patientLastName.c_str()
                                           encoding:NSUTF8StringEncoding];
  patientFirstName      = [NSString stringWithCString:cppPatient->patientFirstName.c_str()
                                           encoding:NSUTF8StringEncoding];
  patientNote           = [NSString stringWithCString:cppPatient->patientNote.c_str()
                                           encoding:NSUTF8StringEncoding];
  patientZipCode        = [NSString stringWithCString:cppPatient->patientZipCode.c_str()
                                           encoding:NSUTF8StringEncoding];
  patientStreetAddress  = [NSString stringWithCString:cppPatient->patientStreetAddress.c_str()
                                           encoding:NSUTF8StringEncoding];
  patientCityName       = [NSString stringWithCString:cppPatient->patientCityName.c_str()
                                           encoding:NSUTF8StringEncoding];
  patientStateName      = [NSString stringWithCString:cppPatient->patientStateName.c_str()
                                           encoding:NSUTF8StringEncoding];
  patientHomePhone      = [NSString stringWithCString:cppPatient->patientHomePhone.c_str()
                                           encoding:NSUTF8StringEncoding];
  patientCellPhone      = [NSString stringWithCString:cppPatient->patientCellPhone.c_str()
                                           encoding:NSUTF8StringEncoding];
  patientWorkPhone      = [NSString stringWithCString:cppPatient->patientWorkPhone.c_str()
                                           encoding:NSUTF8StringEncoding];
  patientDoctorName     = [NSString stringWithCString:cppPatient->patientDoctorName.c_str()
                                           encoding:NSUTF8StringEncoding];

  patientMaxTreatmentHours  = cppPatient->patientMaxTreatmentHours;
  NSDateComponents* comps   = [[NSDateComponents alloc] init];
  comps.year                = cppPatient->patientExpirationDate.year + 2000;
  comps.month               = cppPatient->patientExpirationDate.month;
  comps.day                 = cppPatient->patientExpirationDate.day;
  NSCalendar *calendar      = [NSCalendar currentCalendar];
  patientExpirationDate     = [calendar dateFromComponents:comps];
  //Copy the list of notes
  for(int i=0; i<cppPatient->patientListOfNotes.size(); i++)
  {
    PatientNote *patientNotes         = [[PatientNote alloc] init];
    const char* cNote                 = cppPatient->patientListOfNotes[i].patientNote.c_str();
    patientNotes.patientNote          = [NSString stringWithCString:cNote encoding:NSUTF8StringEncoding];
    cNote                             = cppPatient->patientListOfNotes[i].patientNoteAddedBy.c_str();
    patientNotes.patientNoteAddedBy   = [NSString stringWithCString:cNote encoding:NSUTF8StringEncoding];
    cNote                             = cppPatient->patientListOfNotes[i].patientNoteAddedDate.c_str();
    patientNotes.patientNoteAddedDate = [NSString stringWithCString:cNote encoding:NSUTF8StringEncoding];
    [patientListOfNotes addObject:patientNotes];
  }
  //Copy the protocols
  for(int i=0; i<cppPatient->patientListOfProtocols.size(); i++)
  {
    TreatmentProtocol* protocol = [[TreatmentProtocol alloc] init];
    const char* pName           = cppPatient->patientListOfProtocols[i].m_protocolName.c_str();
    protocol.protocolName       = [NSString stringWithCString:pName encoding:NSUTF8StringEncoding];
    const char* pInst           = cppPatient->patientListOfProtocols[i].m_protocolInstructions.c_str();
    protocol.protocolInstructions = [NSString stringWithCString:pInst encoding:NSUTF8StringEncoding];
    const char* pNote           = cppPatient->patientListOfProtocols[i].m_protocolNote.c_str();
    protocol.protocolNote       = [NSString stringWithCString:pNote encoding:NSUTF8StringEncoding];
    protocol.protocolPrograms   = [[NSMutableArray alloc] init];
    //Copy the programs
    for(int j=0; j<cppPatient->patientListOfProtocols[i].m_programs.size(); j++)
    {
      ProtocolProgram * program = [[ProtocolProgram alloc] init];
      program.programSequenceNumber = j+1;
      program.programFreq1      = [NSString stringWithCString:
                                   cppPatient->patientListOfProtocols[i].m_programs[j].m_freq1.c_str()
                                   encoding:NSUTF8StringEncoding];
      program.programFreq2      = [NSString stringWithCString:
                                  cppPatient->patientListOfProtocols[i].m_programs[j].m_freq2.c_str()
                                    encoding:NSUTF8StringEncoding];
      program.programCurrent    = [NSString stringWithCString:
                                  cppPatient->patientListOfProtocols[i].m_programs[j].m_current.c_str()
                                    encoding:NSUTF8StringEncoding];
      program.programDuration   = [NSString stringWithCString:
                                  cppPatient->patientListOfProtocols[i].m_programs[j].m_duration.c_str()
                                    encoding:NSUTF8StringEncoding];
      program.programWaveShape  = [NSString stringWithCString:
                                  cppPatient->patientListOfProtocols[i].m_programs[j].m_waveShape.c_str() encoding:NSUTF8StringEncoding];
      program.programPolarity   = [NSString stringWithCString:
                                  cppPatient->patientListOfProtocols[i].m_programs[j].m_polarity.c_str() encoding:NSUTF8StringEncoding];
      [protocol.protocolPrograms addObject:program];
    }
    [patientListOfProtocols addObject:protocol];
  }
  return YES;
}

//********************************************************
//Set the current date and time and the expiration dates
//********************************************************
- (NSDateComponents *)componentsFromDate:(NSDate*)date
{
    NSCalendar *calendar    = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:NSCalendarUnitYear   |
                                                   NSCalendarUnitMonth  |
                                                   NSCalendarUnitDay    |
                                                   NSCalendarUnitHour   |
                                                   NSCalendarUnitMinute |
                                                   NSCalendarUnitSecond |
                                                   NSCalendarUnitWeekday
                                          fromDate:date];
    return comps;
}

//********************************************************
//Implement NSCoder initWithCoder
//********************************************************
- (id)initWithCoder:(NSCoder *)aDecoder
{
  self  = [super init];
  if(self)
  {
    self.patientNumber              = [aDecoder decodeIntForKey:@"patientNumber"];
    self.patientMaxTreatmentHours   = [aDecoder decodeIntForKey:@"patientMaxTreatmentHours"];
    self.patientMaxTreatmentMinutes = [aDecoder decodeIntForKey:@"patientMaxTreatmentMinutes"];
    self.patientLastName            = [aDecoder decodeObjectForKey:@"patientLastName"];
    self.patientFirstName           = [aDecoder decodeObjectForKey:@"patientFirstName"];
    self.patientNote                = [aDecoder decodeObjectForKey:@"patientNote"];
    self.patientZipCode             = [aDecoder decodeObjectForKey:@"patientZipCode"];
    self.patientStreetAddress       = [aDecoder decodeObjectForKey:@"patientStreetAddress"];
    self.patientCityName            = [aDecoder decodeObjectForKey:@"patientCityName"];
    self.patientStateName           = [aDecoder decodeObjectForKey:@"patientStateName"];
    self.patientHomePhone           = [aDecoder decodeObjectForKey:@"patientHomePhone"];
    self.patientCellPhone           = [aDecoder decodeObjectForKey:@"patientCellPhone"];
    self.patientWorkPhone           = [aDecoder decodeObjectForKey:@"patientWorkPhone"];
    self.patientDoctorName          = [aDecoder decodeObjectForKey:@"patientDoctorName"];
    self.patientExpirationDate      = [aDecoder decodeObjectForKey:@"patientExpirationDate"];
    self.patientListOfNotes         = [aDecoder decodeObjectForKey:@"patientListOfNotes"];
    self.patientListOfProtocols     = [aDecoder decodeObjectForKey:@"patientListOfProtocols"];
  }
  return self;
}

//********************************************************
//Implement NSCoder encodeWithCoder
//********************************************************
- (void)encodeWithCoder:(NSCoder *)aCoder
{
  [aCoder encodeInt:self.patientNumber              forKey:@"patientNumber"];
  [aCoder encodeInt:self.patientMaxTreatmentHours   forKey:@"patientMaxTreatmentHours"];
  [aCoder encodeInt:self.patientMaxTreatmentMinutes forKey:@"patientMaxTreatmentMinutes"];

  [aCoder encodeObject:self.patientLastName         forKey:@"patientLastName"];
  [aCoder encodeObject:self.patientFirstName        forKey:@"patientFirstName"];
  [aCoder encodeObject:self.patientNote             forKey:@"patientNote"];
  [aCoder encodeObject:self.patientZipCode          forKey:@"patientZipCode"];
  [aCoder encodeObject:self.patientStreetAddress    forKey:@"patientStreetAddress"];
  [aCoder encodeObject:self.patientCityName         forKey:@"patientCityName"];
  [aCoder encodeObject:self.patientStateName        forKey:@"patientStateName"];
  [aCoder encodeObject:self.patientHomePhone        forKey:@"patientHomePhone"];
  [aCoder encodeObject:self.patientCellPhone        forKey:@"patientCellPhone"];
  [aCoder encodeObject:self.patientWorkPhone        forKey:@"patientWorkPhone"];
  [aCoder encodeObject:self.patientDoctorName       forKey:@"patientDoctorName"];
  [aCoder encodeObject:self.patientExpirationDate   forKey:@"patientExpirationDate"];
  [aCoder encodeObject:self.patientListOfNotes      forKey:@"patientListOfNotes"];
  [aCoder encodeObject:self.patientListOfProtocols  forKey:@"patientListOfProtocols"];
}


@end