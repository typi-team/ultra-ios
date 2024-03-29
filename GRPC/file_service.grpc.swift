//
// DO NOT EDIT.
//
// Generated by the protocol buffer compiler.
// Source: file_service.proto
//

//
// Copyright 2018, gRPC Authors All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
import GRPC
import NIO
import NIOConcurrencyHelpers
import SwiftProtobuf


/// Usage: instantiate `FileServiceClient`, then call methods of this protocol to make API calls.
internal protocol FileServiceClientProtocol: GRPCClient {
  var serviceName: String { get }
  var interceptors: FileServiceClientInterceptorFactoryProtocol? { get }

  func create(
    _ request: FileCreateRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<FileCreateRequest, FileCreateResponse>

  func upload(
    callOptions: CallOptions?
  ) -> ClientStreamingCall<FileChunk, FileUploadResponse>

  func getUploadedChunks(
    _ request: GetUploadedChunksRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<GetUploadedChunksRequest, GetUploadedChunksResponse>

  func download(
    _ request: FileDownloadRequest,
    callOptions: CallOptions?,
    handler: @escaping (FileChunk) -> Void
  ) -> ServerStreamingCall<FileDownloadRequest, FileChunk>

  func downloadPhoto(
    _ request: PhotoDownloadRequest,
    callOptions: CallOptions?,
    handler: @escaping (FileChunk) -> Void
  ) -> ServerStreamingCall<PhotoDownloadRequest, FileChunk>
}

extension FileServiceClientProtocol {
  internal var serviceName: String {
    return "FileService"
  }

  /// Unary call to Create
  ///
  /// - Parameters:
  ///   - request: Request to send to Create.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func create(
    _ request: FileCreateRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<FileCreateRequest, FileCreateResponse> {
    return self.makeUnaryCall(
      path: FileServiceClientMetadata.Methods.create.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeCreateInterceptors() ?? []
    )
  }

  /// Client streaming call to Upload
  ///
  /// Callers should use the `send` method on the returned object to send messages
  /// to the server. The caller should send an `.end` after the final message has been sent.
  ///
  /// - Parameters:
  ///   - callOptions: Call options.
  /// - Returns: A `ClientStreamingCall` with futures for the metadata, status and response.
  internal func upload(
    callOptions: CallOptions? = nil
  ) -> ClientStreamingCall<FileChunk, FileUploadResponse> {
    return self.makeClientStreamingCall(
      path: FileServiceClientMetadata.Methods.upload.path,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeUploadInterceptors() ?? []
    )
  }

  /// Unary call to GetUploadedChunks
  ///
  /// - Parameters:
  ///   - request: Request to send to GetUploadedChunks.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func getUploadedChunks(
    _ request: GetUploadedChunksRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<GetUploadedChunksRequest, GetUploadedChunksResponse> {
    return self.makeUnaryCall(
      path: FileServiceClientMetadata.Methods.getUploadedChunks.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetUploadedChunksInterceptors() ?? []
    )
  }

  /// Server streaming call to Download
  ///
  /// - Parameters:
  ///   - request: Request to send to Download.
  ///   - callOptions: Call options.
  ///   - handler: A closure called when each response is received from the server.
  /// - Returns: A `ServerStreamingCall` with futures for the metadata and status.
  internal func download(
    _ request: FileDownloadRequest,
    callOptions: CallOptions? = nil,
    handler: @escaping (FileChunk) -> Void
  ) -> ServerStreamingCall<FileDownloadRequest, FileChunk> {
    return self.makeServerStreamingCall(
      path: FileServiceClientMetadata.Methods.download.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeDownloadInterceptors() ?? [],
      handler: handler
    )
  }

  /// Server streaming call to DownloadPhoto
  ///
  /// - Parameters:
  ///   - request: Request to send to DownloadPhoto.
  ///   - callOptions: Call options.
  ///   - handler: A closure called when each response is received from the server.
  /// - Returns: A `ServerStreamingCall` with futures for the metadata and status.
  internal func downloadPhoto(
    _ request: PhotoDownloadRequest,
    callOptions: CallOptions? = nil,
    handler: @escaping (FileChunk) -> Void
  ) -> ServerStreamingCall<PhotoDownloadRequest, FileChunk> {
    return self.makeServerStreamingCall(
      path: FileServiceClientMetadata.Methods.downloadPhoto.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeDownloadPhotoInterceptors() ?? [],
      handler: handler
    )
  }
}

#if compiler(>=5.6)
@available(*, deprecated)
extension FileServiceClient: @unchecked Sendable {}
#endif // compiler(>=5.6)

@available(*, deprecated, renamed: "FileServiceNIOClient")
internal final class FileServiceClient: FileServiceClientProtocol {
  private let lock = Lock()
  private var _defaultCallOptions: CallOptions
  private var _interceptors: FileServiceClientInterceptorFactoryProtocol?
  internal let channel: GRPCChannel
  internal var defaultCallOptions: CallOptions {
    get { self.lock.withLock { return self._defaultCallOptions } }
    set { self.lock.withLockVoid { self._defaultCallOptions = newValue } }
  }
  internal var interceptors: FileServiceClientInterceptorFactoryProtocol? {
    get { self.lock.withLock { return self._interceptors } }
    set { self.lock.withLockVoid { self._interceptors = newValue } }
  }

  /// Creates a client for the FileService service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  internal init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: FileServiceClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self._defaultCallOptions = defaultCallOptions
    self._interceptors = interceptors
  }
}

internal struct FileServiceNIOClient: FileServiceClientProtocol {
  internal var channel: GRPCChannel
  internal var defaultCallOptions: CallOptions
  internal var interceptors: FileServiceClientInterceptorFactoryProtocol?

