// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: file_service.proto
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

struct FileChunk {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var fileID: String = String()

  var data: Data = Data()

  var seqNum: Int64 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct FileCreateRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var name: String = String()

  var size: Int64 = 0

  var mimeType: String = String()

  var chunks: [FileChunk] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct FileUploadChunksRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var fileID: String = String()

  var chunks: [FileChunk] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct FileDownloadRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var fileID: String = String()

  var fromChunkNumber: Int64 = 0

  var toChunkNumber: Int64 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct FileCreateResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var fileID: String = String()

  var chunkSize: Int64 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct FileUploadAcceptedChunks {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var fileID: String = String()

  var acceptedChunks: [Int64] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct FileUploadResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct GetUploadedChunksRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var fileID: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct GetUploadedChunksResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var chunks: [Int64] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct PhotoDownloadRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var fileID: String = String()

  var size: PhotoSize = .blur

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

#if swift(>=5.5) && canImport(_Concurrency)
extension FileChunk: @unchecked Sendable {}
extension FileCreateRequest: @unchecked Sendable {}
extension FileUploadChunksRequest: @unchecked Sendable {}
extension FileDownloadRequest: @unchecked Sendable {}
extension FileCreateResponse: @unchecked Sendable {}
extension FileUploadAcceptedChunks: @unchecked Sendable {}
extension FileUploadResponse: @unchecked Sendable {}
extension GetUploadedChunksRequest: @unchecked Sendable {}
extension GetUploadedChunksResponse: @unchecked Sendable {}
extension PhotoDownloadRequest: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension FileChunk: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "FileChunk"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "file_id"),
    2: .same(proto: "data"),
    3: .standard(proto: "seq_num"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.fileID) }()
      case 2: try { try decoder.decodeSingularBytesField(value: &self.data) }()
      case 3: try { try decoder.decodeSingularInt64Field(value: &self.seqNum) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.fileID.isEmpty {
      try visitor.visitSingularStringField(value: self.fileID, fieldNumber: 1)
    }
    if !self.data.isEmpty {
      try visitor.visitSingularBytesField(value: self.data, fieldNumber: 2)
    }
    if self.seqNum != 0 {
      try visitor.visitSingularInt64Field(value: self.seqNum, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: FileChunk, rhs: FileChunk) -> Bool {
    if lhs.fileID != rhs.fileID {return false}
    if lhs.data != rhs.data {return false}
    if lhs.seqNum != rhs.seqNum {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension FileCreateRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "FileCreateRequest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "name"),
    2: .same(proto: "size"),
    3: .same(proto: "mimeType"),
    4: .same(proto: "chunks"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.name) }()
      case 2: try { try decoder.decodeSingularInt64Field(value: &self.size) }()
      case 3: try { try decoder.decodeSingularStringField(value: &self.mimeType) }()
      case 4: try { try decoder.decodeRepeatedMessageField(value: &self.chunks) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.name.isEmpty {
      try visitor.visitSingularStringField(value: self.name, fieldNumber: 1)
    }
    if self.size != 0 {
      try visitor.visitSingularInt64Field(value: self.size, fieldNumber: 2)
    }
    if !self.mimeType.isEmpty {
      try visitor.visitSingularStringField(value: self.mimeType, fieldNumber: 3)
    }
    if !self.chunks.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.chunks, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: FileCreateRequest, rhs: FileCreateRequest) -> Bool {
    if lhs.name != rhs.name {return false}
    if lhs.size != rhs.size {return false}
    if lhs.mimeType != rhs.mimeType {return false}
    if lhs.chunks != rhs.chunks {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension FileUploadChunksRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "FileUploadChunksRequest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "file_id"),
    2: .same(proto: "chunks"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.fileID) }()
      case 2: try { try decoder.decodeRepeatedMessageField(value: &self.chunks) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.fileID.isEmpty {
      try visitor.visitSingularStringField(value: self.fileID, fieldNumber: 1)
    }
    if !self.chunks.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.chunks, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: FileUploadChunksRequest, rhs: FileUploadChunksRequest) -> Bool {
    if lhs.fileID != rhs.fileID {return false}
    if lhs.chunks != rhs.chunks {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension FileDownloadRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "FileDownloadRequest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "file_id"),
    2: .standard(proto: "from_chunk_number"),
    3: .standard(proto: "to_chunk_number"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.fileID) }()
      case 2: try { try decoder.decodeSingularInt64Field(value: &self.fromChunkNumber) }()
      case 3: try { try decoder.decodeSingularInt64Field(value: &self.toChunkNumber) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.fileID.isEmpty {
      try visitor.visitSingularStringField(value: self.fileID, fieldNumber: 1)
    }
    if self.fromChunkNumber != 0 {
      try visitor.visitSingularInt64Field(value: self.fromChunkNumber, fieldNumber: 2)
    }
    if self.toChunkNumber != 0 {
      try visitor.visitSingularInt64Field(value: self.toChunkNumber, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: FileDownloadRequest, rhs: FileDownloadRequest) -> Bool {
    if lhs.fileID != rhs.fileID {return false}
    if lhs.fromChunkNumber != rhs.fromChunkNumber {return false}
    if lhs.toChunkNumber != rhs.toChunkNumber {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension FileCreateResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "FileCreateResponse"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "file_id"),
    2: .standard(proto: "chunk_size"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.fileID) }()
      case 2: try { try decoder.decodeSingularInt64Field(value: &self.chunkSize) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.fileID.isEmpty {
      try visitor.visitSingularStringField(value: self.fileID, fieldNumber: 1)
    }
    if self.chunkSize != 0 {
      try visitor.visitSingularInt64Field(value: self.chunkSize, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: FileCreateResponse, rhs: FileCreateResponse) -> Bool {
    if lhs.fileID != rhs.fileID {return false}
    if lhs.chunkSize != rhs.chunkSize {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension FileUploadAcceptedChunks: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "FileUploadAcceptedChunks"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "file_id"),
    2: .standard(proto: "accepted_chunks"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.fileID) }()
      case 2: try { try decoder.decodeRepeatedInt64Field(value: &self.acceptedChunks) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.fileID.isEmpty {
      try visitor.visitSingularStringField(value: self.fileID, fieldNumber: 1)
    }
    if !self.acceptedChunks.isEmpty {
      try visitor.visitPackedInt64Field(value: self.acceptedChunks, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: FileUploadAcceptedChunks, rhs: FileUploadAcceptedChunks) -> Bool {
    if lhs.fileID != rhs.fileID {return false}
    if lhs.acceptedChunks != rhs.acceptedChunks {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension FileUploadResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "FileUploadResponse"
  static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let _ = try decoder.nextFieldNumber() {
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: FileUploadResponse, rhs: FileUploadResponse) -> Bool {
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension GetUploadedChunksRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "GetUploadedChunksRequest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "file_id"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.fileID) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.fileID.isEmpty {
      try visitor.visitSingularStringField(value: self.fileID, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: GetUploadedChunksRequest, rhs: GetUploadedChunksRequest) -> Bool {
    if lhs.fileID != rhs.fileID {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension GetUploadedChunksResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "GetUploadedChunksResponse"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "chunks"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedInt64Field(value: &self.chunks) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.chunks.isEmpty {
      try visitor.visitPackedInt64Field(value: self.chunks, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: GetUploadedChunksResponse, rhs: GetUploadedChunksResponse) -> Bool {
    if lhs.chunks != rhs.chunks {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension PhotoDownloadRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "PhotoDownloadRequest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "file_id"),
    2: .same(proto: "size"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.fileID) }()
      case 2: try { try decoder.decodeSingularEnumField(value: &self.size) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.fileID.isEmpty {
      try visitor.visitSingularStringField(value: self.fileID, fieldNumber: 1)
    }
    if self.size != .blur {
      try visitor.visitSingularEnumField(value: self.size, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: PhotoDownloadRequest, rhs: PhotoDownloadRequest) -> Bool {
    if lhs.fileID != rhs.fileID {return false}
    if lhs.size != rhs.size {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
