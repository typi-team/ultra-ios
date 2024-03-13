//
// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the protocol buffer compiler.
// Source: contact_service.proto
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

  func getContacts(
    _ request: GetContactsRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<GetContactsRequest, GetContactsResponse>

  func getContactByUserId(
    _ request: ContactByUserIdRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<ContactByUserIdRequest, ContactByUserIdResponse>

  func getStatuses(
    _ request: GetStatusesRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<GetStatusesRequest, GetStatusesResponse>

  func acceptContact(
    _ request: AcceptContactRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<AcceptContactRequest, AcceptContactResponse>
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

  /// Unary call to GetContacts
  ///
  /// - Parameters:
  ///   - request: Request to send to GetContacts.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func getContacts(
    _ request: GetContactsRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<GetContactsRequest, GetContactsResponse> {
    return self.makeUnaryCall(
      path: ContactServiceClientMetadata.Methods.getContacts.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetContactsInterceptors() ?? []
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

  /// Unary call to AcceptContact
  ///
  /// - Parameters:
  ///   - request: Request to send to AcceptContact.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func acceptContact(
    _ request: AcceptContactRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<AcceptContactRequest, AcceptContactResponse> {
    return self.makeUnaryCall(
      path: ContactServiceClientMetadata.Methods.acceptContact.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeAcceptContactInterceptors() ?? []
    )
  }
}

@available(*, deprecated)
extension ContactServiceClient: @unchecked Sendable {}

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

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
internal protocol ContactServiceAsyncClientProtocol: GRPCClient {
  static var serviceDescriptor: GRPCServiceDescriptor { get }
  var interceptors: ContactServiceClientInterceptorFactoryProtocol? { get }

  func makeImportCall(
    _ request: ContactsImportRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncUnaryCall<ContactsImportRequest, ContactImportResponse>

  func makeGetContactsCall(
    _ request: GetContactsRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncUnaryCall<GetContactsRequest, GetContactsResponse>

  func makeGetContactByUserIDCall(
    _ request: ContactByUserIdRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncUnaryCall<ContactByUserIdRequest, ContactByUserIdResponse>

  func makeGetStatusesCall(
    _ request: GetStatusesRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncUnaryCall<GetStatusesRequest, GetStatusesResponse>

  func makeAcceptContactCall(
    _ request: AcceptContactRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncUnaryCall<AcceptContactRequest, AcceptContactResponse>
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

  internal func makeGetContactsCall(
    _ request: GetContactsRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncUnaryCall<GetContactsRequest, GetContactsResponse> {
    return self.makeAsyncUnaryCall(
      path: ContactServiceClientMetadata.Methods.getContacts.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetContactsInterceptors() ?? []
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

  internal func makeAcceptContactCall(
    _ request: AcceptContactRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncUnaryCall<AcceptContactRequest, AcceptContactResponse> {
    return self.makeAsyncUnaryCall(
      path: ContactServiceClientMetadata.Methods.acceptContact.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeAcceptContactInterceptors() ?? []
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

  internal func getContacts(
    _ request: GetContactsRequest,
    callOptions: CallOptions? = nil
  ) async throws -> GetContactsResponse {
    return try await self.performAsyncUnaryCall(
      path: ContactServiceClientMetadata.Methods.getContacts.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetContactsInterceptors() ?? []
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

  internal func acceptContact(
    _ request: AcceptContactRequest,
    callOptions: CallOptions? = nil
  ) async throws -> AcceptContactResponse {
    return try await self.performAsyncUnaryCall(
      path: ContactServiceClientMetadata.Methods.acceptContact.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeAcceptContactInterceptors() ?? []
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

internal protocol ContactServiceClientInterceptorFactoryProtocol: Sendable {

  /// - Returns: Interceptors to use when invoking '`import`'.
  func makeImportInterceptors() -> [ClientInterceptor<ContactsImportRequest, ContactImportResponse>]

  /// - Returns: Interceptors to use when invoking 'getContacts'.
  func makeGetContactsInterceptors() -> [ClientInterceptor<GetContactsRequest, GetContactsResponse>]

  /// - Returns: Interceptors to use when invoking 'getContactByUserId'.
  func makeGetContactByUserIdInterceptors() -> [ClientInterceptor<ContactByUserIdRequest, ContactByUserIdResponse>]

  /// - Returns: Interceptors to use when invoking 'getStatuses'.
  func makeGetStatusesInterceptors() -> [ClientInterceptor<GetStatusesRequest, GetStatusesResponse>]

  /// - Returns: Interceptors to use when invoking 'acceptContact'.
  func makeAcceptContactInterceptors() -> [ClientInterceptor<AcceptContactRequest, AcceptContactResponse>]
}

internal enum ContactServiceClientMetadata {
  internal static let serviceDescriptor = GRPCServiceDescriptor(
    name: "ContactService",
    fullName: "ContactService",
    methods: [
      ContactServiceClientMetadata.Methods.`import`,
      ContactServiceClientMetadata.Methods.getContacts,
      ContactServiceClientMetadata.Methods.getContactByUserId,
      ContactServiceClientMetadata.Methods.getStatuses,
      ContactServiceClientMetadata.Methods.acceptContact,
    ]
  )

  internal enum Methods {
    internal static let `import` = GRPCMethodDescriptor(
      name: "Import",
      path: "/ContactService/Import",
      type: GRPCCallType.unary
    )

    internal static let getContacts = GRPCMethodDescriptor(
      name: "GetContacts",
      path: "/ContactService/GetContacts",
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

    internal static let acceptContact = GRPCMethodDescriptor(
      name: "AcceptContact",
      path: "/ContactService/AcceptContact",
      type: GRPCCallType.unary
    )
  }
}

/// To build a server, implement a class that conforms to this protocol.
internal protocol ContactServiceProvider: CallHandlerProvider {
  var interceptors: ContactServiceServerInterceptorFactoryProtocol? { get }

  func `import`(request: ContactsImportRequest, context: StatusOnlyCallContext) -> EventLoopFuture<ContactImportResponse>

  func getContacts(request: GetContactsRequest, context: StatusOnlyCallContext) -> EventLoopFuture<GetContactsResponse>

  func getContactByUserId(request: ContactByUserIdRequest, context: StatusOnlyCallContext) -> EventLoopFuture<ContactByUserIdResponse>

  func getStatuses(request: GetStatusesRequest, context: StatusOnlyCallContext) -> EventLoopFuture<GetStatusesResponse>

  func acceptContact(request: AcceptContactRequest, context: StatusOnlyCallContext) -> EventLoopFuture<AcceptContactResponse>
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

    case "GetContacts":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<GetContactsRequest>(),
        responseSerializer: ProtobufSerializer<GetContactsResponse>(),
        interceptors: self.interceptors?.makeGetContactsInterceptors() ?? [],
        userFunction: self.getContacts(request:context:)
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

    case "AcceptContact":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<AcceptContactRequest>(),
        responseSerializer: ProtobufSerializer<AcceptContactResponse>(),
        interceptors: self.interceptors?.makeAcceptContactInterceptors() ?? [],
        userFunction: self.acceptContact(request:context:)
      )

    default:
      return nil
    }
  }
}

/// To implement a server, implement an object which conforms to this protocol.
@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
internal protocol ContactServiceAsyncProvider: CallHandlerProvider, Sendable {
  static var serviceDescriptor: GRPCServiceDescriptor { get }
  var interceptors: ContactServiceServerInterceptorFactoryProtocol? { get }

  func `import`(
    request: ContactsImportRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> ContactImportResponse

  func getContacts(
    request: GetContactsRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> GetContactsResponse

  func getContactByUserId(
    request: ContactByUserIdRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> ContactByUserIdResponse

  func getStatuses(
    request: GetStatusesRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> GetStatusesResponse

  func acceptContact(
    request: AcceptContactRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> AcceptContactResponse
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
        wrapping: { try await self.`import`(request: $0, context: $1) }
      )

    case "GetContacts":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<GetContactsRequest>(),
        responseSerializer: ProtobufSerializer<GetContactsResponse>(),
        interceptors: self.interceptors?.makeGetContactsInterceptors() ?? [],
        wrapping: { try await self.getContacts(request: $0, context: $1) }
      )

    case "GetContactByUserId":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<ContactByUserIdRequest>(),
        responseSerializer: ProtobufSerializer<ContactByUserIdResponse>(),
        interceptors: self.interceptors?.makeGetContactByUserIdInterceptors() ?? [],
        wrapping: { try await self.getContactByUserId(request: $0, context: $1) }
      )

    case "GetStatuses":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<GetStatusesRequest>(),
        responseSerializer: ProtobufSerializer<GetStatusesResponse>(),
        interceptors: self.interceptors?.makeGetStatusesInterceptors() ?? [],
        wrapping: { try await self.getStatuses(request: $0, context: $1) }
      )

    case "AcceptContact":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<AcceptContactRequest>(),
        responseSerializer: ProtobufSerializer<AcceptContactResponse>(),
        interceptors: self.interceptors?.makeAcceptContactInterceptors() ?? [],
        wrapping: { try await self.acceptContact(request: $0, context: $1) }
      )

    default:
      return nil
    }
  }
}

internal protocol ContactServiceServerInterceptorFactoryProtocol: Sendable {

  /// - Returns: Interceptors to use when handling '`import`'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeImportInterceptors() -> [ServerInterceptor<ContactsImportRequest, ContactImportResponse>]

  /// - Returns: Interceptors to use when handling 'getContacts'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeGetContactsInterceptors() -> [ServerInterceptor<GetContactsRequest, GetContactsResponse>]

  /// - Returns: Interceptors to use when handling 'getContactByUserId'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeGetContactByUserIdInterceptors() -> [ServerInterceptor<ContactByUserIdRequest, ContactByUserIdResponse>]

  /// - Returns: Interceptors to use when handling 'getStatuses'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeGetStatusesInterceptors() -> [ServerInterceptor<GetStatusesRequest, GetStatusesResponse>]

  /// - Returns: Interceptors to use when handling 'acceptContact'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeAcceptContactInterceptors() -> [ServerInterceptor<AcceptContactRequest, AcceptContactResponse>]
}

internal enum ContactServiceServerMetadata {
  internal static let serviceDescriptor = GRPCServiceDescriptor(
    name: "ContactService",
    fullName: "ContactService",
    methods: [
      ContactServiceServerMetadata.Methods.`import`,
      ContactServiceServerMetadata.Methods.getContacts,
      ContactServiceServerMetadata.Methods.getContactByUserId,
      ContactServiceServerMetadata.Methods.getStatuses,
      ContactServiceServerMetadata.Methods.acceptContact,
    ]
  )

  internal enum Methods {
    internal static let `import` = GRPCMethodDescriptor(
      name: "Import",
      path: "/ContactService/Import",
      type: GRPCCallType.unary
    )

    internal static let getContacts = GRPCMethodDescriptor(
      name: "GetContacts",
      path: "/ContactService/GetContacts",
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

    internal static let acceptContact = GRPCMethodDescriptor(
      name: "AcceptContact",
      path: "/ContactService/AcceptContact",
      type: GRPCCallType.unary
    )
  }
}
