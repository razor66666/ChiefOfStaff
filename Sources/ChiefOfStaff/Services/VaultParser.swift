import Foundation

public struct ParsedNote: Identifiable, Equatable {
    public var id: String { relativePath }
    public let relativePath: String
    public let title: String
    public let content: String
    public let visibility: String
    public let isPublic: Bool
    public let metadata: [String: String]
}

/// Handles reading Markdown files, enforcing path exclusions, and evaluating `visibility: public` YAML frontmatter.
public class VaultParser {
    public static let shared = VaultParser()
    
    // Default ignored paths (Defense-in-Depth Rule 2)
    private var ignoredDirectories: [String] = [
        "00_Inbox",
        "00_Private",
        "Vault_Admin",
        ".obsidian",
        ".git"
    ]
    
    public init(ignoredDirectories: [String]? = nil) {
        if let customIgnores = ignoredDirectories {
            self.ignoredDirectories = customIgnores
        }
    }

    /// Evaluates if a relative file path is permitted for indexing.
    public func isPathAllowed(relativePath: String) -> Bool {
        let normalizedPath = relativePath.replacingOccurrences(of: "\\", with: "/")
        
        for ignored in ignoredDirectories {
            if normalizedPath.hasPrefix(ignored) || normalizedPath.contains("/\(ignored)/") {
                return false
            }
        }
        return true
    }

    /// Parses raw note content to extract YAML frontmatter and evaluate visibility.
    /// - Parameters:
    ///   - rawContent: Full string content of the Markdown note.
    ///   - relativePath: Note location in vault for path filtering.
    /// - Returns: A ParsedNote object if permitted and public, or nil if private/excluded.
    public func parseNote(rawContent: String, relativePath: String) -> ParsedNote? {
        // Rule 2 Check: Path exclusion
        guard isPathAllowed(relativePath: relativePath) else {
            return nil
        }
        
        var metadata: [String: String] = [:]
        var bodyContent = rawContent
        
        // Extract YAML Frontmatter block (surrounded by ---)
        if rawContent.hasPrefix("---") {
            let lines = rawContent.components(separatedBy: .newlines)
            var frontmatterLines: [String] = []
            var contentLines: [String] = []
            var inFrontmatter = false
            var fenceCount = 0
            
            for line in lines {
                if line.trimmingCharacters(in: .whitespaces) == "---" {
                    fenceCount += 1
                    if fenceCount == 1 {
                        inFrontmatter = true
                        continue
                    } else if fenceCount == 2 {
                        inFrontmatter = false
                        continue
                    }
                }
                
                if inFrontmatter {
                    frontmatterLines.append(line)
                } else {
                    contentLines.append(line)
                }
            }
            
            // Parse Key-Value YAML lines
            for fLine in frontmatterLines {
                let parts = fLine.split(separator: ":", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
                if parts.count == 2 {
                    let key = parts[0].lowercased()
                    let value = parts[1].replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "'", with: "")
                    metadata[key] = value
                }
            }
            
            bodyContent = contentLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // Rule 1 Check: Default Deny. Must explicitly state `visibility: public`
        let visibility = metadata["visibility"]?.lowercased() ?? "private"
        let isPublic = (visibility == "public")
        
        guard isPublic else {
            return nil
        }
        
        // Fallback title to filename if no frontmatter title
        let fileName = URL(fileURLWithPath: relativePath).deletingPathExtension().lastPathComponent
        let title = metadata["title"] ?? fileName
        
        return ParsedNote(
            relativePath: relativePath,
            title: title,
            content: bodyContent,
            visibility: visibility,
            isPublic: isPublic,
            metadata: metadata
        )
    }
}