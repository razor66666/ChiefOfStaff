import XCTest
@testable import ChiefOfStaff

final class VaultParserTests: XCTestCase {
    let parser = VaultParser.shared

    func testPublicNoteWithYAMLPasses() {
        let noteContent = """
        ---
        title: "Public Architecture Guide"
        visibility: public
        ---
        This is public knowledge text.
        """
        
        let result = parser.parseNote(rawContent: noteContent, relativePath: "Knowledge/Architecture.md")
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.title, "Public Architecture Guide")
        XCTAssertTrue(result?.isPublic ?? false)
    }

    func testPrivateNoteIsRejectedByDefault() {
        let noteContent = """
        ---
        title: "Private Financial Log"
        ---
        Confidential details.
        """
        
        let result = parser.parseNote(rawContent: noteContent, relativePath: "Knowledge/Finances.md")
        XCTAssertNil(result, "Notes lacking 'visibility: public' must be rejected (Default Deny).")
    }

    func testIgnoredPathIsRejectedEvenIfPublic() {
        let noteContent = """
        ---
        visibility: public
        ---
        Public content in an inbox folder.
        """
        
        let result = parser.parseNote(rawContent: noteContent, relativePath: "00_Inbox/Note.md")
        XCTAssertNil(result, "Notes inside ignored paths must be rejected regardless of YAML tag.")
    }
}