//
// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the protocol buffer compiler.
// Source: chat_service.proto
//
import GRPC
import NIO
import NIOConcurrencyHelpers
import SwiftProtobuf


/// Usage: instantiate `ChatServiceClient`, then call methods of this protocol to make API calls.
internal protocol ChatServiceClientProtocol: GRPCClient {
  var serviceName: String { get }
  var interceptors: ChatServiceClientInterceptorFactoryProtocol? { get }

  func getByID(
    _ request: GetChatRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<GetChatRequest, GetChatResponse>

  func getSettings(
    _ request: GetChatSettingsRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<GetChatSettingsRequest, GetChatSettingsResponse>

  func getChats(
    _ request: GetChatsListRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<GetChatsListRequest, GetChatsListResponse>

  func delete(
    _ request: ChatDeleteRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<ChatDeleteRequest, ChatDeleteResponse>
}

extension ChatServiceClientProtocol {
  internal var serviceName: String {
    return "ChatService"
  }

  /// Unary call to GetByID
  ///
  /// - Parameters:
  ///   - request: Request to send to GetByID.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func getByID(
    _ request: GetChatRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<GetChatRequest, GetChatResponse> {
    return self.makeUnaryCall(
      path: ChatServiceClientMetadata.Methods.getByID.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetByIDInterceptors() ?? []
    )
  }

  /// Unary call to GetSettings
  ///
  /// - Parameters:
  ///   - request: Request to send to GetSettings.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func getSettings(
    _ request: GetChatSettingsRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<GetChatSettingsRequest, GetChatSettingsResponse> {
    return self.makeUnaryCall(
      path: ChatServiceClientMetadata.Methods.getSettings.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetSettingsInterceptors() ?? []
    )
  }

  /// Unary call to GetChats
  ///
  /// - Parameters:
  ///   - request: Request to send to GetChats.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func getChats(
    _ request: GetChatsListRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<GetChatsListRequest, GetChatsListResponse> {
    return self.makeUnaryCall(
      path: ChatServiceClientMetadata.Methods.getChats.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetChatsInterceptors() ?? []
    )
  }

  /// Unary call to Delete
  ///
  /// - Parameters:
  ///   - request: Request to send to Delete.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func delete(
    _ request: ChatDeleteRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<ChatDeleteRequest, ChatDeleteResponse> {
    return self.makeUnaryCall(
      path: ChatServiceClientMetadata.Methods.delete.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeDeleteInterceptors() ?? []
    )
  }
}

@available(*, deprecated)
extension ChatServiceClient: @unchecked Sendable {}

@available(*, deprecated, renamed: "ChatServiceNIOClient")
internal final class ChatServiceClient: ChatServiceClientProtocol {
  private let lock = Lock()
  private var _defaultCallOptions: CallOptions
  private var _interceptors: ChatServiceClientInterceptorFactoryProtocol?
  internal let channel: GRPCChannel
  internal var defaultCallOptions: CallOptions {
    get { self.lock.withLock { return self._defaultCallOptions } }
    set { self.lock.withLockVoid { self._defaultCallOptions = newValue } }
  }
  internal var interceptors: ChatServiceClientInterceptorFactoryProtocol? {
    get { self.lock.withLock { return self._interceptors } }
    set { self.lock.withLockVoid { self._interceptors = newValue } }
  }

  /// Creates a client for the ChatService service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  internal init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: ChatServiceClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self._defaultCallOptions = defaultCallOptions
    self._interceptors = interceptors
  }
}

internal struct ChatServiceNIOClient: ChatServiceClientProtocol {
  internal var channel: GRPCChannel
  internal var defaultCallOptions: CallOptions
  internal var interceptors: ChatServiceClientInterceptorFactoryProtocol?

  /// Creates a client for the ChatService service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  internal init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: ChatServiceClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
internal protocol ChatServiceAsyncClientProtocol: GRPCClient {
  static var serviceDescriptor: GRPCServiceDescriptor { get }
  var interceptors: ChatServiceClientInterceptorFactoryProtocol? { get }

  func makeGetByIDCall(
    _ request: GetChatRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncUnaryCall<GetChatRequest, GetChatResponse>

  func makeGetSettingsCall(
    _ request: GetChatSettingsRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncUnaryCall<GetChatSettingsRequest, GetChatSettingsResponse>

  func makeGetChatsCall(
    _ request: GetChatsListRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncUnaryCall<GetChatsListRequest, GetChatsListResponse>

  func makeDeleteCall(
    _ request: ChatDeleteRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncUnaryCall<ChatDeleteRequest, ChatDeleteResponse>
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension ChatServiceAsyncClientProtocol {
  internal static var serviceDescriptor: GRPCServiceDescriptor {
    return ChatServiceClientMetadata.serviceDescriptor
  }

  internal var interceptors: ChatServiceClientInterceptorFactoryProtocol? {
    return nil
  }

  internal func makeGetByIDCall(
    _ request: GetChatRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncUnaryCall<GetChatRequest, GetChatResponse> {
    return self.makeAsyncUnaryCall(
      path: ChatServiceClientMetadata.Methods.getByID.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetByIDInterceptors() ?? []
    )
  }

  internal func makeGetSettingsCall(
    _ request: GetChatSettingsRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncUnaryCall<GetChatSettingsRequest, GetChatSettingsResponse> {
    return self.makeAsyncUnaryCall(
      path: ChatServiceClientMetadata.Methods.getSettings.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetSettingsInterceptors() ?? []
    )
  }

  internal func makeGetChatsCall(
    _ request: GetChatsListRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncUnaryCall<GetChatsListRequest, GetChatsListResponse> {
    return self.makeAsyncUnaryCall(
      path: ChatServiceClientMetadata.Methods.getChats.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetChatsInterceptors() ?? []
    )
  }

  internal func makeDeleteCall(
    _ request: ChatDeleteRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncUnaryCall<ChatDeleteRequest, ChatDeleteResponse> {
    return self.makeAsyncUnaryCall(
      path: ChatServiceClientMetadata.Methods.delete.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeDeleteInterceptors() ?? []
    )
  }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension ChatServiceAsyncClientProtocol {
  internal func getByID(
    _ request: GetChatRequest,
    callOptions: CallOptions? = nil
  ) async throws -> GetChatResponse {
    return try await self.performAsyncUnaryCall(
      path: ChatServiceClientMetadata.Methods.getByID.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetByIDInterceptors() ?? []
    )
  }

  internal func getSettings(
    _ request: GetChatSettingsRequest,
    callOptions: CallOptions? = nil
  ) async throws -> GetChatSettingsResponse {
    return try await self.performAsyncUnaryCall(
      path: ChatServiceClientMetadata.Methods.getSettings.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetSettingsInterceptors() ?? []
    )
  }

  internal func getChats(
    _ request: GetChatsListRequest,
    callOptions: CallOptions? = nil
  ) async throws -> GetChatsListResponse {
    return try await self.performAsyncUnaryCall(
      path: ChatServiceClientMetadata.Methods.getChats.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetChatsInterceptors() ?? []
    )
  }

  internal func delete(
    _ request: ChatDeleteRequest,
    callOptions: CallOptions? = nil
  ) async throws -> ChatDeleteResponse {
    return try await self.performAsyncUnaryCall(
      path: ChatServiceClientMetadata.Methods.delete.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeDeleteInterceptors() ?? []
    )
  }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
internal struct ChatServiceAsyncClient: ChatServiceAsyncClientProtocol {
  internal var channel: GRPCChannel
  internal var defaultCallOptions: CallOptions
  internal var interceptors: ChatServiceClientInterceptorFactoryProtocol?

  internal init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: ChatServiceClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

internal protocol ChatServiceClientInterceptorFactoryProtocol: Sendable {

  /// - Returns: Interceptors to use when invoking 'getByID'.
  func makeGetByIDInterceptors() -> [ClientInterceptor<GetChatRequest, GetChatResponse>]

  /// - Returns: Interceptors to use when invoking 'getSettings'.
  func makeGetSettingsInterceptors() -> [ClientInterceptor<GetChatSettingsRequest, GetChatSettingsResponse>]

  /// - Returns: Interceptors to use when invoking 'getChats'.
  func makeGetChatsInterceptors() -> [ClientInterceptor<GetChatsListRequest, GetChatsListResponse>]

  /// - Returns: Interceptors to use when invoking 'delete'.
  func makeDeleteInterceptors() -> [ClientInterceptor<ChatDeleteRequest, ChatDeleteResponse>]
}

internal enum ChatServiceClientMetadata {
  internal static let serviceDescriptor = GRPCServiceDescriptor(
    name: "ChatService",
    fullName: "ChatService",
    methods: [
      ChatServiceClientMetadata.Methods.getByID,
      ChatServiceClientMetadata.Methods.getSettings,
      ChatServiceClientMetadata.Methods.getChats,
      ChatServiceClientMetadata.Methods.delete,
    ]
  )

  internal enum Methods {
    internal static let getByID = GRPCMethodDescriptor(
      name: "GetByID",
      path: "/ChatService/GetByID",
      type: GRPCCallType.unary
    )

    internal static let getSettings = GRPCMethodDescriptor(
      name: "GetSettings",
      path: "/ChatService/GetSettings",
      type: GRPCCallType.unary
    )

    internal static let getChats = GRPCMethodDescriptor(
      name: "GetChats",
      path: "/ChatService/GetChats",
      type: GRPCCallType.unary
    )

    internal static let delete = GRPCMethodDescriptor(
      name: "Delete",
      path: "/ChatService/Delete",
      type: GRPCCallType.unary
    )
  }
}

/// To build a server, implement a class that conforms to this protocol.
internal protocol ChatServiceProvider: CallHandlerProvider {
  var interceptors: ChatServiceServerInterceptorFactoryProtocol? { get }

  func getByID(request: GetChatRequest, context: StatusOnlyCallContext) -> EventLoopFuture<GetChatResponse>

  func getSettings(request: GetChatSettingsRequest, context: StatusOnlyCallContext) -> EventLoopFuture<GetChatSettingsResponse>

  func getChats(request: GetChatsListRequest, context: StatusOnlyCallContext) -> EventLoopFuture<GetChatsListResponse>

  func delete(request: ChatDeleteRequest, context: StatusOnlyCallContext) -> EventLoopFuture<ChatDeleteResponse>
}

extension ChatServiceProvider {
  internal var serviceName: Substring {
    return ChatServiceServerMetadata.serviceDescriptor.fullName[...]
  }

  /// Determines, calls and returns the appropriate request handler, depending on the request's method.
  /// Returns nil for methods not handled by this service.
  internal func handle(
    method name: Substring,
    context: CallHandlerContext
  ) -> GRPCServerHandlerProtocol? {
    switch name {
    case "GetByID":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<GetChatRequest>(),
        responseSerializer: ProtobufSerializer<GetChatResponse>(),
        interceptors: self.interceptors?.makeGetByIDInterceptors() ?? [],
        userFunction: self.getByID(request:context:)
      )

    case "GetSettings":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<GetChatSettingsRequest>(),
        responseSerializer: ProtobufSerializer<GetChatSettingsResponse>(),
        interceptors: self.interceptors?.makeGetSettingsInterceptors() ?? [],
        userFunction: self.getSettings(request:context:)
      )

    case "GetChats":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<GetChatsListRequest>(),
        responseSerializer: ProtobufSerializer<GetChatsListResponse>(),
        interceptors: self.interceptors?.makeGetChatsInterceptors() ?? [],
        userFunction: self.getChats(request:context:)
      )

    case "Delete":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<ChatDeleteRequest>(),
        responseSerializer: ProtobufSerializer<ChatDeleteResponse>(),
        interceptors: self.interceptors?.makeDeleteInterceptors() ?? [],
        userFunction: self.delete(request:context:)
      )

    default:
      return nil
    }
  }
}

/// To implement a server, implement an object which conforms to this protocol.
@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
internal protocol ChatServiceAsyncProvider: CallHandlerProvider, Sendable {
  static var serviceDescriptor: GRPCServiceDescriptor { get }
  var interceptors: ChatServiceServerInterceptorFactoryProtocol? { get }

  func getByID(
    request: GetChatRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> GetChatResponse

  func getSettings(
    request: GetChatSettingsRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> GetChatSettingsResponse

  func getChats(
    request: GetChatsListRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> GetChatsListResponse

  func delete(
    request: ChatDeleteRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> ChatDeleteResponse
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension ChatServiceAsyncProvider {
  internal static var serviceDescriptor: GRPCServiceDescriptor {
    return ChatServiceServerMetadata.serviceDescriptor
  }

  internal var serviceName: Substring {
    return ChatServiceServerMetadata.serviceDescriptor.fullName[...]
  }

  internal var interceptors: ChatServiceServerInterceptorFactoryProtocol? {
    return nil
  }

  internal func handle(
    method name: Substring,
    context: CallHandlerContext
  ) -> GRPCServerHandlerProtocol? {
    switch name {
    case "GetByID":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<GetChatRequest>(),
        responseSerializer: ProtobufSerializer<GetChatResponse>(),
        interceptors: self.interceptors?.makeGetByIDInterceptors() ?? [],
        wrapping: { try await self.getByID(request: $0, context: $1) }
      )

    case "GetSettings":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<GetChatSettingsRequest>(),
        responseSerializer: ProtobufSerializer<GetChatSettingsResponse>(),
        interceptors: self.interceptors?.makeGetSettingsInterceptors() ?? [],
        wrapping: { try await self.getSettings(request: $0, context: $1) }
      )

    case "GetChats":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<GetChatsListRequest>(),
        responseSerializer: ProtobufSerializer<GetChatsListResponse>(),
        interceptors: self.interceptors?.makeGetChatsInterceptors() ?? [],
        wrapping: { try await self.getChats(request: $0, context: $1) }
      )

    case "Delete":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<ChatDeleteRequest>(),
        responseSerializer: ProtobufSerializer<ChatDeleteResponse>(),
        interceptors: self.interceptors?.makeDeleteInterceptors() ?? [],
        wrapping: { try await self.delete(request: $0, context: $1) }
      )

    default:
      return nil
    }
  }
}

internal protocol ChatServiceServerInterceptorFactoryProtocol: Sendable {

  /// - Returns: Interceptors to use when handling 'getByID'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeGetByIDInterceptors() -> [ServerInterceptor<GetChatRequest, GetChatResponse>]

  /// - Returns: Interceptors to use when handling 'getSettings'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeGetSettingsInterceptors() -> [ServerInterceptor<GetChatSettingsRequest, GetChatSettingsResponse>]

  /// - Returns: Interceptors to use when handling 'getChats'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeGetChatsInterceptors() -> [ServerInterceptor<GetChatsListRequest, GetChatsListResponse>]

  /// - Returns: Interceptors to use when handling 'delete'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeDeleteInterceptors() -> [ServerInterceptor<ChatDeleteRequest, ChatDeleteResponse>]
}

internal enum ChatServiceServerMetadata {
  internal static let serviceDescriptor = GRPCServiceDescriptor(
    name: "ChatService",
    fullName: "ChatService",
    methods: [
      ChatServiceServerMetadata.Methods.getByID,
      ChatServiceServerMetadata.Methods.getSettings,
      ChatServiceServerMetadata.Methods.getChats,
      ChatServiceServerMetadata.Methods.delete,
    ]
  )

  internal enum Methods {
    internal static let getByID = GRPCMethodDescriptor(
      name: "GetByID",
      path: "/ChatService/GetByID",
      type: GRPCCallType.unary
    )

    internal static let getSettings = GRPCMethodDescriptor(
      name: "GetSettings",
      path: "/ChatService/GetSettings",
      type: GRPCCallType.unary
    )

    internal static let getChats = GRPCMethodDescriptor(
      name: "GetChats",
      path: "/ChatService/GetChats",
      type: GRPCCallType.unary
    )

    internal static let delete = GRPCMethodDescriptor(
      name: "Delete",
      path: "/ChatService/Delete",
      type: GRPCCallType.unary
    )
  }
}
