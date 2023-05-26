//
// DO NOT EDIT.
//
// Generated by the protocol buffer compiler.
// Source: chat_service.proto
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


/// Usage: instantiate `ChatServiceClient`, then call methods of this protocol to make API calls.
internal protocol ChatServiceClientProtocol: GRPCClient {
  var serviceName: String { get }
  var interceptors: ChatServiceClientInterceptorFactoryProtocol? { get }

  func delete(
    _ request: ChatDeleteRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<ChatDeleteRequest, ChatDeleteResponse>
}

extension ChatServiceClientProtocol {
  internal var serviceName: String {
    return "ChatService"
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

#if compiler(>=5.6)
@available(*, deprecated)
extension ChatServiceClient: @unchecked Sendable {}
#endif // compiler(>=5.6)

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

#if compiler(>=5.6)
@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
internal protocol ChatServiceAsyncClientProtocol: GRPCClient {
  static var serviceDescriptor: GRPCServiceDescriptor { get }
  var interceptors: ChatServiceClientInterceptorFactoryProtocol? { get }

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

#endif // compiler(>=5.6)

internal protocol ChatServiceClientInterceptorFactoryProtocol: GRPCSendable {

  /// - Returns: Interceptors to use when invoking 'delete'.
  func makeDeleteInterceptors() -> [ClientInterceptor<ChatDeleteRequest, ChatDeleteResponse>]
}

internal enum ChatServiceClientMetadata {
  internal static let serviceDescriptor = GRPCServiceDescriptor(
    name: "ChatService",
    fullName: "ChatService",
    methods: [
      ChatServiceClientMetadata.Methods.delete,
    ]
  )

  internal enum Methods {
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

#if compiler(>=5.6)

/// To implement a server, implement an object which conforms to this protocol.
@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
internal protocol ChatServiceAsyncProvider: CallHandlerProvider {
  static var serviceDescriptor: GRPCServiceDescriptor { get }
  var interceptors: ChatServiceServerInterceptorFactoryProtocol? { get }

  @Sendable func delete(
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
    case "Delete":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<ChatDeleteRequest>(),
        responseSerializer: ProtobufSerializer<ChatDeleteResponse>(),
        interceptors: self.interceptors?.makeDeleteInterceptors() ?? [],
        wrapping: self.delete(request:context:)
      )

    default:
      return nil
    }
  }
}

#endif // compiler(>=5.6)

internal protocol ChatServiceServerInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when handling 'delete'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeDeleteInterceptors() -> [ServerInterceptor<ChatDeleteRequest, ChatDeleteResponse>]
}

internal enum ChatServiceServerMetadata {
  internal static let serviceDescriptor = GRPCServiceDescriptor(
    name: "ChatService",
    fullName: "ChatService",
    methods: [
      ChatServiceServerMetadata.Methods.delete,
    ]
  )

  internal enum Methods {
    internal static let delete = GRPCMethodDescriptor(
      name: "Delete",
      path: "/ChatService/Delete",
      type: GRPCCallType.unary
    )
  }
}