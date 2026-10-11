import Foundation

public struct AppConfig {
    public static let shared = AppConfig()
    
    public let ingestEndpoint: URL
    public let defaultVisibility: String
    public let ignoredDirectories: [String]
    
    private init() {
        // 1. Try reading from ProcessInfo environment variables (useful for CI/CD or custom runners)
        if let envEndpoint = ProcessInfo.processInfo.environment["INGEST_ENDPOINT"],
           let url = URL(string: envEndpoint) {
            self.ingestEndpoint = url
        } 
        // 2. Fall back to local AppConfig.plist
        else if let path = Bundle.main.path(forResource: "AppConfig", ofType: "plist"),
                let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
                let endpointString = dict["IngestEndpoint"] as? String,
                let url = URL(string: endpointString) {
            self.ingestEndpoint = url
        } 
        // 3. Fallback generic default for public open-source builds
        else {
            self.ingestEndpoint = URL(string: "http://localhost:8080/v1/ingest")!
        }
        
        self.defaultVisibility = ProcessInfo.processInfo.environment["DEFAULT_VISIBILITY"] ?? "private"
        self.ignoredDirectories = ["00_Inbox", "00_Private", "Vault_Admin", ".obsidian", ".git"]
    }
}