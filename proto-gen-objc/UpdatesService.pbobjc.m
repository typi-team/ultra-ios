// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: updates_service.proto

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

#import "UpdatesService.pbobjc.h"
#import "common/UpdateTypes.pbobjc.h"
#import "common/User.pbobjc.h"
#import "common/Chat.pbobjc.h"
#import "common/Contact.pbobjc.h"
#import "common/MessageTypes.pbobjc.h"
// @@protoc_insertion_point(imports)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#pragma clang diagnostic ignored "-Wdollar-in-identifier-extension"

#pragma mark - Objective C Class declarations
// Forward declarations of Objective C classes that we can use as
// static values in struct initializers.
// We don't use [Foo class] because it is not a static value.
GPBObjCClassDeclaration(Chat);
GPBObjCClassDeclaration(Contact);
GPBObjCClassDeclaration(Message);
GPBObjCClassDeclaration(User);
GPBObjCClassDeclaration(UserState);

#pragma mark - UpdatesServiceRoot

@implementation UpdatesServiceRoot

// No extensions in the file and none of the imports (direct or indirect)
// defined extensions, so no need to generate +extensionRegistry.

@end

#pragma mark - UpdatesServiceRoot_FileDescriptor

static GPBFileDescriptor *UpdatesServiceRoot_FileDescriptor(void) {
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

#pragma mark - ListenRequest

@implementation ListenRequest

@dynamic hasLocalState, localState;

typedef struct ListenRequest__storage_ {
  uint32_t _has_storage_[1];
  UserState *localState;
} ListenRequest__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "localState",
        .dataTypeSpecific.clazz = GPBObjCClass(UserState),
        .number = ListenRequest_FieldNumber_LocalState,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(ListenRequest__storage_, localState),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[ListenRequest class]
                                     rootClass:[UpdatesServiceRoot class]
                                          file:UpdatesServiceRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(ListenRequest__storage_)
                                         flags:(GPBDescriptorInitializationFlags)(GPBDescriptorInitializationFlag_UsesClassRefs | GPBDescriptorInitializationFlag_Proto3OptionalKnown)];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - InitialStateRequest

@implementation InitialStateRequest


typedef struct InitialStateRequest__storage_ {
  uint32_t _has_storage_[1];
} InitialStateRequest__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[InitialStateRequest class]
                                     rootClass:[UpdatesServiceRoot class]
                                          file:UpdatesServiceRoot_FileDescriptor()
                                        fields:NULL
                                    fieldCount:0
                                   storageSize:sizeof(InitialStateRequest__storage_)
                                         flags:(GPBDescriptorInitializationFlags)(GPBDescriptorInitializationFlag_UsesClassRefs | GPBDescriptorInitializationFlag_Proto3OptionalKnown)];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - InitialStateResponse

@implementation InitialStateResponse

@dynamic state;
@dynamic chatsArray, chatsArray_Count;
@dynamic messagesArray, messagesArray_Count;
@dynamic usersArray, usersArray_Count;
@dynamic contactsArray, contactsArray_Count;

typedef struct InitialStateResponse__storage_ {
  uint32_t _has_storage_[1];
  NSMutableArray *chatsArray;
  NSMutableArray *messagesArray;
  NSMutableArray *usersArray;
  NSMutableArray *contactsArray;
  uint64_t state;
} InitialStateResponse__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "state",
        .dataTypeSpecific.clazz = Nil,
        .number = InitialStateResponse_FieldNumber_State,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(InitialStateResponse__storage_, state),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeUInt64,
      },
      {
        .name = "chatsArray",
        .dataTypeSpecific.clazz = GPBObjCClass(Chat),
        .number = InitialStateResponse_FieldNumber_ChatsArray,
        .hasIndex = GPBNoHasBit,
        .offset = (uint32_t)offsetof(InitialStateResponse__storage_, chatsArray),
        .flags = GPBFieldRepeated,
        .dataType = GPBDataTypeMessage,
      },
      {
        .name = "messagesArray",
        .dataTypeSpecific.clazz = GPBObjCClass(Message),
        .number = InitialStateResponse_FieldNumber_MessagesArray,
        .hasIndex = GPBNoHasBit,
        .offset = (uint32_t)offsetof(InitialStateResponse__storage_, messagesArray),
        .flags = GPBFieldRepeated,
        .dataType = GPBDataTypeMessage,
      },
      {
        .name = "usersArray",
        .dataTypeSpecific.clazz = GPBObjCClass(User),
        .number = InitialStateResponse_FieldNumber_UsersArray,
        .hasIndex = GPBNoHasBit,
        .offset = (uint32_t)offsetof(InitialStateResponse__storage_, usersArray),
        .flags = GPBFieldRepeated,
        .dataType = GPBDataTypeMessage,
      },
      {
        .name = "contactsArray",
        .dataTypeSpecific.clazz = GPBObjCClass(Contact),
        .number = InitialStateResponse_FieldNumber_ContactsArray,
        .hasIndex = GPBNoHasBit,
        .offset = (uint32_t)offsetof(InitialStateResponse__storage_, contactsArray),
        .flags = GPBFieldRepeated,
        .dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[InitialStateResponse class]
                                     rootClass:[UpdatesServiceRoot class]
                                          file:UpdatesServiceRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(InitialStateResponse__storage_)
                                         flags:(GPBDescriptorInitializationFlags)(GPBDescriptorInitializationFlag_UsesClassRefs | GPBDescriptorInitializationFlag_Proto3OptionalKnown)];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - PingRequest

@implementation PingRequest


typedef struct PingRequest__storage_ {
  uint32_t _has_storage_[1];
} PingRequest__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[PingRequest class]
                                     rootClass:[UpdatesServiceRoot class]
                                          file:UpdatesServiceRoot_FileDescriptor()
                                        fields:NULL
                                    fieldCount:0
                                   storageSize:sizeof(PingRequest__storage_)
                                         flags:(GPBDescriptorInitializationFlags)(GPBDescriptorInitializationFlag_UsesClassRefs | GPBDescriptorInitializationFlag_Proto3OptionalKnown)];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - PingResponse

@implementation PingResponse


typedef struct PingResponse__storage_ {
  uint32_t _has_storage_[1];
} PingResponse__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[PingResponse class]
                                     rootClass:[UpdatesServiceRoot class]
                                          file:UpdatesServiceRoot_FileDescriptor()
                                        fields:NULL
                                    fieldCount:0
                                   storageSize:sizeof(PingResponse__storage_)
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
