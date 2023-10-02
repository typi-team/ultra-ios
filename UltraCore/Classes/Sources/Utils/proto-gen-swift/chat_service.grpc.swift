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

  func delete(
    _ request: ChatDeleteRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<ChatDeleteRequest, ChatDeleteResponse>

  func blockUser(
    _ request: BlockUserRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<BlockUserRequest, BlockUserResponse>

  func unblockUser(
    _ request: UnblockUserRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<UnblockUserRequest, UnblockUserResponse>

  func getBlockedList(
    _ request: GetBlockedUsersRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<GetBlockedUsersRequest, GetBlockedUsersResponse>
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

  /// Unary call to BlockUser
  ///
  /// - Parameters:
  ///   - request: Request to send to BlockUser.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func blockUser(
    _ request: BlockUserRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<BlockUserRequest, BlockUserResponse> {
    return self.makeUnaryCall(
      path: ChatServiceClientMetadata.Methods.blockUser.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeBlockUserInterceptors() ?? []
    )
  }

  /// Unary call to UnblockUser
  ///
  /// - Parameters:
  ///   - request: Request to send to UnblockUser.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func unblockUser(
    _ request: UnblockUserRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<UnblockUserRequest, UnblockUserResponse> {
    return self.makeUnaryCall(
      path: ChatServiceClientMetadata.Methods.unblockUser.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeUnblockUserInterceptors() ?? []
    )
  }

  /// Unary call to GetBlockedList
  ///
  /// - Parameters:
  ///   - request: Request to send to GetBlockedList.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func getBlockedList(
    _ request: GetBlockedUsersRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<GetBlockedUsersRequest, GetBlockedUsersResponse> {
    return self.makeUnaryCall(
      path: ChatServiceClientMetadata.Methods.getBlockedList.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetBlockedListInterceptors() ?? []
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

  func makeDeleteCall(
    _ request: ChatDeleteRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncUnaryCall<ChatDeleteRequest, ChatDeleteResponse>

  func makeBlockUserCall(
    _ request: BlockUserRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncUnaryCall<BlockUserRequest, BlockUserResponse>

  func makeUnblockUserCall(
    _ request: UnblockUserRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncUnaryCall<UnblockUserRequest, UnblockUserResponse>

  func makeGetBlockedListCall(
    _ request: GetBlockedUsersRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncUnaryCall<GetBlockedUsersRequest, GetBlockedUsersResponse>
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

  internal func makeBlockUserCall(
    _ request: BlockUserRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncUnaryCall<BlockUserRequest, BlockUserResponse> {
    return self.makeAsyncUnaryCall(
      path: ChatServiceClientMetadata.Methods.blockUser.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeBlockUserInterceptors() ?? []
    )
  }

  internal func makeUnblockUserCall(
    _ request: UnblockUserRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncUnaryCall<UnblockUserRequest, UnblockUserResponse> {
    return self.makeAsyncUnaryCall(
      path: ChatServiceClientMetadata.Methods.unblockUser.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeUnblockUserInterceptors() ?? []
    )
  }

  internal func makeGetBlockedListCall(
    _ request: GetBlockedUsersRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncUnaryCall<GetBlockedUsersRequest, GetBlockedUsersResponse> {
    return self.makeAsyncUnaryCall(
      path: ChatServiceClientMetadata.Methods.getBlockedList.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetBlockedListInterceptors() ?? []
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

  internal func blockUser(
    _ request: BlockUserRequest,
    callOptions: CallOptions? = nil
  ) async throws -> BlockUserResponse {
    return try await self.performAsyncUnaryCall(
      path: ChatServiceClientMetadata.Methods.blockUser.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeBlockUserInterceptors() ?? []
    )
  }

  internal func unblockUser(
    _ request: UnblockUserRequest,
    callOptions: CallOptions? = nil
  ) async throws -> UnblockUserResponse {
    return try await self.performAsyncUnaryCall(
      path: ChatServiceClientMetadata.Methods.unblockUser.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeUnblockUserInterceptors() ?? []
    )
  }

  internal func getBlockedList(
    _ request: GetBlockedUsersRequest,
    callOptions: CallOptions? = nil
  ) async throws -> GetBlockedUsersResponse {
    return try await self.performAsyncUnaryCall(
      path: ChatServiceClientMetadata.Methods.getBlockedList.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetBlockedListInterceptors() ?? []
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

  /// - Returns: Interceptors to use when invoking 'delete'.
  func makeDeleteInterceptors() -> [ClientInterceptor<ChatDeleteRequest, ChatDeleteResponse>]

  /// - Returns: Interceptors to use when invoking 'blockUser'.
  func makeBlockUserInterceptors() -> [ClientInterceptor<BlockUserRequest, BlockUserResponse>]

  /// - Returns: Interceptors to use when invoking 'unblockUser'.
  func makeUnblockUserInterceptors() -> [ClientInterceptor<UnblockUserRequest, UnblockUserResponse>]

  /// - Returns: Interceptors to use when invoking 'getBlockedList'.
  func makeGetBlockedListInterceptors() -> [ClientInterceptor<GetBlockedUsersRequest, GetBlockedUsersResponse>]
}

internal enum ChatServiceClientMetadata {
  internal static let serviceDescriptor = GRPCServiceDescriptor(
    name: "ChatService",
    fullName: "ChatService",
    methods: [
      ChatServiceClientMetadata.Methods.getByID,
      ChatServiceClientMetadata.Methods.delete,
      ChatServiceClientMetadata.Methods.blockUser,
      ChatServiceClientMetadata.Methods.unblockUser,
      ChatServiceClientMetadata.Methods.getBlockedList,
    ]
  )

  internal enum Methods {
    internal static let getByID = GRPCMethodDescriptor(
      name: "GetByID",
      path: "/ChatService/GetByID",
      type: GRPCCallType.unary
    )

    internal static let delete = GRPCMethodDescriptor(
      name: "Delete",
      path: "/ChatService/Delete",
      type: GRPCCallType.unary
    )

    internal static let blockUser = GRPCMethodDescriptor(
      name: "BlockUser",
      path: "/ChatService/BlockUser",
      type: GRPCCallType.unary
    )

    internal static let unblockUser = GRPCMethodDescriptor(
      name: "UnblockUser",
      path: "/ChatService/UnblockUser",
      type: GRPCCallType.unary
    )

    internal static let getBlockedList = GRPCMethodDescriptor(
      name: "GetBlockedList",
      path: "/ChatService/GetBlockedList",
      type: GRPCCallType.unary
    )
  }
}

/// To build a server, implement a class that conforms to this protocol.
internal protocol ChatServiceProvider: CallHandlerProvider {
  var interceptors: ChatServiceServerInterceptorFactoryProtocol? { get }

  func getByID(request: GetChatRequest, context: StatusOnlyCallContext) -> EventLoopFuture<GetChatResponse>

  func delete(request: ChatDeleteRequest, context: StatusOnlyCallContext) -> EventLoopFuture<ChatDeleteResponse>

  func blockUser(request: BlockUserRequest, context: StatusOnlyCallContext) -> EventLoopFuture<BlockUserResponse>

  func unblockUser(request: UnblockUserRequest, context: StatusOnlyCallContext) -> EventLoopFuture<UnblockUserResponse>

  func getBlockedList(request: GetBlockedUsersRequest, context: StatusOnlyCallContext) -> EventLoopFuture<GetBlockedUsersResponse>
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

    case "Delete":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<ChatDeleteRequest>(),
        responseSerializer: ProtobufSerializer<ChatDeleteResponse>(),
        interceptors: self.interceptors?.makeDeleteInterceptors() ?? [],
        userFunction: self.delete(request:context:)
      )

    case "BlockUser":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<BlockUserRequest>(),
        responseSerializer: ProtobufSerializer<BlockUserResponse>(),
        interceptors: self.interceptors?.makeBlockUserInterceptors() ?? [],
        userFunction: self.blockUser(request:context:)
      )

    case "UnblockUser":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<UnblockUserRequest>(),
        responseSerializer: ProtobufSerializer<UnblockUserResponse>(),
        interceptors: self.interceptors?.makeUnblockUserInterceptors() ?? [],
        userFunction: self.unblockUser(request:context:)
      )

    case "GetBlockedList":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<GetBlockedUsersRequest>(),
        responseSerializer: ProtobufSerializer<GetBlockedUsersResponse>(),
        interceptors: self.interceptors?.makeGetBlockedListInterceptors() ?? [],
        userFunction: self.getBlockedList(request:context:)
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

  func delete(
    request: ChatDeleteRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> ChatDeleteResponse

  func blockUser(
    request: BlockUserRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> BlockUserResponse

  func unblockUser(
    request: UnblockUserRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> UnblockUserResponse

  func getBlockedList(
    request: GetBlockedUsersRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> GetBlockedUsersResponse
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

    case "Delete":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<ChatDeleteRequest>(),
        responseSerializer: ProtobufSerializer<ChatDeleteResponse>(),
        interceptors: self.interceptors?.makeDeleteInterceptors() ?? [],
        wrapping: { try await self.delete(request: $0, context: $1) }
      )

    case "BlockUser":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<BlockUserRequest>(),
        responseSerializer: ProtobufSerializer<BlockUserResponse>(),
        interceptors: self.interceptors?.makeBlockUserInterceptors() ?? [],
        wrapping: { try await self.blockUser(request: $0, context: $1) }
      )

    case "UnblockUser":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<UnblockUserRequest>(),
        responseSerializer: ProtobufSerializer<UnblockUserResponse>(),
        interceptors: self.interceptors?.makeUnblockUserInterceptors() ?? [],
        wrapping: { try await self.unblockUser(request: $0, context: $1) }
      )

    case "GetBlockedList":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<GetBlockedUsersRequest>(),
        responseSerializer: ProtobufSerializer<GetBlockedUsersResponse>(),
        interceptors: self.interceptors?.makeGetBlockedListInterceptors() ?? [],
        wrapping: { try await self.getBlockedList(request: $0, context: $1) }
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

  /// - Returns: Interceptors to use when handling 'delete'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeDeleteInterceptors() -> [ServerInterceptor<ChatDeleteRequest, ChatDeleteResponse>]

  /// - Returns: Interceptors to use when handling 'blockUser'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeBlockUserInterceptors() -> [ServerInterceptor<BlockUserRequest, BlockUserResponse>]

  /// - Returns: Interceptors to use when handling 'unblockUser'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeUnblockUserInterceptors() -> [ServerInterceptor<UnblockUserRequest, UnblockUserResponse>]

  /// - Returns: Interceptors to use when handling 'getBlockedList'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeGetBlockedListInterceptors() -> [ServerInterceptor<GetBlockedUsersRequest, GetBlockedUsersResponse>]
}

internal enum ChatServiceServerMetadata {
  internal static let serviceDescriptor = GRPCServiceDescriptor(
    name: "ChatService",
    fullName: "ChatService",
    methods: [
      ChatServiceServerMetadata.Methods.getByID,
      ChatServiceServerMetadata.Methods.delete,
      ChatServiceServerMetadata.Methods.blockUser,
      ChatServiceServerMetadata.Methods.unblockUser,
      ChatServiceServerMetadata.Methods.getBlockedList,
    ]
  )

  internal enum Methods {
    internal static let getByID = GRPCMethodDescriptor(
      name: "GetByID",
      path: "/ChatService/GetByID",
      type: GRPCCallType.unary
    )

    internal static let delete = GRPCMethodDescriptor(
      name: "Delete",
      path: "/ChatService/Delete",
      type: GRPCCallType.unary
    )

    internal static let blockUser = GRPCMethodDescriptor(
      name: "BlockUser",
      path: "/ChatService/BlockUser",
      type: GRPCCallType.unary
    )

    internal static let unblockUser = GRPCMethodDescriptor(
      name: "UnblockUser",
      path: "/ChatService/UnblockUser",
      type: GRPCCallType.unary
    )

    internal static let getBlockedList = GRPCMethodDescriptor(
      name: "GetBlockedList",
      path: "/ChatService/GetBlockedList",
      type: GRPCCallType.unary
    )
  }
}
