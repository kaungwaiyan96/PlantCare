import Foundation

enum APIConfig {
    static var plantNetAPIKey: String {
        if let key = bundledValue(for: "PLANTNET_API_KEY") {
            return key
        }
        if let envKey = cleaned(ProcessInfo.processInfo.environment["PLANTNET_API_KEY"]) {
            return envKey
        }
        return ""
    }

    static var perenualAPIKey: String {
        if let key = bundledValue(for: "PERENUAL_API_KEY") {
            return key
        }
        if let envKey = cleaned(ProcessInfo.processInfo.environment["PERENUAL_API_KEY"]) {
            return envKey
        }
        return ""
    }

    private static func bundledValue(for name: String) -> String? {
        let keys = [name, "INFOPLIST_KEY_\(name)"]
        for key in keys {
            if let value = cleaned(Bundle.main.object(forInfoDictionaryKey: key) as? String) {
                return value
            }
        }
        return nil
    }

    private static func cleaned(_ value: String?) -> String? {
        guard let value else { return nil }
        let result = value.trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        guard !result.isEmpty, !result.hasPrefix("$(") else { return nil }
        return result
    }

    static let plantNetBaseURL = "https://my-api.plantnet.org/v2/identify/all"
    static let perenualBaseURL = "https://perenual.com/api"

    static var hasLiveKeys: Bool {
        !plantNetAPIKey.isEmpty || !perenualAPIKey.isEmpty
    }
}
