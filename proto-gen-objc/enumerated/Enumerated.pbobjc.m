// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: enumerated/enumerated.proto

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

#import <stdatomic.h>

#import "enumerated/Enumerated.pbobjc.h"
// @@protoc_insertion_point(imports)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

#pragma mark - EnumeratedRoot

@implementation EnumeratedRoot

// No extensions in the file and no imports, so no need to generate
// +extensionRegistry.

@end

#pragma mark - Enum DeviceEnum

GPBEnumDescriptor *DeviceEnum_EnumDescriptor(void) {
  static _Atomic(GPBEnumDescriptor*) descriptor = nil;
  if (!descriptor) {
    static const char *valueNames =
        "Web\000Ios\000Android\000";
    static const int32_t values[] = {
        DeviceEnum_Web,
        DeviceEnum_Ios,
        DeviceEnum_Android,
    };
    GPBEnumDescriptor *worker =
        [GPBEnumDescriptor allocDescriptorForName:GPBNSStringifySymbol(DeviceEnum)
                                       valueNames:valueNames
                                           values:values
                                            count:(uint32_t)(sizeof(values) / sizeof(int32_t))
                                     enumVerifier:DeviceEnum_IsValidValue];
    GPBEnumDescriptor *expected = nil;
    if (!atomic_compare_exchange_strong(&descriptor, &expected, worker)) {
      [worker release];
    }
  }
  return descriptor;
}

BOOL DeviceEnum_IsValidValue(int32_t value__) {
  switch (value__) {
    case DeviceEnum_Web:
    case DeviceEnum_Ios:
    case DeviceEnum_Android:
      return YES;
    default:
      return NO;
  }
}

#pragma mark - Enum ChatTypeEnum

GPBEnumDescriptor *ChatTypeEnum_EnumDescriptor(void) {
  static _Atomic(GPBEnumDescriptor*) descriptor = nil;
  if (!descriptor) {
    static const char *valueNames =
        "PeerToPeer\000SimpleGroup\000Group\000Channel\000";
    static const int32_t values[] = {
        ChatTypeEnum_PeerToPeer,
        ChatTypeEnum_SimpleGroup,
        ChatTypeEnum_Group,
        ChatTypeEnum_Channel,
    };
    GPBEnumDescriptor *worker =
        [GPBEnumDescriptor allocDescriptorForName:GPBNSStringifySymbol(ChatTypeEnum)
                                       valueNames:valueNames
                                           values:values
                                            count:(uint32_t)(sizeof(values) / sizeof(int32_t))
                                     enumVerifier:ChatTypeEnum_IsValidValue];
    GPBEnumDescriptor *expected = nil;
    if (!atomic_compare_exchange_strong(&descriptor, &expected, worker)) {
      [worker release];
    }
  }
  return descriptor;
}

BOOL ChatTypeEnum_IsValidValue(int32_t value__) {
  switch (value__) {
    case ChatTypeEnum_PeerToPeer:
    case ChatTypeEnum_SimpleGroup:
    case ChatTypeEnum_Group:
    case ChatTypeEnum_Channel:
      return YES;
    default:
      return NO;
  }
}

#pragma mark - Enum MessageTypeEnum

GPBEnumDescriptor *MessageTypeEnum_EnumDescriptor(void) {
  static _Atomic(GPBEnumDescriptor*) descriptor = nil;
  if (!descriptor) {
    static const char *valueNames =
        "Text\000Audio\000Voice\000Photo\000Video\000File\000";
    static const int32_t values[] = {
        MessageTypeEnum_Text,
        MessageTypeEnum_Audio,
        MessageTypeEnum_Voice,
        MessageTypeEnum_Photo,
        MessageTypeEnum_Video,
        MessageTypeEnum_File,
    };
    GPBEnumDescriptor *worker =
        [GPBEnumDescriptor allocDescriptorForName:GPBNSStringifySymbol(MessageTypeEnum)
                                       valueNames:valueNames
                                           values:values
                                            count:(uint32_t)(sizeof(values) / sizeof(int32_t))
                                     enumVerifier:MessageTypeEnum_IsValidValue];
    GPBEnumDescriptor *expected = nil;
    if (!atomic_compare_exchange_strong(&descriptor, &expected, worker)) {
      [worker release];
    }
  }
  return descriptor;
}

BOOL MessageTypeEnum_IsValidValue(int32_t value__) {
  switch (value__) {
    case MessageTypeEnum_Text:
    case MessageTypeEnum_Audio:
    case MessageTypeEnum_Voice:
    case MessageTypeEnum_Photo:
    case MessageTypeEnum_Video:
    case MessageTypeEnum_File:
      return YES;
    default:
      return NO;
  }
}

#pragma mark - Enum UserStatusEnum

GPBEnumDescriptor *UserStatusEnum_EnumDescriptor(void) {
  static _Atomic(GPBEnumDescriptor*) descriptor = nil;
  if (!descriptor) {
    static const char *valueNames =
        "Unknown\000Online\000Offline\000";
    static const int32_t values[] = {
        UserStatusEnum_Unknown,
        UserStatusEnum_Online,
        UserStatusEnum_Offline,
    };
    GPBEnumDescriptor *worker =
        [GPBEnumDescriptor allocDescriptorForName:GPBNSStringifySymbol(UserStatusEnum)
                                       valueNames:valueNames
                                           values:values
                                            count:(uint32_t)(sizeof(values) / sizeof(int32_t))
                                     enumVerifier:UserStatusEnum_IsValidValue];
    GPBEnumDescriptor *expected = nil;
    if (!atomic_compare_exchange_strong(&descriptor, &expected, worker)) {
      [worker release];
    }
  }
  return descriptor;
}

BOOL UserStatusEnum_IsValidValue(int32_t value__) {
  switch (value__) {
    case UserStatusEnum_Unknown:
    case UserStatusEnum_Online:
    case UserStatusEnum_Offline:
      return YES;
    default:
      return NO;
  }
}

#pragma mark - Enum PhotoSize

GPBEnumDescriptor *PhotoSize_EnumDescriptor(void) {
  static _Atomic(GPBEnumDescriptor*) descriptor = nil;
  if (!descriptor) {
    static const char *valueNames =
        "Blur\000S\000W\000Y\000X\000M\000";
    static const int32_t values[] = {
        PhotoSize_Blur,
        PhotoSize_S,
        PhotoSize_W,
        PhotoSize_Y,
        PhotoSize_X,
        PhotoSize_M,
    };
    GPBEnumDescriptor *worker =
        [GPBEnumDescriptor allocDescriptorForName:GPBNSStringifySymbol(PhotoSize)
                                       valueNames:valueNames
                                           values:values
                                            count:(uint32_t)(sizeof(values) / sizeof(int32_t))
                                     enumVerifier:PhotoSize_IsValidValue];
    GPBEnumDescriptor *expected = nil;
    if (!atomic_compare_exchange_strong(&descriptor, &expected, worker)) {
      [worker release];
    }
  }
  return descriptor;
}

BOOL PhotoSize_IsValidValue(int32_t value__) {
  switch (value__) {
    case PhotoSize_Blur:
    case PhotoSize_S:
    case PhotoSize_W:
    case PhotoSize_Y:
    case PhotoSize_X:
    case PhotoSize_M:
      return YES;
    default:
      return NO;
  }
}


#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)
