//
//  Patient.h
//  CustomCareGui
//
//  Created by Mark Frank on 12/22/14.
//  Copyright (c) 2014 MarkFrank. All rights reserved.
//

#import <Foundation/Foundation.h>
struct CppPatient;
@interface Patient : NSObject <NSCoding>
{
}

@property          int             patientNumber;
@property (strong) NSString*       patientLastName;
@property (strong) NSString*       patientFirstName;
@property (strong) NSString*       patientNote;
@property (strong) NSString*       patientZipCode;
@property (strong) NSString*       patientStreetAddress;
@property (strong) NSString*       patientCityName;
@property (strong) NSString*       patientStateName;
@property (strong) NSString*       patientHomePhone;
@property (strong) NSString*       patientCellPhone;
@property (strong) NSString*       patientWorkPhone;
@property (strong) NSString*       patientDoctorName;
@property          int             patientMaxTreatmentHours;
@property          int             patientMaxTreatmentMinutes;
@property (strong) NSDate*         patientExpirationDate;
@property (strong) NSMutableArray* patientListOfNotes;
@property (strong) NSMutableArray* patientListOfProtocols;

- (bool)savePatientToFilePath:            (NSString *)         filePath;
- (bool)readPatientFromFilePath:          (NSString *)         filePath;
- (NSString *)getPatientPrescription:     (bool)               addPrograms;
- (NSDateComponents *)componentsFromDate: (NSDate *  )         date;
- (bool)copyPatientToCppPatient:          (struct CppPatient *)cppPatient;
- (bool)copyCppToSelf:                    (struct CppPatient *)cppPatient;

//NSCoding methods in order to do deep copy using archive/unarchive
- (id)initWithCoder:    (NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder*) encoder;

@end
