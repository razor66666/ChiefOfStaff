import XCTest
@testable import ChiefOfStaff

final class QueryViewTests: XCTestCase {
    
    func testVaultParserExcludesPrivateAndIgnoredPathNotes() {
        let parser = VaultParser.shared
        
        let publicNote = """
        ---
        title: "Public OS Guide"
        visibility: public
        ---
        Public content body.
        """
        
        let privateNote = """
        ---
        title: "Secret Key Log"
        ---
        Private content.
        """
        
        let ignoredFolderNote = """
        ---
        title: "Inbox Draft"
        visibility: public
        ---
        Public content in 00_Inbox.
        """
        
        XCTAssertNotNil(parser.parseNote(rawContent: publicNote, relativePath: "Docs/Guide.md"))
        XCTAssertNil(parser.parseNote(rawContent: privateNote, relativePath: "Docs/Secret.md"))
        XCTAssertNil(parser.parseNote(rawContent: ignoredFolderNote, relativePath: "00_Inbox/Draft.md"))
    }
}