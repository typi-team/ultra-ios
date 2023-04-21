// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: enumerated/enumerated.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

enum DeviceEnum: SwiftProtobuf.Enum {
  typealias RawValue = Int
  case web // = 0
  case ios // = 1
  case android // = 2
  case UNRECOGNIZED(Int)

  init() {
    self = .web
  }

  init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .web
    case 1: self = .ios
    case 2: self = .android
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  var rawValue: Int {
    switch self {
    case .web: return 0
    case .ios: return 1
    case .android: return 2
    case .UNRECOGNIZED(let i): return i
    }
  }

}

#if swift(>=4.2)

extension DeviceEnum: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  static var allCases: [DeviceEnum] = [
    .web,
    .ios,
    .android,
  ]
}

#endif  // swift(>=4.2)

enum ChatTypeEnum: SwiftProtobuf.Enum {
  typealias RawValue = Int
  case peerToPeer // = 0
  case simpleGroup // = 1
  case group // = 2
  case channel // = 3
  case UNRECOGNIZED(Int)

  init() {
    self = .peerToPeer
  }

  init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .peerToPeer
    case 1: self = .simpleGroup
    case 2: self = .group
    case 3: self = .channel
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  var rawValue: Int {
    switch self {
    case .peerToPeer: return 0
    case .simpleGroup: return 1
    case .group: return 2
    case .channel: return 3
    case .UNRECOGNIZED(let i): return i
    }
  }

}

#if swift(>=4.2)

extension ChatTypeEnum: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  static var allCases: [ChatTypeEnum] = [
    .peerToPeer,
    .simpleGroup,
    .group,
    .channel,
  ]
}

#endif  // swift(>=4.2)

enum MessageTypeEnum: SwiftProtobuf.Enum {
  typealias RawValue = Int
  case text // = 0
  case audio // = 1
  case voice // = 2
  case photo // = 3
  case video // = 4
  case file // = 5
  case UNRECOGNIZED(Int)

  init() {
    self = .text
  }

  init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .text
    case 1: self = .audio
    case 2: self = .voice
    case 3: self = .photo
    case 4: self = .video
    case 5: self = .file
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  var rawValue: Int {
    switch self {
    case .text: return 0
    case .audio: return 1
    case .voice: return 2
    case .photo: return 3
    case .video: return 4
    case .file: return 5
    case .UNRECOGNIZED(let i): return i
    }
  }

}

#if swift(>=4.2)

extension MessageTypeEnum: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  static var allCases: [MessageTypeEnum] = [
    .text,
    .audio,
    .voice,
    .photo,
    .video,
    .file,
  ]
}

#endif  // swift(>=4.2)

enum UserStatusEnum: SwiftProtobuf.Enum {
  typealias RawValue = Int
  case unknown // = 0
  case online // = 1
  case offline // = 2
  case away // = 3
  case UNRECOGNIZED(Int)

  init() {
    self = .unknown
  }

  init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .unknown
    case 1: self = .online
    case 2: self = .offline
    case 3: self = .away
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  var rawValue: Int {
    switch self {
    case .unknown: return 0
    case .online: return 1
    case .offline: return 2
    case .away: return 3
    case .UNRECOGNIZED(let i): return i
    }
  }

}

#if swift(>=4.2)

extension UserStatusEnum: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  static var allCases: [UserStatusEnum] = [
    .unknown,
    .online,
    .offline,
    .away,
  ]
}

#endif  // swift(>=4.2)

/// Available photo sizes
enum PhotoSize: SwiftProtobuf.Enum {
  typealias RawValue = Int

  /// Image size with applied gaussian blur filter.
  /// Width is 100, quality will be decreased to 50%,
  /// can be used for preview photos
  case blur // = 0

  /// width=100, quality=90%, height will be changed by keeping sides ratio
  case s // = 1

  /// width=2560, quality=90%, height will be changed by keeping sides ratio
  case w // = 2

  /// width=1280, quality=90%, height will be changed by keeping sides ratio
  case y // = 3

  /// width=800, quality=90%, height will be changed by keeping sides ratio
  case x // = 4

  /// width=320, quality=90%, height will be changed by keeping sides ratio
  case m // = 5
  case UNRECOGNIZED(Int)

  init() {
    self = .blur
  }

  init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .blur
    case 1: self = .s
    case 2: self = .w
    case 3: self = .y
    case 4: self = .x
    case 5: self = .m
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  var rawValue: Int {
    switch self {
    case .blur: return 0
    case .s: return 1
    case .w: return 2
    case .y: return 3
    case .x: return 4
    case .m: return 5
    case .UNRECOGNIZED(let i): return i
    }
  }

}

#if swift(>=4.2)

extension PhotoSize: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  static var allCases: [PhotoSize] = [
    .blur,
    .s,
    .w,
    .y,
    .x,
    .m,
  ]
}

#endif  // swift(>=4.2)

#if swift(>=5.5) && canImport(_Concurrency)
extension DeviceEnum: @unchecked Sendable {}
extension ChatTypeEnum: @unchecked Sendable {}
extension MessageTypeEnum: @unchecked Sendable {}
extension UserStatusEnum: @unchecked Sendable {}
extension PhotoSize: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension DeviceEnum: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "WEB"),
    1: .same(proto: "IOS"),
    2: .same(proto: "ANDROID"),
  ]
}

extension ChatTypeEnum: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "PEER_TO_PEER"),
    1: .same(proto: "SIMPLE_GROUP"),
    2: .same(proto: "GROUP"),
    3: .same(proto: "CHANNEL"),
  ]
}

extension MessageTypeEnum: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "TEXT"),
    1: .same(proto: "AUDIO"),
    2: .same(proto: "VOICE"),
    3: .same(proto: "PHOTO"),
    4: .same(proto: "VIDEO"),
    5: .same(proto: "FILE"),
  ]
}

extension UserStatusEnum: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "UNKNOWN"),
    1: .same(proto: "ONLINE"),
    2: .same(proto: "OFFLINE"),
    3: .same(proto: "AWAY"),
  ]
}

extension PhotoSize: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "BLUR"),
    1: .same(proto: "S"),
    2: .same(proto: "W"),
    3: .same(proto: "Y"),
    4: .same(proto: "X"),
    5: .same(proto: "M"),
  ]
}
