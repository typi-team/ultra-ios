// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: support_service.proto
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

struct SupportAssignManagerRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Support chat id
  var chatID: String = String()

  /// Manager user id
  var userID: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct SupportAssignManagerResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var state: UInt64 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct SupportUnassignManagerRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Support chat id
  var chatID: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct SupportUnassignManagerResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var state: UInt64 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct SupportStatusUpdateRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var chatID: String = String()

  var status: SupportChatStatusEnum = .supportChatStatusClosed

  /// This field actual only if status=SUPPORT_CHAT_STATUS_POSTPONED, otherwise ignored.
  /// Maximum 24 hours from time of method execution. 
  /// Format: UnixMicro
  var postponeTime: Int64 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct SupportStatusUpdateResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var state: UInt64 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct SupportSetManagersRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var phones: [String] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct SupportSetManagersResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var users: [User] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct InitSupportChatsRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var receptions: [InitSupportChatsRequest.Reception] = []

  var managers: [InitSupportChatsRequest.PersonalManager] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  struct Reception {
    // SwiftProtobuf.Message conformance is added in an extension below. See the
    // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
    // methods supported on all messages.

    var name: String = String()

    var reception: String = String()

    var unknownFields = SwiftProtobuf.UnknownStorage()

    init() {}
  }

  struct PersonalManager {
    // SwiftProtobuf.Message conformance is added in an extension below. See the
    // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
    // methods supported on all messages.

    var name: String = String()

    var phone: String = String()

    var unknownFields = SwiftProtobuf.UnknownStorage()

    init() {}
  }

  init() {}
}

struct InitSupportChatsResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var chats: [Chat] = []

  var messages: [Message] = []

  var users: [User] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct GetSupportChatsRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var limit: Int64 = 0

  var skip: Int64 = 0

  /// Use to filter by support chat status
  var status: [SupportChatStatusEnum] = []

  /// Assigned support manager user id. Provide
  /// empty value to get all (assigned and non assigned) 
  /// support chats
  var assignedUserID: String = String()

  var receptions: [String] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct GetSupportChatsResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var chats: [Chat] = []

  var messages: [Message] = []

  var users: [User] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

