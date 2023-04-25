// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: common/file.proto
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

struct Photo {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var fileID: String = String()

  var fileSize: Int64 = 0

  var mimeType: String = String()

  var preview: Data = Data()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Photo: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension Photo: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "Photo"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "file_id"),
    2: .standard(proto: "file_size"),
    3: .standard(proto: "mime_type"),
    8: .same(proto: "preview"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.fileID) }()
      case 2: try { try decoder.decodeSingularInt64Field(value: &self.fileSize) }()
      case 3: try { try decoder.decodeSingularStringField(value: &self.mimeType) }()
      case 8: try { try decoder.decodeSingularBytesField(value: &self.preview) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.fileID.isEmpty {
      try visitor.visitSingularStringField(value: self.fileID, fieldNumber: 1)
    }
    if self.fileSize != 0 {
      try visitor.visitSingularInt64Field(value: self.fileSize, fieldNumber: 2)
    }
    if !self.mimeType.isEmpty {
      try visitor.visitSingularStringField(value: self.mimeType, fieldNumber: 3)
    }
    if !self.preview.isEmpty {
      try visitor.visitSingularBytesField(value: self.preview, fieldNumber: 8)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Photo, rhs: Photo) -> Bool {
    if lhs.fileID != rhs.fileID {return false}
    if lhs.fileSize != rhs.fileSize {return false}
    if lhs.mimeType != rhs.mimeType {return false}
    if lhs.preview != rhs.preview {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
