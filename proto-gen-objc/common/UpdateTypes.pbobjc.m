// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: common/update_types.proto

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

#import "common/UpdateTypes.pbobjc.h"
#import "common/MessageTypes.pbobjc.h"
#import "common/Contact.pbobjc.h"
#import "common/User.pbobjc.h"
// @@protoc_insertion_point(imports)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#pragma clang diagnostic ignored "-Wdirect-ivar-access"
#pragma clang diagnostic ignored "-Wdollar-in-identifier-extension"

#pragma mark - Objective C Class declarations
// Forward declarations of Objective C classes that we can use as
// static values in struct initializers.
// We don't use [Foo class] because it is not a static value.
GPBObjCClassDeclaration(Contact);
GPBObjCClassDeclaration(Message);
GPBObjCClassDeclaration(MessagesDeleted);
GPBObjCClassDeclaration(MessagesDelivered);
GPBObjCClassDeclaration(MessagesRange);
GPBObjCClassDeclaration(MessagesRead);
GPBObjCClassDeclaration(Update);
GPBObjCClassDeclaration(UserAudioRecording);
GPBObjCClassDeclaration(UserStatus);
GPBObjCClassDeclaration(UserTyping);

#pragma mark - UpdateTypesRoot

@implementation UpdateTypesRoot

// No extensions in the file and none of the imports (direct or indirect)
// defined extensions, so no need to generate +extensionRegistry.

@end

#pragma mark - UpdateTypesRoot_FileDescriptor

static GPBFileDescriptor *UpdateTypesRoot_FileDescriptor(void) {
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

#pragma mark - MessagesDelivered

@implementation MessagesDelivered

@dynamic chatId;
@dynamic userId;
@dynamic maxSeqNumber;

typedef struct MessagesDelivered__storage_ {
  uint32_t _has_storage_[1];
  NSString *chatId;
  NSString *userId;
  uint64_t maxSeqNumber;
} MessagesDelivered__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "chatId",
        .dataTypeSpecific.clazz = Nil,
        .number = MessagesDelivered_FieldNumber_ChatId,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(MessagesDelivered__storage_, chatId),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "userId",
        .dataTypeSpecific.clazz = Nil,
        .number = MessagesDelivered_FieldNumber_UserId,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(MessagesDelivered__storage_, userId),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "maxSeqNumber",
        .dataTypeSpecific.clazz = Nil,
        .number = MessagesDelivered_FieldNumber_MaxSeqNumber,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(MessagesDelivered__storage_, maxSeqNumber),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeUInt64,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[MessagesDelivered class]
                                     rootClass:[UpdateTypesRoot class]
                                          file:UpdateTypesRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(MessagesDelivered__storage_)
                                         flags:(GPBDescriptorInitializationFlags)(GPBDescriptorInitializationFlag_UsesClassRefs | GPBDescriptorInitializationFlag_Proto3OptionalKnown)];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - MessagesRead

@implementation MessagesRead

@dynamic chatId;
@dynamic userId;
@dynamic maxSeqNumber;

typedef struct MessagesRead__storage_ {
  uint32_t _has_storage_[1];
  NSString *chatId;
  NSString *userId;
  uint64_t maxSeqNumber;
} MessagesRead__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "chatId",
        .dataTypeSpecific.clazz = Nil,
        .number = MessagesRead_FieldNumber_ChatId,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(MessagesRead__storage_, chatId),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "userId",
        .dataTypeSpecific.clazz = Nil,
        .number = MessagesRead_FieldNumber_UserId,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(MessagesRead__storage_, userId),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "maxSeqNumber",
        .dataTypeSpecific.clazz = Nil,
        .number = MessagesRead_FieldNumber_MaxSeqNumber,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(MessagesRead__storage_, maxSeqNumber),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeUInt64,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[MessagesRead class]
                                     rootClass:[UpdateTypesRoot class]
                                          file:UpdateTypesRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(MessagesRead__storage_)
                                         flags:(GPBDescriptorInitializationFlags)(GPBDescriptorInitializationFlag_UsesClassRefs | GPBDescriptorInitializationFlag_Proto3OptionalKnown)];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - MessagesDeleted

@implementation MessagesDeleted

@dynamic chatId;
@dynamic rangeArray, rangeArray_Count;

