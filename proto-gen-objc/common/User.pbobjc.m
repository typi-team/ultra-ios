// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: common/user.proto

// This CPP symbol can be defined to use imports that match up to the framework
// imports needed when using CocoaPods.
#if !defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS)
 #define GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS 0
#endif

#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
 #import <Protobuf/GPBProtocolBuffers_RuntimeSupport.h>
#else
 #import "GPBProtocolBuffers_RuntimeSupport.h"
#endif

#import "common/User.pbobjc.h"
#import "enumerated/Enumerated.pbobjc.h"
// @@protoc_insertion_point(imports)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

#pragma mark - UserRoot

@implementation UserRoot

// No extensions in the file and none of the imports (direct or indirect)
// defined extensions, so no need to generate +extensionRegistry.

@end

#pragma mark - UserRoot_FileDescriptor

static GPBFileDescriptor *UserRoot_FileDescriptor(void) {
  // This is called by +initialize so there is no need to worry
  // about thread safety of the singleton.
  static GPBFileDescriptor *descriptor = NULL;
  if (!descriptor) {
    GPB_DEBUG_CHECK_RUNTIME_VERSIONS();
    descriptor = [[GPBFileDescriptor alloc] initWithPackage:@""
                                                     syntax:GPBFileSyntaxProto3];
  }
  return descriptor;
}

#pragma mark - UserState

@implementation UserState

@dynamic state;

typedef struct UserState__storage_ {
  uint32_t _has_storage_[1];
  uint64_t state;
} UserState__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "state",
        .dataTypeSpecific.clazz = Nil,
        .number = UserState_FieldNumber_State,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(UserState__storage_, state),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeUInt64,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[UserState class]
                                     rootClass:[UserRoot class]
                                          file:UserRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(UserState__storage_)
                                         flags:(GPBDescriptorInitializationFlags)(GPBDescriptorInitializationFlag_UsesClassRefs | GPBDescriptorInitializationFlag_Proto3OptionalKnown)];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - User

@implementation User

@dynamic id_p;
@dynamic nickname;
@dynamic firstname;
@dynamic lastname;
@dynamic phone;
@dynamic photo;

typedef struct User__storage_ {
  uint32_t _has_storage_[1];
  NSString *id_p;
  NSString *nickname;
  NSString *firstname;
  NSString *lastname;
  NSString *phone;
  NSString *photo;
} User__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "id_p",
        .dataTypeSpecific.clazz = Nil,
        .number = User_FieldNumber_Id_p,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(User__storage_, id_p),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "nickname",
        .dataTypeSpecific.clazz = Nil,
        .number = User_FieldNumber_Nickname,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(User__storage_, nickname),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "firstname",
        .dataTypeSpecific.clazz = Nil,
        .number = User_FieldNumber_Firstname,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(User__storage_, firstname),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "lastname",
        .dataTypeSpecific.clazz = Nil,
        .number = User_FieldNumber_Lastname,
        .hasIndex = 3,
        .offset = (uint32_t)offsetof(User__storage_, lastname),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "phone",
        .dataTypeSpecific.clazz = Nil,
        .number = User_FieldNumber_Phone,
        .hasIndex = 4,
        .offset = (uint32_t)offsetof(User__storage_, phone),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "photo",
        .dataTypeSpecific.clazz = Nil,
        .number = User_FieldNumber_Photo,
        .hasIndex = 5,
        .offset = (uint32_t)offsetof(User__storage_, photo),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[User class]
                                     rootClass:[UserRoot class]
                                          file:UserRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(User__storage_)
                                         flags:(GPBDescriptorInitializationFlags)(GPBDescriptorInitializationFlag_UsesClassRefs | GPBDescriptorInitializationFlag_Proto3OptionalKnown)];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - UserStatus

@implementation UserStatus

@dynamic userId;
@dynamic status;
@dynamic lastSeen;

typedef struct UserStatus__storage_ {
  uint32_t _has_storage_[1];
  UserStatusEnum status;
  NSString *userId;
  int64_t lastSeen;
} UserStatus__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "userId",
        .dataTypeSpecific.clazz = Nil,
        .number = UserStatus_FieldNumber_UserId,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(UserStatus__storage_, userId),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "status",
        .dataTypeSpecific.enumDescFunc = UserStatusEnum_EnumDescriptor,
        .number = UserStatus_FieldNumber_Status,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(UserStatus__storage_, status),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldHasEnumDescriptor | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeEnum,
      },
      {
        .name = "lastSeen",
        .dataTypeSpecific.clazz = Nil,
        .number = UserStatus_FieldNumber_LastSeen,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(UserStatus__storage_, lastSeen),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeInt64,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[UserStatus class]
                                     rootClass:[UserRoot class]
                                          file:UserRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(UserStatus__storage_)
                                         flags:(GPBDescriptorInitializationFlags)(GPBDescriptorInitializationFlag_UsesClassRefs | GPBDescriptorInitializationFlag_Proto3OptionalKnown)];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

int32_t UserStatus_Status_RawValue(UserStatus *message) {
  GPBDescriptor *descriptor = [UserStatus descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:UserStatus_FieldNumber_Status];
  return GPBGetMessageRawEnumField(message, field);
}

void SetUserStatus_Status_RawValue(UserStatus *message, int32_t value) {
  GPBDescriptor *descriptor = [UserStatus descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:UserStatus_FieldNumber_Status];
  GPBSetMessageRawEnumField(message, field, value);
}


#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)
