//
// DO NOT EDIT.
//
// Generated by the protocol buffer compiler.
// Source: contact_service.proto
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


/// Usage: instantiate `ContactServiceClient`, then call methods of this protocol to make API calls.
internal protocol ContactServiceClientProtocol: GRPCClient {
  var serviceName: String { get }
  var interceptors: ContactServiceClientInterceptorFactoryProtocol? { get }

  func `import`(
    _ request: ContactsImportRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<ContactsImportRequest, ContactImportResponse>

  func getContactByUserId(
    _ request: ContactByUserIdRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<ContactByUserIdRequest, ContactByUserIdResponse>

  func getStatuses(
    _ request: GetStatusesRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<GetStatusesRequest, GetStatusesResponse>
}

extension ContactServiceClientProtocol {
  internal var serviceName: String {
    return "ContactService"
  }

  /// Unary call to Import
  ///
  /// - Parameters:
  ///   - request: Request to send to Import.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func `import`(
    _ request: ContactsImportRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<ContactsImportRequest, ContactImportResponse> {
    return self.makeUnaryCall(
      path: ContactServiceClientMetadata.Methods.`import`.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeImportInterceptors() ?? []
    )
  }

  /// Unary call to GetContactByUserId
  ///
  /// - Parameters:
  ///   - request: Request to send to GetContactByUserId.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func getContactByUserId(
    _ request: ContactByUserIdRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<ContactByUserIdRequest, ContactByUserIdResponse> {
    return self.makeUnaryCall(
      path: ContactServiceClientMetadata.Methods.getContactByUserId.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetContactByUserIdInterceptors() ?? []
    )
  }

  /// Unary call to GetStatuses
  ///
  /// - Parameters:
  ///   - request: Request to send to GetStatuses.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func getStatuses(
    _ request: GetStatusesRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<GetStatusesRequest, GetStatusesResponse> {
    return self.makeUnaryCall(
      path: ContactServiceClientMetadata.Methods.getStatuses.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetStatusesInterceptors() ?? []
    )
  }
}

#if compiler(>=5.6)
@available(*, deprecated)
extension ContactServiceClient: @unchecked Sendable {}
#endif // compiler(>=5.6)

@available(*, deprecated, renamed: "ContactServiceNIOClient")
internal final class ContactServiceClient: ContactServiceClientProtocol {
  private let lock = Lock()
  private var _defaultCallOptions: CallOptions
  private var _interceptors: ContactServiceClientInterceptorFactoryProtocol?
  internal let channel: GRPCChannel
  internal var defaultCallOptions: CallOptions {
    get { self.lock.withLock { return self._defaultCallOptions } }
    set { self.lock.withLockVoid { self._defaultCallOptions = newValue } }
  }
  internal var interceptors: ContactServiceClientInterceptorFactoryProtocol? {
    get { self.lock.withLock { return self._interceptors } }
    set { self.lock.withLockVoid { self._interceptors = newValue } }
  }

  /// Creates a client for the ContactService service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  internal init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: ContactServiceClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self._defaultCallOptions = defaultCallOptions
    self._interceptors = interceptors
  }
}

internal struct ContactServiceNIOClient: ContactServiceClientProtocol {
  internal var channel: GRPCChannel
  internal var defaultCallOptions: CallOptions
  internal var interceptors: ContactServiceClientInterceptorFactoryProtocol?

  /// Creates a client for the ContactService service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  internal init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: ContactServiceClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

#if compiler(>=5.6)
@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
internal protocol ContactServiceAsyncClientProtocol: GRPCClient {
  static var serviceDescriptor: GRPCServiceDescriptor { get }
  var interceptors: ContactServiceClientInterceptorFactoryProtocol? { get }

  func makeImportCall(
    _ request: ContactsImportRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncUnaryCall<ContactsImportRequest, ContactImportResponse>

  func makeGetContactByUserIDCall(
    _ request: ContactByUserIdRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncUnaryCall<ContactByUserIdRequest, ContactByUserIdResponse>

  func makeGetStatusesCall(
    _ request: GetStatusesRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncUnaryCall<GetStatusesRequest, GetStatusesResponse>
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension ContactServiceAsyncClientProtocol {
  internal static var serviceDescriptor: GRPCServiceDescriptor {
    return ContactServiceClientMetadata.serviceDescriptor
  }

  internal var interceptors: ContactServiceClientInterceptorFactoryProtocol? {
    return nil
  }

  internal func makeImportCall(
    _ request: ContactsImportRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncUnaryCall<ContactsImportRequest, ContactImportResponse> {
    return self.makeAsyncUnaryCall(
      path: ContactServiceClientMetadata.Methods.`import`.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeImportInterceptors() ?? []
    )
  }

  internal func makeGetContactByUserIDCall(
    _ request: ContactByUserIdRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncUnaryCall<ContactByUserIdRequest, ContactByUserIdResponse> {
    return self.makeAsyncUnaryCall(
      path: ContactServiceClientMetadata.Methods.getContactByUserId.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetContactByUserIdInterceptors() ?? []
    )
  }

  internal func makeGetStatusesCall(
    _ request: GetStatusesRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncUnaryCall<GetStatusesRequest, GetStatusesResponse> {
    return self.makeAsyncUnaryCall(
      path: ContactServiceClientMetadata.Methods.getStatuses.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetStatusesInterceptors() ?? []
    )
  }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension ContactServiceAsyncClientProtocol {
  internal func `import`(
    _ request: ContactsImportRequest,
    callOptions: CallOptions? = nil
  ) async throws -> ContactImportResponse {
    return try await self.performAsyncUnaryCall(
      path: ContactServiceClientMetadata.Methods.`import`.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeImportInterceptors() ?? []
    )
  }

  internal func getContactByUserId(
    _ request: ContactByUserIdRequest,
    callOptions: CallOptions? = nil
  ) async throws -> ContactByUserIdResponse {
    return try await self.performAsyncUnaryCall(
      path: ContactServiceClientMetadata.Methods.getContactByUserId.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetContactByUserIdInterceptors() ?? []
    )
  }

  internal func getStatuses(
    _ request: GetStatusesRequest,
    callOptions: CallOptions? = nil
  ) async throws -> GetStatusesResponse {
    return try await self.performAsyncUnaryCall(
      path: ContactServiceClientMetadata.Methods.getStatuses.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetStatusesInterceptors() ?? []
    )
  }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
internal struct ContactServiceAsyncClient: ContactServiceAsyncClientProtocol {
  internal var channel: GRPCChannel
  internal var defaultCallOptions: CallOptions
  internal var interceptors: ContactServiceClientInterceptorFactoryProtocol?

  internal init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: ContactServiceClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

#endif // compiler(>=5.6)

internal protocol ContactServiceClientInterceptorFactoryProtocol: GRPCSendable {

  /// - Returns: Interceptors to use when invoking '`import`'.
  func makeImportInterceptors() -> [ClientInterceptor<ContactsImportRequest, ContactImportResponse>]

  /// - Returns: Interceptors to use when invoking 'getContactByUserId'.
  func makeGetContactByUserIdInterceptors() -> [ClientInterceptor<ContactByUserIdRequest, ContactByUserIdResponse>]

  /// - Returns: Interceptors to use when invoking 'getStatuses'.
  func makeGetStatusesInterceptors() -> [ClientInterceptor<GetStatusesRequest, GetStatusesResponse>]
}

internal enum ContactServiceClientMetadata {
  internal static let serviceDescriptor = GRPCServiceDescriptor(
    name: "ContactService",
    fullName: "ContactService",
    methods: [
      ContactServiceClientMetadata.Methods.`import`,
      ContactServiceClientMetadata.Methods.getContactByUserId,
      ContactServiceClientMetadata.Methods.getStatuses,
    ]
  )

  internal enum Methods {
    internal static let `import` = GRPCMethodDescriptor(
      name: "Import",
      path: "/ContactService/Import",
      type: GRPCCallType.unary
    )

    internal static let getContactByUserId = GRPCMethodDescriptor(
      name: "GetContactByUserId",
      path: "/ContactService/GetContactByUserId",
      type: GRPCCallType.unary
    )

    internal static let getStatuses = GRPCMethodDescriptor(
      name: "GetStatuses",
      path: "/ContactService/GetStatuses",
      type: GRPCCallType.unary
    )
  }
}

/// To build a server, implement a class that conforms to this protocol.
internal protocol ContactServiceProvider: CallHandlerProvider {
  var interceptors: ContactServiceServerInterceptorFactoryProtocol? { get }

  func `import`(request: ContactsImportRequest, context: StatusOnlyCallContext) -> EventLoopFuture<ContactImportResponse>

  func getContactByUserId(request: ContactByUserIdRequest, context: StatusOnlyCallContext) -> EventLoopFuture<ContactByUserIdResponse>

  func getStatuses(request: GetStatusesRequest, context: StatusOnlyCallContext) -> EventLoopFuture<GetStatusesResponse>
}

extension ContactServiceProvider {
  internal var serviceName: Substring {
    return ContactServiceServerMetadata.serviceDescriptor.fullName[...]
  }

  /// Determines, calls and returns the appropriate request handler, depending on the request's method.
  /// Returns nil for methods not handled by this service.
  internal func handle(
    method name: Substring,
    context: CallHandlerContext
  ) -> GRPCServerHandlerProtocol? {
    switch name {
    case "Import":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<ContactsImportRequest>(),
        responseSerializer: ProtobufSerializer<ContactImportResponse>(),
        interceptors: self.interceptors?.makeImportInterceptors() ?? [],
        userFunction: self.`import`(request:context:)
      )

    case "GetContactByUserId":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<ContactByUserIdRequest>(),
        responseSerializer: ProtobufSerializer<ContactByUserIdResponse>(),
        interceptors: self.interceptors?.makeGetContactByUserIdInterceptors() ?? [],
        userFunction: self.getContactByUserId(request:context:)
      )

    case "GetStatuses":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<GetStatusesRequest>(),
        responseSerializer: ProtobufSerializer<GetStatusesResponse>(),
        interceptors: self.interceptors?.makeGetStatusesInterceptors() ?? [],
        userFunction: self.getStatuses(request:context:)
      )

    default:
      return nil
    }
  }
}

#if compiler(>=5.6)

/// To implement a server, implement an object which conforms to this protocol.
@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
internal protocol ContactServiceAsyncProvider: CallHandlerProvider {
  static var serviceDescriptor: GRPCServiceDescriptor { get }
  var interceptors: ContactServiceServerInterceptorFactoryProtocol? { get }

  @Sendable func `import`(
    request: ContactsImportRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> ContactImportResponse

  @Sendable func getContactByUserId(
    request: ContactByUserIdRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> ContactByUserIdResponse

  @Sendable func getStatuses(
    request: GetStatusesRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> GetStatusesResponse
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension ContactServiceAsyncProvider {
  internal static var serviceDescriptor: GRPCServiceDescriptor {
    return ContactServiceServerMetadata.serviceDescriptor
  }

  internal var serviceName: Substring {
    return ContactServiceServerMetadata.serviceDescriptor.fullName[...]
  }

  internal var interceptors: ContactServiceServerInterceptorFactoryProtocol? {
    return nil
  }

  internal func handle(
    method name: Substring,
    context: CallHandlerContext
  ) -> GRPCServerHandlerProtocol? {
    switch name {
    case "Import":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<ContactsImportRequest>(),
        responseSerializer: ProtobufSerializer<ContactImportResponse>(),
        interceptors: self.interceptors?.makeImportInterceptors() ?? [],
        wrapping: self.`import`(request:context:)
      )

    case "GetContactByUserId":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<ContactByUserIdRequest>(),
        responseSerializer: ProtobufSerializer<ContactByUserIdResponse>(),
        interceptors: self.interceptors?.makeGetContactByUserIdInterceptors() ?? [],
        wrapping: self.getContactByUserId(request:context:)
      )

    case "GetStatuses":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<GetStatusesRequest>(),
        responseSerializer: ProtobufSerializer<GetStatusesResponse>(),
        interceptors: self.interceptors?.makeGetStatusesInterceptors() ?? [],
        wrapping: self.getStatuses(request:context:)
      )

    default:
      return nil
    }
  }
}

#endif // compiler(>=5.6)

internal protocol ContactServiceServerInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when handling '`import`'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeImportInterceptors() -> [ServerInterceptor<ContactsImportRequest, ContactImportResponse>]

  /// - Returns: Interceptors to use when handling 'getContactByUserId'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeGetContactByUserIdInterceptors() -> [ServerInterceptor<ContactByUserIdRequest, ContactByUserIdResponse>]

  /// - Returns: Interceptors to use when handling 'getStatuses'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeGetStatusesInterceptors() -> [ServerInterceptor<GetStatusesRequest, GetStatusesResponse>]
}

internal enum ContactServiceServerMetadata {
  internal static let serviceDescriptor = GRPCServiceDescriptor(
    name: "ContactService",
    fullName: "ContactService",
    methods: [
      ContactServiceServerMetadata.Methods.`import`,
      ContactServiceServerMetadata.Methods.getContactByUserId,
      ContactServiceServerMetadata.Methods.getStatuses,
    ]
  )

  internal enum Methods {
    internal static let `import` = GRPCMethodDescriptor(
      name: "Import",
      path: "/ContactService/Import",
      type: GRPCCallType.unary
    )

    internal static let getContactByUserId = GRPCMethodDescriptor(
      name: "GetContactByUserId",
      path: "/ContactService/GetContactByUserId",
      type: GRPCCallType.unary
    )

    internal static let getStatuses = GRPCMethodDescriptor(
      name: "GetStatuses",
      path: "/ContactService/GetStatuses",
      type: GRPCCallType.unary
    )
  }
}