typedef struct MessagesDeleted__storage_ {
  uint32_t _has_storage_[1];
  NSString *chatId;
  NSMutableArray *rangeArray;
} MessagesDeleted__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "chatId",
        .dataTypeSpecific.clazz = Nil,
        .number = MessagesDeleted_FieldNumber_ChatId,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(MessagesDeleted__storage_, chatId),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "rangeArray",
        .dataTypeSpecific.clazz = GPBObjCClass(MessagesRange),
        .number = MessagesDeleted_FieldNumber_RangeArray,
        .hasIndex = GPBNoHasBit,
        .offset = (uint32_t)offsetof(MessagesDeleted__storage_, rangeArray),
        .flags = GPBFieldRepeated,
        .dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[MessagesDeleted class]
                                     rootClass:[UpdateTypesRoot class]
                                          file:UpdateTypesRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(MessagesDeleted__storage_)
                                         flags:(GPBDescriptorInitializationFlags)(GPBDescriptorInitializationFlag_UsesClassRefs | GPBDescriptorInitializationFlag_Proto3OptionalKnown)];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - UserTyping

@implementation UserTyping

@dynamic chatId;
@dynamic userId;

typedef struct UserTyping__storage_ {
  uint32_t _has_storage_[1];
  NSString *chatId;
  NSString *userId;
} UserTyping__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "chatId",
        .dataTypeSpecific.clazz = Nil,
        .number = UserTyping_FieldNumber_ChatId,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(UserTyping__storage_, chatId),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "userId",
        .dataTypeSpecific.clazz = Nil,
        .number = UserTyping_FieldNumber_UserId,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(UserTyping__storage_, userId),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[UserTyping class]
                                     rootClass:[UpdateTypesRoot class]
                                          file:UpdateTypesRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(UserTyping__storage_)
                                         flags:(GPBDescriptorInitializationFlags)(GPBDescriptorInitializationFlag_UsesClassRefs | GPBDescriptorInitializationFlag_Proto3OptionalKnown)];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - UserAudioRecording

@implementation UserAudioRecording

@dynamic chatId;
@dynamic userId;

typedef struct UserAudioRecording__storage_ {
  uint32_t _has_storage_[1];
  NSString *chatId;
  NSString *userId;
} UserAudioRecording__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "chatId",
        .dataTypeSpecific.clazz = Nil,
        .number = UserAudioRecording_FieldNumber_ChatId,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(UserAudioRecording__storage_, chatId),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "userId",
        .dataTypeSpecific.clazz = Nil,
        .number = UserAudioRecording_FieldNumber_UserId,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(UserAudioRecording__storage_, userId),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[UserAudioRecording class]
                                     rootClass:[UpdateTypesRoot class]
                                          file:UpdateTypesRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(UserAudioRecording__storage_)
                                         flags:(GPBDescriptorInitializationFlags)(GPBDescriptorInitializationFlag_UsesClassRefs | GPBDescriptorInitializationFlag_Proto3OptionalKnown)];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - Update

@implementation Update

@dynamic ofUpdateOneOfCase;
@dynamic ofPresenceOneOfCase;
@dynamic state;
@dynamic message;
@dynamic contact;
@dynamic messagesDelivered;
@dynamic messagesRead;
@dynamic messagesDeleted;
@dynamic typing;
@dynamic audioRecording;
@dynamic userStatus;

