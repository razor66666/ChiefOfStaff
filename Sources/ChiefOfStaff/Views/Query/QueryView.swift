import SwiftUI

public struct QueryView: View {
    @State private var searchQuery: String = ""
    @State private var parsedNotes: [ParsedNote] = []
    @State private var selectedNote: ParsedNote?
    @State private var isIndexing: Bool = false

    private let vaultParser = VaultParser.shared

    public init() {}

    public var filteredNotes: [ParsedNote] {
        if searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return parsedNotes
        } else {
            return parsedNotes.filter { note in
                note.title.localizedCaseInsensitiveContains(searchQuery) ||
                note.content.localizedCaseInsensitiveContains(searchQuery) ||
                note.relativePath.localizedCaseInsensitiveContains(searchQuery)
            }
        }
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar Header
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search public knowledge...", text: $searchQuery)
                        .textFieldStyle(.plain)
                    if !searchQuery.isEmpty {
                        Button(action: { searchQuery = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(10)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 8)

                // Privacy Status Indicator Banner
                HStack {
                    Image(systemName: "lock.shield.fill")
                        .foregroundColor(.green)
                    Text("Public Index Active (YAML Gate: Default Deny)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(filteredNotes.count) notes")
                        .font(.caption)
                        .bold()
                }
                .padding(.horizontal)
                .padding(.vertical, 8)

                Divider()

                // Results List / Empty State
                if filteredNotes.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text(searchQuery.isEmpty ? "No Public Knowledge Found" : "No Matches for '\(searchQuery)'")
                            .font(.headline)
                        Text("Ensure Markdown notes contain 'visibility: public' in YAML frontmatter.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    Spacer()
                } else {
                    List(filteredNotes) { note in
                        Button(action: { selectedNote = note }) {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(note.title)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text(note.relativePath)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                
                                Text(note.content)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                                
                                HStack(spacing: 4) {
                                    Text("PUBLIC")
                                        .font(.caption2)
                                        .bold()
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.green.opacity(0.2))
                                        .foregroundColor(.green)
                                        .cornerRadius(4)
                                    
                                    ForEach(Array(note.metadata.keys.prefix(3)), id: \.self) { key in
                                        if key != "title" && key != "visibility" {
                                            Text("#\(key)")
                                                .font(.caption2)
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Public Query")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: loadMockVaultData) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .sheet(item: $selectedNote) { note in
                NavigationStack {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text(note.relativePath)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("visibility: public")
                                    .font(.caption)
                                    .bold()
                                    .foregroundColor(.green)
                            }
                            
                            Divider()
                            
                            Text(note.content)
                                .font(.body)
                            
                            Spacer()
                        }
                        .padding()
                    }
                    .navigationTitle(note.title)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                selectedNote = nil
                            }
                        }
                    }
                }
            }
            .onAppear {
                loadMockVaultData()
            }
        }
    }

    /// Simulates local vault parsing and enforces VaultParser privacy filters
    private func loadMockVaultData() {
        let sampleFiles: [(path: String, content: String)] = [
            (
                path: "01_Projects/ChiefOfStaff.md",
                content: """
                ---
                title: "ChiefOfStaff iOS Architecture"
                visibility: public
                ---
                Local-first AGPLv3 companion app for personal knowledge management and operating council integrations.
                """
            ),
            (
                path: "00_Private/Financials.md",
                content: """
                ---
                title: "Private Ledger"
                visibility: public
                ---
                Confidential account details.
                """
            ),
            (
                path: "02_Knowledge/SwiftUI_Testing.md",
                content: """
                ---
                title: "SwiftUI Testing Best Practices"
                visibility: public
                ---
                Use standard SPM package layout with XCTest and MockURLProtocol for network unit isolation.
                """
            ),
            (
                path: "02_Knowledge/Internal_Notes.md",
                content: """
                ---
                title: "Unmarked Private Note"
                ---
                Lacks visibility tag, so Default Deny filter must block this.
                """
            )
        ]

        var allowedNotes: [ParsedNote] = []
        for file in sampleFiles {
            if let parsed = vaultParser.parseNote(rawContent: file.content, relativePath: file.path) {
                allowedNotes.append(parsed)
            }
        }
        
        self.parsedNotes = allowedNotes
    }
}