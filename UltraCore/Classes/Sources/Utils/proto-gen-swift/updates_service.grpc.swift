//
// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the protocol buffer compiler.
// Source: updates_service.proto
//
import GRPC
import NIO
import NIOConcurrencyHelpers
import SwiftProtobuf


///*
/// Main service to listen real-time updates. Each change will be
/// delivered as update by this service
///
/// Usage: instantiate `UpdatesServiceClient`, then call methods of this protocol to make API calls.
internal protocol UpdatesServiceClientProtocol: GRPCClient {
  var serviceName: String { get }
  var interceptors: UpdatesServiceClientInterceptorFactoryProtocol? { get }

  func listen(
    _ request: ListenRequest,
    callOptions: CallOptions?,
    handler: @escaping (Updates) -> Void
  ) -> ServerStreamingCall<ListenRequest, Updates>

  func ping(
    _ request: PingRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<PingRequest, PingResponse>

  func getInitialState(
    _ request: InitialStateRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<InitialStateRequest, InitialStateResponse>

  func getUpdates(
    _ request: GetUpdatesRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<GetUpdatesRequest, GetUpdatesResponse>
}

extension UpdatesServiceClientProtocol {
  internal var serviceName: String {
    return "UpdatesService"
  }

  /// Main stream for client applications, user's online status
  /// and session will be tracked by this listener. Listening session
  /// has 180 seconds expiration time, is at that time period client
  /// will not call Ping then session will be aborted
  ///
  /// - Parameters:
  ///   - request: Request to send to Listen.
  ///   - callOptions: Call options.
  ///   - handler: A closure called when each response is received from the server.
  /// - Returns: A `ServerStreamingCall` with futures for the metadata and status.
  internal func listen(
    _ request: ListenRequest,
    callOptions: CallOptions? = nil,
    handler: @escaping (Updates) -> Void
  ) -> ServerStreamingCall<ListenRequest, Updates> {
    return self.makeServerStreamingCall(
      path: UpdatesServiceClientMetadata.Methods.listen.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeListenInterceptors() ?? [],
      handler: handler
    )
  }

  /// Empty message to extend user session. Client must
  /// call this method each 120 seconds to avoid session abortion
  ///
  /// - Parameters:
  ///   - request: Request to send to Ping.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func ping(
    _ request: PingRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<PingRequest, PingResponse> {
    return self.makeUnaryCall(
      path: UpdatesServiceClientMetadata.Methods.ping.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makePingInterceptors() ?? []
    )
  }

  /// Returns initial state for client. Client should call
  /// this method only for initial setup when user is logined from
  /// new device and doesn't have any local data. #Listen should be
  /// request from state which was returned by this method, it guarantees 
  /// that client will get only new updates
  ///
  /// - Parameters:
  ///   - request: Request to send to GetInitialState.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func getInitialState(
    _ request: InitialStateRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<InitialStateRequest, InitialStateResponse> {
    return self.makeUnaryCall(
      path: UpdatesServiceClientMetadata.Methods.getInitialState.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetInitialStateInterceptors() ?? []
    )
  }

  /// Get updates by state range, should be used by clients to close gaps
  ///
  /// - Parameters:
  ///   - request: Request to send to GetUpdates.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func getUpdates(
    _ request: GetUpdatesRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<GetUpdatesRequest, GetUpdatesResponse> {
    return self.makeUnaryCall(
      path: UpdatesServiceClientMetadata.Methods.getUpdates.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetUpdatesInterceptors() ?? []
    )
  }
}

@available(*, deprecated)
extension UpdatesServiceClient: @unchecked Sendable {}

@available(*, deprecated, renamed: "UpdatesServiceNIOClient")
internal final class UpdatesServiceClient: UpdatesServiceClientProtocol {
  private let lock = Lock()
  private var _defaultCallOptions: CallOptions
  private var _interceptors: UpdatesServiceClientInterceptorFactoryProtocol?
  internal let channel: GRPCChannel
  internal var defaultCallOptions: CallOptions {
    get { self.lock.withLock { return self._defaultCallOptions } }
    set { self.lock.withLockVoid { self._defaultCallOptions = newValue } }
  }
  internal var interceptors: UpdatesServiceClientInterceptorFactoryProtocol? {
    get { self.lock.withLock { return self._interceptors } }
    set { self.lock.withLockVoid { self._interceptors = newValue } }
  }

  /// Creates a client for the UpdatesService service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  internal init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: UpdatesServiceClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self._defaultCallOptions = defaultCallOptions
    self._interceptors = interceptors
  }
}

internal struct UpdatesServiceNIOClient: UpdatesServiceClientProtocol {
  internal var channel: GRPCChannel
  internal var defaultCallOptions: CallOptions
  internal var interceptors: UpdatesServiceClientInterceptorFactoryProtocol?

  /// Creates a client for the UpdatesService service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  internal init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: UpdatesServiceClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

///*
/// Main service to listen real-time updates. Each change will be
/// delivered as update by this service
@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
internal protocol UpdatesServiceAsyncClientProtocol: GRPCClient {
  static var serviceDescriptor: GRPCServiceDescriptor { get }
  var interceptors: UpdatesServiceClientInterceptorFactoryProtocol? { get }

  func makeListenCall(
    _ request: ListenRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncServerStreamingCall<ListenRequest, Updates>

  func makePingCall(
    _ request: PingRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncUnaryCall<PingRequest, PingResponse>

  func makeGetInitialStateCall(
    _ request: InitialStateRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncUnaryCall<InitialStateRequest, InitialStateResponse>

  func makeGetUpdatesCall(
    _ request: GetUpdatesRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncUnaryCall<GetUpdatesRequest, GetUpdatesResponse>
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension UpdatesServiceAsyncClientProtocol {
  internal static var serviceDescriptor: GRPCServiceDescriptor {
    return UpdatesServiceClientMetadata.serviceDescriptor
  }

  internal var interceptors: UpdatesServiceClientInterceptorFactoryProtocol? {
    return nil
  }

  internal func makeListenCall(
    _ request: ListenRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncServerStreamingCall<ListenRequest, Updates> {
    return self.makeAsyncServerStreamingCall(
      path: UpdatesServiceClientMetadata.Methods.listen.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeListenInterceptors() ?? []
    )
  }

  internal func makePingCall(
    _ request: PingRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncUnaryCall<PingRequest, PingResponse> {
    return self.makeAsyncUnaryCall(
      path: UpdatesServiceClientMetadata.Methods.ping.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makePingInterceptors() ?? []
    )
  }

  internal func makeGetInitialStateCall(
    _ request: InitialStateRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncUnaryCall<InitialStateRequest, InitialStateResponse> {
    return self.makeAsyncUnaryCall(
      path: UpdatesServiceClientMetadata.Methods.getInitialState.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetInitialStateInterceptors() ?? []
    )
  }

  internal func makeGetUpdatesCall(
    _ request: GetUpdatesRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncUnaryCall<GetUpdatesRequest, GetUpdatesResponse> {
    return self.makeAsyncUnaryCall(
      path: UpdatesServiceClientMetadata.Methods.getUpdates.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetUpdatesInterceptors() ?? []
    )
  }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension UpdatesServiceAsyncClientProtocol {
  internal func listen(
    _ request: ListenRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncResponseStream<Updates> {
    return self.performAsyncServerStreamingCall(
      path: UpdatesServiceClientMetadata.Methods.listen.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeListenInterceptors() ?? []
    )
  }

  internal func ping(
    _ request: PingRequest,
    callOptions: CallOptions? = nil
  ) async throws -> PingResponse {
    return try await self.performAsyncUnaryCall(
      path: UpdatesServiceClientMetadata.Methods.ping.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makePingInterceptors() ?? []
    )
  }

  internal func getInitialState(
    _ request: InitialStateRequest,
    callOptions: CallOptions? = nil
  ) async throws -> InitialStateResponse {
    return try await self.performAsyncUnaryCall(
      path: UpdatesServiceClientMetadata.Methods.getInitialState.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetInitialStateInterceptors() ?? []
    )
  }

  internal func getUpdates(
    _ request: GetUpdatesRequest,
    callOptions: CallOptions? = nil
  ) async throws -> GetUpdatesResponse {
    return try await self.performAsyncUnaryCall(
      path: UpdatesServiceClientMetadata.Methods.getUpdates.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetUpdatesInterceptors() ?? []
    )
  }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
internal struct UpdatesServiceAsyncClient: UpdatesServiceAsyncClientProtocol {
  internal var channel: GRPCChannel
  internal var defaultCallOptions: CallOptions
  internal var interceptors: UpdatesServiceClientInterceptorFactoryProtocol?

  internal init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: UpdatesServiceClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

internal protocol UpdatesServiceClientInterceptorFactoryProtocol: Sendable {

  /// - Returns: Interceptors to use when invoking 'listen'.
  func makeListenInterceptors() -> [ClientInterceptor<ListenRequest, Updates>]

  /// - Returns: Interceptors to use when invoking 'ping'.
  func makePingInterceptors() -> [ClientInterceptor<PingRequest, PingResponse>]

  /// - Returns: Interceptors to use when invoking 'getInitialState'.
  func makeGetInitialStateInterceptors() -> [ClientInterceptor<InitialStateRequest, InitialStateResponse>]

  /// - Returns: Interceptors to use when invoking 'getUpdates'.
  func makeGetUpdatesInterceptors() -> [ClientInterceptor<GetUpdatesRequest, GetUpdatesResponse>]
}

internal enum UpdatesServiceClientMetadata {
  internal static let serviceDescriptor = GRPCServiceDescriptor(
    name: "UpdatesService",
    fullName: "UpdatesService",
    methods: [
      UpdatesServiceClientMetadata.Methods.listen,
      UpdatesServiceClientMetadata.Methods.ping,
      UpdatesServiceClientMetadata.Methods.getInitialState,
      UpdatesServiceClientMetadata.Methods.getUpdates,
    ]
  )

  internal enum Methods {
    internal static let listen = GRPCMethodDescriptor(
      name: "Listen",
      path: "/UpdatesService/Listen",
      type: GRPCCallType.serverStreaming
    )

    internal static let ping = GRPCMethodDescriptor(
      name: "Ping",
      path: "/UpdatesService/Ping",
      type: GRPCCallType.unary
    )

    internal static let getInitialState = GRPCMethodDescriptor(
      name: "GetInitialState",
      path: "/UpdatesService/GetInitialState",
      type: GRPCCallType.unary
    )

    internal static let getUpdates = GRPCMethodDescriptor(
      name: "GetUpdates",
      path: "/UpdatesService/GetUpdates",
      type: GRPCCallType.unary
    )
  }
}

///*
/// Main service to listen real-time updates. Each change will be
/// delivered as update by this service
///
/// To build a server, implement a class that conforms to this protocol.
internal protocol UpdatesServiceProvider: CallHandlerProvider {
  var interceptors: UpdatesServiceServerInterceptorFactoryProtocol? { get }

  /// Main stream for client applications, user's online status
  /// and session will be tracked by this listener. Listening session
  /// has 180 seconds expiration time, is at that time period client
  /// will not call Ping then session will be aborted
  func listen(request: ListenRequest, context: StreamingResponseCallContext<Updates>) -> EventLoopFuture<GRPCStatus>

  /// Empty message to extend user session. Client must
  /// call this method each 120 seconds to avoid session abortion
  func ping(request: PingRequest, context: StatusOnlyCallContext) -> EventLoopFuture<PingResponse>

  /// Returns initial state for client. Client should call
  /// this method only for initial setup when user is logined from
  /// new device and doesn't have any local data. #Listen should be
  /// request from state which was returned by this method, it guarantees 
  /// that client will get only new updates
  func getInitialState(request: InitialStateRequest, context: StatusOnlyCallContext) -> EventLoopFuture<InitialStateResponse>

  /// Get updates by state range, should be used by clients to close gaps
  func getUpdates(request: GetUpdatesRequest, context: StatusOnlyCallContext) -> EventLoopFuture<GetUpdatesResponse>
}

extension UpdatesServiceProvider {
  internal var serviceName: Substring {
    return UpdatesServiceServerMetadata.serviceDescriptor.fullName[...]
  }

  /// Determines, calls and returns the appropriate request handler, depending on the request's method.
  /// Returns nil for methods not handled by this service.
  internal func handle(
    method name: Substring,
    context: CallHandlerContext
  ) -> GRPCServerHandlerProtocol? {
    switch name {
    case "Listen":
      return ServerStreamingServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<ListenRequest>(),
        responseSerializer: ProtobufSerializer<Updates>(),
        interceptors: self.interceptors?.makeListenInterceptors() ?? [],
        userFunction: self.listen(request:context:)
      )

    case "Ping":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<PingRequest>(),
        responseSerializer: ProtobufSerializer<PingResponse>(),
        interceptors: self.interceptors?.makePingInterceptors() ?? [],
        userFunction: self.ping(request:context:)
      )

    case "GetInitialState":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<InitialStateRequest>(),
        responseSerializer: ProtobufSerializer<InitialStateResponse>(),
        interceptors: self.interceptors?.makeGetInitialStateInterceptors() ?? [],
        userFunction: self.getInitialState(request:context:)
      )

    case "GetUpdates":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<GetUpdatesRequest>(),
        responseSerializer: ProtobufSerializer<GetUpdatesResponse>(),
        interceptors: self.interceptors?.makeGetUpdatesInterceptors() ?? [],
        userFunction: self.getUpdates(request:context:)
      )

    default:
      return nil
    }
  }
}

///*
/// Main service to listen real-time updates. Each change will be
/// delivered as update by this service
///
/// To implement a server, implement an object which conforms to this protocol.
@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
internal protocol UpdatesServiceAsyncProvider: CallHandlerProvider, Sendable {
  static var serviceDescriptor: GRPCServiceDescriptor { get }
  var interceptors: UpdatesServiceServerInterceptorFactoryProtocol? { get }

  /// Main stream for client applications, user's online status
  /// and session will be tracked by this listener. Listening session
  /// has 180 seconds expiration time, is at that time period client
  /// will not call Ping then session will be aborted
  func listen(
    request: ListenRequest,
    responseStream: GRPCAsyncResponseStreamWriter<Updates>,
    context: GRPCAsyncServerCallContext
  ) async throws

  /// Empty message to extend user session. Client must
  /// call this method each 120 seconds to avoid session abortion
  func ping(
    request: PingRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> PingResponse

  /// Returns initial state for client. Client should call
  /// this method only for initial setup when user is logined from
  /// new device and doesn't have any local data. #Listen should be
  /// request from state which was returned by this method, it guarantees 
  /// that client will get only new updates
  func getInitialState(
    request: InitialStateRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> InitialStateResponse

  /// Get updates by state range, should be used by clients to close gaps
  func getUpdates(
    request: GetUpdatesRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> GetUpdatesResponse
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension UpdatesServiceAsyncProvider {
  internal static var serviceDescriptor: GRPCServiceDescriptor {
    return UpdatesServiceServerMetadata.serviceDescriptor
  }

  internal var serviceName: Substring {
    return UpdatesServiceServerMetadata.serviceDescriptor.fullName[...]
  }

  internal var interceptors: UpdatesServiceServerInterceptorFactoryProtocol? {
    return nil
  }

  internal func handle(
    method name: Substring,
    context: CallHandlerContext
  ) -> GRPCServerHandlerProtocol? {
    switch name {
    case "Listen":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<ListenRequest>(),
        responseSerializer: ProtobufSerializer<Updates>(),
        interceptors: self.interceptors?.makeListenInterceptors() ?? [],
        wrapping: { try await self.listen(request: $0, responseStream: $1, context: $2) }
      )

    case "Ping":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<PingRequest>(),
        responseSerializer: ProtobufSerializer<PingResponse>(),
        interceptors: self.interceptors?.makePingInterceptors() ?? [],
        wrapping: { try await self.ping(request: $0, context: $1) }
      )

    case "GetInitialState":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<InitialStateRequest>(),
        responseSerializer: ProtobufSerializer<InitialStateResponse>(),
        interceptors: self.interceptors?.makeGetInitialStateInterceptors() ?? [],
        wrapping: { try await self.getInitialState(request: $0, context: $1) }
      )

    case "GetUpdates":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<GetUpdatesRequest>(),
        responseSerializer: ProtobufSerializer<GetUpdatesResponse>(),
        interceptors: self.interceptors?.makeGetUpdatesInterceptors() ?? [],
        wrapping: { try await self.getUpdates(request: $0, context: $1) }
      )

    default:
      return nil
    }
  }
}

internal protocol UpdatesServiceServerInterceptorFactoryProtocol: Sendable {

  /// - Returns: Interceptors to use when handling 'listen'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeListenInterceptors() -> [ServerInterceptor<ListenRequest, Updates>]

  /// - Returns: Interceptors to use when handling 'ping'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makePingInterceptors() -> [ServerInterceptor<PingRequest, PingResponse>]

  /// - Returns: Interceptors to use when handling 'getInitialState'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeGetInitialStateInterceptors() -> [ServerInterceptor<InitialStateRequest, InitialStateResponse>]

  /// - Returns: Interceptors to use when handling 'getUpdates'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeGetUpdatesInterceptors() -> [ServerInterceptor<GetUpdatesRequest, GetUpdatesResponse>]
}

internal enum UpdatesServiceServerMetadata {
  internal static let serviceDescriptor = GRPCServiceDescriptor(
    name: "UpdatesService",
    fullName: "UpdatesService",
    methods: [
      UpdatesServiceServerMetadata.Methods.listen,
      UpdatesServiceServerMetadata.Methods.ping,
      UpdatesServiceServerMetadata.Methods.getInitialState,
      UpdatesServiceServerMetadata.Methods.getUpdates,
    ]
  )

  internal enum Methods {
    internal static let listen = GRPCMethodDescriptor(
      name: "Listen",
      path: "/UpdatesService/Listen",
      type: GRPCCallType.serverStreaming
    )

    internal static let ping = GRPCMethodDescriptor(
      name: "Ping",
      path: "/UpdatesService/Ping",
      type: GRPCCallType.unary
    )

    internal static let getInitialState = GRPCMethodDescriptor(
      name: "GetInitialState",
      path: "/UpdatesService/GetInitialState",
      type: GRPCCallType.unary
    )

    internal static let getUpdates = GRPCMethodDescriptor(
      name: "GetUpdates",
      path: "/UpdatesService/GetUpdates",
      type: GRPCCallType.unary
    )
  }
}