#if swift(>=5.5) && canImport(_Concurrency)
extension SupportAssignManagerRequest: @unchecked Sendable {}
extension SupportAssignManagerResponse: @unchecked Sendable {}
extension SupportUnassignManagerRequest: @unchecked Sendable {}
extension SupportUnassignManagerResponse: @unchecked Sendable {}
extension SupportStatusUpdateRequest: @unchecked Sendable {}
extension SupportStatusUpdateResponse: @unchecked Sendable {}
extension SupportSetManagersRequest: @unchecked Sendable {}
extension SupportSetManagersResponse: @unchecked Sendable {}
extension InitSupportChatsRequest: @unchecked Sendable {}
extension InitSupportChatsRequest.Reception: @unchecked Sendable {}
extension InitSupportChatsRequest.PersonalManager: @unchecked Sendable {}
extension InitSupportChatsResponse: @unchecked Sendable {}
extension GetSupportChatsRequest: @unchecked Sendable {}
extension GetSupportChatsResponse: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension SupportAssignManagerRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "SupportAssignManagerRequest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "chat_id"),
    2: .standard(proto: "user_id"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.chatID) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.userID) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.chatID.isEmpty {
      try visitor.visitSingularStringField(value: self.chatID, fieldNumber: 1)
    }
    if !self.userID.isEmpty {
      try visitor.visitSingularStringField(value: self.userID, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: SupportAssignManagerRequest, rhs: SupportAssignManagerRequest) -> Bool {
    if lhs.chatID != rhs.chatID {return false}
    if lhs.userID != rhs.userID {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension SupportAssignManagerResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "SupportAssignManagerResponse"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "state"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularUInt64Field(value: &self.state) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.state != 0 {
      try visitor.visitSingularUInt64Field(value: self.state, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: SupportAssignManagerResponse, rhs: SupportAssignManagerResponse) -> Bool {
    if lhs.state != rhs.state {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension SupportUnassignManagerRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "SupportUnassignManagerRequest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "chat_id"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.chatID) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.chatID.isEmpty {
      try visitor.visitSingularStringField(value: self.chatID, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: SupportUnassignManagerRequest, rhs: SupportUnassignManagerRequest) -> Bool {
    if lhs.chatID != rhs.chatID {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension SupportUnassignManagerResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "SupportUnassignManagerResponse"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "state"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularUInt64Field(value: &self.state) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.state != 0 {
      try visitor.visitSingularUInt64Field(value: self.state, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: SupportUnassignManagerResponse, rhs: SupportUnassignManagerResponse) -> Bool {
    if lhs.state != rhs.state {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension SupportStatusUpdateRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "SupportStatusUpdateRequest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "chat_id"),
    2: .same(proto: "status"),
    3: .standard(proto: "postpone_time"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.chatID) }()
      case 2: try { try decoder.decodeSingularEnumField(value: &self.status) }()
      case 3: try { try decoder.decodeSingularInt64Field(value: &self.postponeTime) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.chatID.isEmpty {
      try visitor.visitSingularStringField(value: self.chatID, fieldNumber: 1)
    }
    if self.status != .supportChatStatusClosed {
      try visitor.visitSingularEnumField(value: self.status, fieldNumber: 2)
    }
    if self.postponeTime != 0 {
      try visitor.visitSingularInt64Field(value: self.postponeTime, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: SupportStatusUpdateRequest, rhs: SupportStatusUpdateRequest) -> Bool {
    if lhs.chatID != rhs.chatID {return false}
    if lhs.status != rhs.status {return false}
    if lhs.postponeTime != rhs.postponeTime {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension SupportStatusUpdateResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "SupportStatusUpdateResponse"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "state"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularUInt64Field(value: &self.state) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.state != 0 {
      try visitor.visitSingularUInt64Field(value: self.state, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: SupportStatusUpdateResponse, rhs: SupportStatusUpdateResponse) -> Bool {
    if lhs.state != rhs.state {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension SupportSetManagersRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "SupportSetManagersRequest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "phones"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedStringField(value: &self.phones) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.phones.isEmpty {
      try visitor.visitRepeatedStringField(value: self.phones, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: SupportSetManagersRequest, rhs: SupportSetManagersRequest) -> Bool {
    if lhs.phones != rhs.phones {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension SupportSetManagersResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "SupportSetManagersResponse"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "users"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedMessageField(value: &self.users) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.users.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.users, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: SupportSetManagersResponse, rhs: SupportSetManagersResponse) -> Bool {
    if lhs.users != rhs.users {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension InitSupportChatsRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "InitSupportChatsRequest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "receptions"),
    2: .same(proto: "managers"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedMessageField(value: &self.receptions) }()
      case 2: try { try decoder.decodeRepeatedMessageField(value: &self.managers) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.receptions.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.receptions, fieldNumber: 1)
    }
    if !self.managers.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.managers, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: InitSupportChatsRequest, rhs: InitSupportChatsRequest) -> Bool {
    if lhs.receptions != rhs.receptions {return false}
    if lhs.managers != rhs.managers {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension InitSupportChatsRequest.Reception: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = InitSupportChatsRequest.protoMessageName + ".Reception"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "name"),
    2: .same(proto: "reception"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.name) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.reception) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.name.isEmpty {
      try visitor.visitSingularStringField(value: self.name, fieldNumber: 1)
    }
    if !self.reception.isEmpty {
      try visitor.visitSingularStringField(value: self.reception, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: InitSupportChatsRequest.Reception, rhs: InitSupportChatsRequest.Reception) -> Bool {
    if lhs.name != rhs.name {return false}
    if lhs.reception != rhs.reception {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension InitSupportChatsRequest.PersonalManager: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = InitSupportChatsRequest.protoMessageName + ".PersonalManager"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "name"),
    2: .same(proto: "phone"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.name) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.phone) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.name.isEmpty {
      try visitor.visitSingularStringField(value: self.name, fieldNumber: 1)
    }
    if !self.phone.isEmpty {
      try visitor.visitSingularStringField(value: self.phone, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: InitSupportChatsRequest.PersonalManager, rhs: InitSupportChatsRequest.PersonalManager) -> Bool {
    if lhs.name != rhs.name {return false}
    if lhs.phone != rhs.phone {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension InitSupportChatsResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "InitSupportChatsResponse"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "chats"),
    2: .same(proto: "messages"),
    3: .same(proto: "users"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedMessageField(value: &self.chats) }()
      case 2: try { try decoder.decodeRepeatedMessageField(value: &self.messages) }()
      case 3: try { try decoder.decodeRepeatedMessageField(value: &self.users) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.chats.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.chats, fieldNumber: 1)
    }
    if !self.messages.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.messages, fieldNumber: 2)
    }
    if !self.users.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.users, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: InitSupportChatsResponse, rhs: InitSupportChatsResponse) -> Bool {
    if lhs.chats != rhs.chats {return false}
    if lhs.messages != rhs.messages {return false}
    if lhs.users != rhs.users {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension GetSupportChatsRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "GetSupportChatsRequest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "limit"),
    2: .same(proto: "skip"),
    3: .same(proto: "status"),
    4: .standard(proto: "assigned_user_id"),
    5: .same(proto: "receptions"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularInt64Field(value: &self.limit) }()
      case 2: try { try decoder.decodeSingularInt64Field(value: &self.skip) }()
      case 3: try { try decoder.decodeRepeatedEnumField(value: &self.status) }()
      case 4: try { try decoder.decodeSingularStringField(value: &self.assignedUserID) }()
      case 5: try { try decoder.decodeRepeatedStringField(value: &self.receptions) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.limit != 0 {
      try visitor.visitSingularInt64Field(value: self.limit, fieldNumber: 1)
    }
    if self.skip != 0 {
      try visitor.visitSingularInt64Field(value: self.skip, fieldNumber: 2)
    }
    if !self.status.isEmpty {
      try visitor.visitPackedEnumField(value: self.status, fieldNumber: 3)
    }
    if !self.assignedUserID.isEmpty {
      try visitor.visitSingularStringField(value: self.assignedUserID, fieldNumber: 4)
    }
    if !self.receptions.isEmpty {
      try visitor.visitRepeatedStringField(value: self.receptions, fieldNumber: 5)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: GetSupportChatsRequest, rhs: GetSupportChatsRequest) -> Bool {
    if lhs.limit != rhs.limit {return false}
    if lhs.skip != rhs.skip {return false}
    if lhs.status != rhs.status {return false}
    if lhs.assignedUserID != rhs.assignedUserID {return false}
    if lhs.receptions != rhs.receptions {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension GetSupportChatsResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "GetSupportChatsResponse"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    3: .same(proto: "chats"),
    4: .same(proto: "messages"),
    5: .same(proto: "users"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 3: try { try decoder.decodeRepeatedMessageField(value: &self.chats) }()
      case 4: try { try decoder.decodeRepeatedMessageField(value: &self.messages) }()
      case 5: try { try decoder.decodeRepeatedMessageField(value: &self.users) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.chats.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.chats, fieldNumber: 3)
    }
    if !self.messages.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.messages, fieldNumber: 4)
    }
    if !self.users.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.users, fieldNumber: 5)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: GetSupportChatsResponse, rhs: GetSupportChatsResponse) -> Bool {
    if lhs.chats != rhs.chats {return false}
    if lhs.messages != rhs.messages {return false}
    if lhs.users != rhs.users {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