  /// Creates a client for the FileService service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  internal init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: FileServiceClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

#if compiler(>=5.6)
@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
internal protocol FileServiceAsyncClientProtocol: GRPCClient {
  static var serviceDescriptor: GRPCServiceDescriptor { get }
  var interceptors: FileServiceClientInterceptorFactoryProtocol? { get }

  func makeCreateCall(
    _ request: FileCreateRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncUnaryCall<FileCreateRequest, FileCreateResponse>

  func makeUploadCall(
    callOptions: CallOptions?
  ) -> GRPCAsyncClientStreamingCall<FileChunk, FileUploadResponse>

  func makeGetUploadedChunksCall(
    _ request: GetUploadedChunksRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncUnaryCall<GetUploadedChunksRequest, GetUploadedChunksResponse>

  func makeDownloadCall(
    _ request: FileDownloadRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncServerStreamingCall<FileDownloadRequest, FileChunk>

  func makeDownloadPhotoCall(
    _ request: PhotoDownloadRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncServerStreamingCall<PhotoDownloadRequest, FileChunk>
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension FileServiceAsyncClientProtocol {
  internal static var serviceDescriptor: GRPCServiceDescriptor {
    return FileServiceClientMetadata.serviceDescriptor
  }

  internal var interceptors: FileServiceClientInterceptorFactoryProtocol? {
    return nil
  }

  internal func makeCreateCall(
    _ request: FileCreateRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncUnaryCall<FileCreateRequest, FileCreateResponse> {
    return self.makeAsyncUnaryCall(
      path: FileServiceClientMetadata.Methods.create.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeCreateInterceptors() ?? []
    )
  }

  internal func makeUploadCall(
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncClientStreamingCall<FileChunk, FileUploadResponse> {
    return self.makeAsyncClientStreamingCall(
      path: FileServiceClientMetadata.Methods.upload.path,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeUploadInterceptors() ?? []
    )
  }

  internal func makeGetUploadedChunksCall(
    _ request: GetUploadedChunksRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncUnaryCall<GetUploadedChunksRequest, GetUploadedChunksResponse> {
    return self.makeAsyncUnaryCall(
      path: FileServiceClientMetadata.Methods.getUploadedChunks.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetUploadedChunksInterceptors() ?? []
    )
  }

  internal func makeDownloadCall(
    _ request: FileDownloadRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncServerStreamingCall<FileDownloadRequest, FileChunk> {
    return self.makeAsyncServerStreamingCall(
      path: FileServiceClientMetadata.Methods.download.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeDownloadInterceptors() ?? []
    )
  }

  internal func makeDownloadPhotoCall(
    _ request: PhotoDownloadRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncServerStreamingCall<PhotoDownloadRequest, FileChunk> {
    return self.makeAsyncServerStreamingCall(
      path: FileServiceClientMetadata.Methods.downloadPhoto.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeDownloadPhotoInterceptors() ?? []
    )
  }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension FileServiceAsyncClientProtocol {
  internal func create(
    _ request: FileCreateRequest,
    callOptions: CallOptions? = nil
  ) async throws -> FileCreateResponse {
    return try await self.performAsyncUnaryCall(
      path: FileServiceClientMetadata.Methods.create.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeCreateInterceptors() ?? []
    )
  }

  internal func upload<RequestStream>(
    _ requests: RequestStream,
    callOptions: CallOptions? = nil
  ) async throws -> FileUploadResponse where RequestStream: Sequence, RequestStream.Element == FileChunk {
    return try await self.performAsyncClientStreamingCall(
      path: FileServiceClientMetadata.Methods.upload.path,
      requests: requests,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeUploadInterceptors() ?? []
    )
  }

  internal func upload<RequestStream>(
    _ requests: RequestStream,
    callOptions: CallOptions? = nil
  ) async throws -> FileUploadResponse where RequestStream: AsyncSequence & Sendable, RequestStream.Element == FileChunk {
    return try await self.performAsyncClientStreamingCall(
      path: FileServiceClientMetadata.Methods.upload.path,
      requests: requests,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeUploadInterceptors() ?? []
    )
  }

  internal func getUploadedChunks(
    _ request: GetUploadedChunksRequest,
    callOptions: CallOptions? = nil
  ) async throws -> GetUploadedChunksResponse {
    return try await self.performAsyncUnaryCall(
      path: FileServiceClientMetadata.Methods.getUploadedChunks.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetUploadedChunksInterceptors() ?? []
    )
  }

  internal func download(
    _ request: FileDownloadRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncResponseStream<FileChunk> {
    return self.performAsyncServerStreamingCall(
      path: FileServiceClientMetadata.Methods.download.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeDownloadInterceptors() ?? []
    )
  }

  internal func downloadPhoto(
    _ request: PhotoDownloadRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncResponseStream<FileChunk> {
    return self.performAsyncServerStreamingCall(
      path: FileServiceClientMetadata.Methods.downloadPhoto.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeDownloadPhotoInterceptors() ?? []
    )
  }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
internal struct FileServiceAsyncClient: FileServiceAsyncClientProtocol {
  internal var channel: GRPCChannel
  internal var defaultCallOptions: CallOptions
  internal var interceptors: FileServiceClientInterceptorFactoryProtocol?

  internal init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: FileServiceClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

#endif // compiler(>=5.6)

internal protocol FileServiceClientInterceptorFactoryProtocol: GRPCSendable {

  /// - Returns: Interceptors to use when invoking 'create'.
  func makeCreateInterceptors() -> [ClientInterceptor<FileCreateRequest, FileCreateResponse>]

  /// - Returns: Interceptors to use when invoking 'upload'.
  func makeUploadInterceptors() -> [ClientInterceptor<FileChunk, FileUploadResponse>]

  /// - Returns: Interceptors to use when invoking 'getUploadedChunks'.
  func makeGetUploadedChunksInterceptors() -> [ClientInterceptor<GetUploadedChunksRequest, GetUploadedChunksResponse>]

  /// - Returns: Interceptors to use when invoking 'download'.
  func makeDownloadInterceptors() -> [ClientInterceptor<FileDownloadRequest, FileChunk>]

  /// - Returns: Interceptors to use when invoking 'downloadPhoto'.
  func makeDownloadPhotoInterceptors() -> [ClientInterceptor<PhotoDownloadRequest, FileChunk>]
}

internal enum FileServiceClientMetadata {
  internal static let serviceDescriptor = GRPCServiceDescriptor(
    name: "FileService",
    fullName: "FileService",
    methods: [
      FileServiceClientMetadata.Methods.create,
      FileServiceClientMetadata.Methods.upload,
      FileServiceClientMetadata.Methods.getUploadedChunks,
      FileServiceClientMetadata.Methods.download,
      FileServiceClientMetadata.Methods.downloadPhoto,
    ]
  )

  internal enum Methods {
    internal static let create = GRPCMethodDescriptor(
      name: "Create",
      path: "/FileService/Create",
      type: GRPCCallType.unary
    )

    internal static let upload = GRPCMethodDescriptor(
      name: "Upload",
      path: "/FileService/Upload",
      type: GRPCCallType.clientStreaming
    )

    internal static let getUploadedChunks = GRPCMethodDescriptor(
      name: "GetUploadedChunks",
      path: "/FileService/GetUploadedChunks",
      type: GRPCCallType.unary
    )

    internal static let download = GRPCMethodDescriptor(
      name: "Download",
      path: "/FileService/Download",
      type: GRPCCallType.serverStreaming
    )

    internal static let downloadPhoto = GRPCMethodDescriptor(
      name: "DownloadPhoto",
      path: "/FileService/DownloadPhoto",
      type: GRPCCallType.serverStreaming
    )
  }
}

/// To build a server, implement a class that conforms to this protocol.
internal protocol FileServiceProvider: CallHandlerProvider {
  var interceptors: FileServiceServerInterceptorFactoryProtocol? { get }

  func create(request: FileCreateRequest, context: StatusOnlyCallContext) -> EventLoopFuture<FileCreateResponse>

  func upload(context: UnaryResponseCallContext<FileUploadResponse>) -> EventLoopFuture<(StreamEvent<FileChunk>) -> Void>

  func getUploadedChunks(request: GetUploadedChunksRequest, context: StatusOnlyCallContext) -> EventLoopFuture<GetUploadedChunksResponse>

  func download(request: FileDownloadRequest, context: StreamingResponseCallContext<FileChunk>) -> EventLoopFuture<GRPCStatus>

  func downloadPhoto(request: PhotoDownloadRequest, context: StreamingResponseCallContext<FileChunk>) -> EventLoopFuture<GRPCStatus>
}

extension FileServiceProvider {
  internal var serviceName: Substring {
    return FileServiceServerMetadata.serviceDescriptor.fullName[...]
  }

  /// Determines, calls and returns the appropriate request handler, depending on the request's method.
  /// Returns nil for methods not handled by this service.
  internal func handle(
    method name: Substring,
    context: CallHandlerContext
  ) -> GRPCServerHandlerProtocol? {
    switch name {
    case "Create":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<FileCreateRequest>(),
        responseSerializer: ProtobufSerializer<FileCreateResponse>(),
        interceptors: self.interceptors?.makeCreateInterceptors() ?? [],
        userFunction: self.create(request:context:)
      )

    case "Upload":
      return ClientStreamingServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<FileChunk>(),
        responseSerializer: ProtobufSerializer<FileUploadResponse>(),
        interceptors: self.interceptors?.makeUploadInterceptors() ?? [],
        observerFactory: self.upload(context:)
      )

    case "GetUploadedChunks":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<GetUploadedChunksRequest>(),
        responseSerializer: ProtobufSerializer<GetUploadedChunksResponse>(),
        interceptors: self.interceptors?.makeGetUploadedChunksInterceptors() ?? [],
        userFunction: self.getUploadedChunks(request:context:)
      )

    case "Download":
      return ServerStreamingServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<FileDownloadRequest>(),
        responseSerializer: ProtobufSerializer<FileChunk>(),
        interceptors: self.interceptors?.makeDownloadInterceptors() ?? [],
        userFunction: self.download(request:context:)
      )

    case "DownloadPhoto":
      return ServerStreamingServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<PhotoDownloadRequest>(),
        responseSerializer: ProtobufSerializer<FileChunk>(),
        interceptors: self.interceptors?.makeDownloadPhotoInterceptors() ?? [],
        userFunction: self.downloadPhoto(request:context:)
      )

    default:
      return nil
    }
  }
}

#if compiler(>=5.6)

/// To implement a server, implement an object which conforms to this protocol.
@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
internal protocol FileServiceAsyncProvider: CallHandlerProvider {
  static var serviceDescriptor: GRPCServiceDescriptor { get }
  var interceptors: FileServiceServerInterceptorFactoryProtocol? { get }

  @Sendable func create(
    request: FileCreateRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> FileCreateResponse

  @Sendable func upload(
    requestStream: GRPCAsyncRequestStream<FileChunk>,
    context: GRPCAsyncServerCallContext
  ) async throws -> FileUploadResponse

  @Sendable func getUploadedChunks(
    request: GetUploadedChunksRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> GetUploadedChunksResponse

  @Sendable func download(
    request: FileDownloadRequest,
    responseStream: GRPCAsyncResponseStreamWriter<FileChunk>,
    context: GRPCAsyncServerCallContext
  ) async throws

  @Sendable func downloadPhoto(
    request: PhotoDownloadRequest,
    responseStream: GRPCAsyncResponseStreamWriter<FileChunk>,
    context: GRPCAsyncServerCallContext
  ) async throws
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension FileServiceAsyncProvider {
  internal static var serviceDescriptor: GRPCServiceDescriptor {
    return FileServiceServerMetadata.serviceDescriptor
  }

  internal var serviceName: Substring {
    return FileServiceServerMetadata.serviceDescriptor.fullName[...]
  }

  internal var interceptors: FileServiceServerInterceptorFactoryProtocol? {
    return nil
  }

  internal func handle(
    method name: Substring,
    context: CallHandlerContext
  ) -> GRPCServerHandlerProtocol? {
    switch name {
    case "Create":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<FileCreateRequest>(),
        responseSerializer: ProtobufSerializer<FileCreateResponse>(),
        interceptors: self.interceptors?.makeCreateInterceptors() ?? [],
        wrapping: self.create(request:context:)
      )

    case "Upload":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<FileChunk>(),
        responseSerializer: ProtobufSerializer<FileUploadResponse>(),
        interceptors: self.interceptors?.makeUploadInterceptors() ?? [],
        wrapping: self.upload(requestStream:context:)
      )

    case "GetUploadedChunks":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<GetUploadedChunksRequest>(),
        responseSerializer: ProtobufSerializer<GetUploadedChunksResponse>(),
        interceptors: self.interceptors?.makeGetUploadedChunksInterceptors() ?? [],
        wrapping: self.getUploadedChunks(request:context:)
      )

    case "Download":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<FileDownloadRequest>(),
        responseSerializer: ProtobufSerializer<FileChunk>(),
        interceptors: self.interceptors?.makeDownloadInterceptors() ?? [],
        wrapping: self.download(request:responseStream:context:)
      )

    case "DownloadPhoto":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<PhotoDownloadRequest>(),
        responseSerializer: ProtobufSerializer<FileChunk>(),
        interceptors: self.interceptors?.makeDownloadPhotoInterceptors() ?? [],
        wrapping: self.downloadPhoto(request:responseStream:context:)
      )

    default:
      return nil
    }
  }
}

#endif // compiler(>=5.6)

internal protocol FileServiceServerInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when handling 'create'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeCreateInterceptors() -> [ServerInterceptor<FileCreateRequest, FileCreateResponse>]

  /// - Returns: Interceptors to use when handling 'upload'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeUploadInterceptors() -> [ServerInterceptor<FileChunk, FileUploadResponse>]

  /// - Returns: Interceptors to use when handling 'getUploadedChunks'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeGetUploadedChunksInterceptors() -> [ServerInterceptor<GetUploadedChunksRequest, GetUploadedChunksResponse>]

  /// - Returns: Interceptors to use when handling 'download'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeDownloadInterceptors() -> [ServerInterceptor<FileDownloadRequest, FileChunk>]

  /// - Returns: Interceptors to use when handling 'downloadPhoto'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeDownloadPhotoInterceptors() -> [ServerInterceptor<PhotoDownloadRequest, FileChunk>]
}

internal enum FileServiceServerMetadata {
  internal static let serviceDescriptor = GRPCServiceDescriptor(
    name: "FileService",
    fullName: "FileService",
    methods: [
      FileServiceServerMetadata.Methods.create,
      FileServiceServerMetadata.Methods.upload,
      FileServiceServerMetadata.Methods.getUploadedChunks,
      FileServiceServerMetadata.Methods.download,
      FileServiceServerMetadata.Methods.downloadPhoto,
    ]
  )

  internal enum Methods {
    internal static let create = GRPCMethodDescriptor(
      name: "Create",
      path: "/FileService/Create",
      type: GRPCCallType.unary
    )

    internal static let upload = GRPCMethodDescriptor(
      name: "Upload",
      path: "/FileService/Upload",
      type: GRPCCallType.clientStreaming
    )

    internal static let getUploadedChunks = GRPCMethodDescriptor(
      name: "GetUploadedChunks",
      path: "/FileService/GetUploadedChunks",
      type: GRPCCallType.unary
    )

    internal static let download = GRPCMethodDescriptor(
      name: "Download",
      path: "/FileService/Download",
      type: GRPCCallType.serverStreaming
    )

    internal static let downloadPhoto = GRPCMethodDescriptor(
      name: "DownloadPhoto",
      path: "/FileService/DownloadPhoto",
      type: GRPCCallType.serverStreaming
    )
  }
}