typedef struct Update__storage_ {
  uint32_t _has_storage_[3];
  Message *message;
  Contact *contact;
  MessagesDelivered *messagesDelivered;
  MessagesRead *messagesRead;
  UserTyping *typing;
  UserAudioRecording *audioRecording;
  UserStatus *userStatus;
  MessagesDeleted *messagesDeleted;
  uint64_t state;
} Update__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "state",
        .dataTypeSpecific.clazz = Nil,
        .number = Update_FieldNumber_State,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(Update__storage_, state),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeUInt64,
      },
      {
        .name = "message",
        .dataTypeSpecific.clazz = GPBObjCClass(Message),
        .number = Update_FieldNumber_Message,
        .hasIndex = -1,
        .offset = (uint32_t)offsetof(Update__storage_, message),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
      {
        .name = "contact",
        .dataTypeSpecific.clazz = GPBObjCClass(Contact),
        .number = Update_FieldNumber_Contact,
        .hasIndex = -1,
        .offset = (uint32_t)offsetof(Update__storage_, contact),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
      {
        .name = "messagesDelivered",
        .dataTypeSpecific.clazz = GPBObjCClass(MessagesDelivered),
        .number = Update_FieldNumber_MessagesDelivered,
        .hasIndex = -1,
        .offset = (uint32_t)offsetof(Update__storage_, messagesDelivered),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
      {
        .name = "messagesRead",
        .dataTypeSpecific.clazz = GPBObjCClass(MessagesRead),
        .number = Update_FieldNumber_MessagesRead,
        .hasIndex = -1,
        .offset = (uint32_t)offsetof(Update__storage_, messagesRead),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
      {
        .name = "typing",
        .dataTypeSpecific.clazz = GPBObjCClass(UserTyping),
        .number = Update_FieldNumber_Typing,
        .hasIndex = -2,
        .offset = (uint32_t)offsetof(Update__storage_, typing),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
      {
        .name = "audioRecording",
        .dataTypeSpecific.clazz = GPBObjCClass(UserAudioRecording),
        .number = Update_FieldNumber_AudioRecording,
        .hasIndex = -2,
        .offset = (uint32_t)offsetof(Update__storage_, audioRecording),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeMessage,
      },
      {
        .name = "userStatus",
        .dataTypeSpecific.clazz = GPBObjCClass(UserStatus),
        .number = Update_FieldNumber_UserStatus,
        .hasIndex = -2,
        .offset = (uint32_t)offsetof(Update__storage_, userStatus),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
      {
        .name = "messagesDeleted",
        .dataTypeSpecific.clazz = GPBObjCClass(MessagesDeleted),
        .number = Update_FieldNumber_MessagesDeleted,
        .hasIndex = -1,
        .offset = (uint32_t)offsetof(Update__storage_, messagesDeleted),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[Update class]
                                     rootClass:[UpdateTypesRoot class]
                                          file:UpdateTypesRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(Update__storage_)
                                         flags:(GPBDescriptorInitializationFlags)(GPBDescriptorInitializationFlag_UsesClassRefs | GPBDescriptorInitializationFlag_Proto3OptionalKnown)];
    static const char *oneofs[] = {
      "ofUpdate",
      "ofPresence",
    };
    [localDescriptor setupOneofs:oneofs
                           count:(uint32_t)(sizeof(oneofs) / sizeof(char*))
                   firstHasIndex:-1];
#if !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    static const char *extraTextFormatInfo =
        "\001\t\016\000";
    [localDescriptor setupExtraTextInfo:extraTextFormatInfo];
#endif  // !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

void Update_ClearOfUpdateOneOfCase(Update *message) {
  GPBDescriptor *descriptor = [Update descriptor];
  GPBOneofDescriptor *oneof = [descriptor.oneofs objectAtIndex:0];
  GPBClearOneof(message, oneof);
}
void Update_ClearOfPresenceOneOfCase(Update *message) {
  GPBDescriptor *descriptor = [Update descriptor];
  GPBOneofDescriptor *oneof = [descriptor.oneofs objectAtIndex:1];
  GPBClearOneof(message, oneof);
}
#pragma mark - Updates

@implementation Updates

@dynamic lastState;
@dynamic count;
@dynamic updatesArray, updatesArray_Count;

typedef struct Updates__storage_ {
  uint32_t _has_storage_[1];
  NSMutableArray *updatesArray;
  uint64_t lastState;
  int64_t count;
} Updates__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "lastState",
        .dataTypeSpecific.clazz = Nil,
        .number = Updates_FieldNumber_LastState,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(Updates__storage_, lastState),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeUInt64,
      },
      {
        .name = "count",
        .dataTypeSpecific.clazz = Nil,
        .number = Updates_FieldNumber_Count,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(Updates__storage_, count),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeInt64,
      },
      {
        .name = "updatesArray",
        .dataTypeSpecific.clazz = GPBObjCClass(Update),
        .number = Updates_FieldNumber_UpdatesArray,
        .hasIndex = GPBNoHasBit,
        .offset = (uint32_t)offsetof(Updates__storage_, updatesArray),
        .flags = GPBFieldRepeated,
        .dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[Updates class]
                                     rootClass:[UpdateTypesRoot class]
                                          file:UpdateTypesRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(Updates__storage_)
                                         flags:(GPBDescriptorInitializationFlags)(GPBDescriptorInitializationFlag_UsesClassRefs | GPBDescriptorInitializationFlag_Proto3OptionalKnown)];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end


#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)
