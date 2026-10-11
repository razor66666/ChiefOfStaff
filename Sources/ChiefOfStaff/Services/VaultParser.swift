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
    
    private var ignoredDirectories: [String]
    
    public init(ignoredDirectories: [String]? = nil) {
        self.ignoredDirectories = ignoredDirectories ?? AppConfig.shared.ignoredDirectories
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
    public func parseNote(rawContent: String, relativePath: String) -> ParsedNote? {
        // Defense-in-Depth Rule 2: Path exclusion
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
        
        // Defense-in-Depth Rule 1: Default Deny. Must explicitly state `visibility: public`
        let visibility = metadata["visibility"]?.lowercased() ?? AppConfig.shared.defaultVisibility
        let isPublic = (visibility == "public")
        
        guard isPublic else {
            return nil
        }
        
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