import Foundation

enum APIConfig {
    static var plantNetAPIKey: String {
        if let key = Bundle.main.object(forInfoDictionaryKey: "PLANTNET_API_KEY") as? String,
           !key.isEmpty, !key.hasPrefix("$(") {
            return key
        }
        if let envKey = ProcessInfo.processInfo.environment["PLANTNET_API_KEY"], !envKey.isEmpty {
            return envKey
        }
        // Pl@ntNet trial/demo public key placeholder
        return ""
    }

    static var perenualAPIKey: String {
        if let key = Bundle.main.object(forInfoDictionaryKey: "PERENUAL_API_KEY") as? String,
           !key.isEmpty, !key.hasPrefix("$(") {
            return key
        }
        if let envKey = ProcessInfo.processInfo.environment["PERENUAL_API_KEY"], !envKey.isEmpty {
            return envKey
        }
        return ""
    }

    static let plantNetBaseURL = "https://my-api.plantnet.org/v2/identify/all"
    static let perenualBaseURL = "https://perenual.com/api"

    static var hasLiveKeys: Bool {
        !plantNetAPIKey.isEmpty || !perenualAPIKey.isEmpty
    }
}
