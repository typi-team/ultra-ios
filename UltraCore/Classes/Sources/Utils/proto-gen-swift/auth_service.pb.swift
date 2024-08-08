// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: auth_service.proto
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

struct IssueJwtRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// User id
  var userID: String = String()

  /// Unique ID for user device
  var deviceID: String = String()

  /// Device type
  var device: DeviceEnum = .web

  /// optional, needed for integration authorizations
  /// when session id retrieved from external service
  var sessionID: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct CreateTestUserRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var phone: String = String()

  var firstname: String = String()

  var lastname: String = String()

  var group: String = String()

  var reception: String = String()

  var supportReceptions: [String] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct CreateTestUserResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var code: Int32 = 0

  var message: String = String()

  var userID: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// Comment
struct IssueJwtResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var token: String = String()

  var userID: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

#if swift(>=5.5) && canImport(_Concurrency)
extension IssueJwtRequest: @unchecked Sendable {}
extension CreateTestUserRequest: @unchecked Sendable {}
extension CreateTestUserResponse: @unchecked Sendable {}
extension IssueJwtResponse: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension IssueJwtRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "IssueJwtRequest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "user_id"),
    2: .standard(proto: "device_id"),
    3: .same(proto: "device"),
    4: .standard(proto: "session_id"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.userID) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.deviceID) }()
      case 3: try { try decoder.decodeSingularEnumField(value: &self.device) }()
      case 4: try { try decoder.decodeSingularStringField(value: &self.sessionID) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.userID.isEmpty {
      try visitor.visitSingularStringField(value: self.userID, fieldNumber: 1)
    }
    if !self.deviceID.isEmpty {
      try visitor.visitSingularStringField(value: self.deviceID, fieldNumber: 2)
    }
    if self.device != .web {
      try visitor.visitSingularEnumField(value: self.device, fieldNumber: 3)
    }
    if !self.sessionID.isEmpty {
      try visitor.visitSingularStringField(value: self.sessionID, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: IssueJwtRequest, rhs: IssueJwtRequest) -> Bool {
    if lhs.userID != rhs.userID {return false}
    if lhs.deviceID != rhs.deviceID {return false}
    if lhs.device != rhs.device {return false}
    if lhs.sessionID != rhs.sessionID {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension CreateTestUserRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "CreateTestUserRequest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "phone"),
    2: .same(proto: "firstname"),
    3: .same(proto: "lastname"),
    4: .same(proto: "group"),
    5: .same(proto: "reception"),
    6: .standard(proto: "support_receptions"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.phone) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.firstname) }()
      case 3: try { try decoder.decodeSingularStringField(value: &self.lastname) }()
      case 4: try { try decoder.decodeSingularStringField(value: &self.group) }()
      case 5: try { try decoder.decodeSingularStringField(value: &self.reception) }()
      case 6: try { try decoder.decodeRepeatedStringField(value: &self.supportReceptions) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.phone.isEmpty {
      try visitor.visitSingularStringField(value: self.phone, fieldNumber: 1)
    }
    if !self.firstname.isEmpty {
      try visitor.visitSingularStringField(value: self.firstname, fieldNumber: 2)
    }
    if !self.lastname.isEmpty {
      try visitor.visitSingularStringField(value: self.lastname, fieldNumber: 3)
    }
    if !self.group.isEmpty {
      try visitor.visitSingularStringField(value: self.group, fieldNumber: 4)
    }
    if !self.reception.isEmpty {
      try visitor.visitSingularStringField(value: self.reception, fieldNumber: 5)
    }
    if !self.supportReceptions.isEmpty {
      try visitor.visitRepeatedStringField(value: self.supportReceptions, fieldNumber: 6)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: CreateTestUserRequest, rhs: CreateTestUserRequest) -> Bool {
    if lhs.phone != rhs.phone {return false}
    if lhs.firstname != rhs.firstname {return false}
    if lhs.lastname != rhs.lastname {return false}
    if lhs.group != rhs.group {return false}
    if lhs.reception != rhs.reception {return false}
    if lhs.supportReceptions != rhs.supportReceptions {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension CreateTestUserResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "CreateTestUserResponse"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "code"),
    2: .same(proto: "message"),
    3: .standard(proto: "user_id"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularInt32Field(value: &self.code) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.message) }()
      case 3: try { try decoder.decodeSingularStringField(value: &self.userID) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.code != 0 {
      try visitor.visitSingularInt32Field(value: self.code, fieldNumber: 1)
    }
    if !self.message.isEmpty {
      try visitor.visitSingularStringField(value: self.message, fieldNumber: 2)
    }
    if !self.userID.isEmpty {
      try visitor.visitSingularStringField(value: self.userID, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: CreateTestUserResponse, rhs: CreateTestUserResponse) -> Bool {
    if lhs.code != rhs.code {return false}
    if lhs.message != rhs.message {return false}
    if lhs.userID != rhs.userID {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension IssueJwtResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "IssueJwtResponse"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "token"),
    2: .standard(proto: "user_id"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.token) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.userID) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.token.isEmpty {
      try visitor.visitSingularStringField(value: self.token, fieldNumber: 1)
    }
    if !self.userID.isEmpty {
      try visitor.visitSingularStringField(value: self.userID, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: IssueJwtResponse, rhs: IssueJwtResponse) -> Bool {
    if lhs.token != rhs.token {return false}
    if lhs.userID != rhs.userID {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
