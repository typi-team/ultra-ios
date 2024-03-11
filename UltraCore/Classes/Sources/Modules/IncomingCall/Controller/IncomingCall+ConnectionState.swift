import LiveKitClient

extension ConnectionState {
    var desctiption: String {
        switch self {
        case .connected:
            return CallStrings.connected.localized
        case .disconnected:
            return CallStrings.disconnected.localized
        case .connecting:
            return CallStrings.connecting.localized
        case .reconnecting:
            return CallStrings.reconnecting.localized
        }
    }
}
