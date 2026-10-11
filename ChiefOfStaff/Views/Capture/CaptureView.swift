import SwiftUI

public struct CaptureView: View {
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var selectedCategory: CaptureCategory = .inbox
    @State private var tagsText: String = ""
    @State private var isPrivate: Bool = true
    @State private var pendingQueueCount: Int = 0 // Staged queue counter
    
    @FocusState private var isContentFocused: Bool
    
    public init() {}

    public var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Category Selector Chips (Quickdown Style)
                Picker("Category", selection: $selectedCategory) {
                    ForEach(CaptureCategory.allCases) { cat in
                        Text(cat.rawValue.capitalized).tag(cat)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // Title Input
                TextField("Note Title / Action Item...", text: $title)
                    .font(.headline)
                    .padding(.horizontal)
                    .textFieldStyle(.roundedBorder)

                // Main Markdown Capture Body (Auto-focused)
                TextEditor(text: $content)
                    .focused($isContentFocused)
                    .font(.body)
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal)

                // Metadata: Tags & Visibility Toggle
                HStack {
                    TextField("Tags (comma separated)", text: $tagsText)
                        .textFieldStyle(.roundedBorder)
                    
                    Toggle(isOn: $isPrivate) {
                        Text("Private")
                            .font(.caption)
                    }
                    .toggleStyle(.switch)
                    .fixedSize()
                }
                .padding(.horizontal)

                Spacer()

                // Queue & Action Bar Footer
                VStack(spacing: 8) {
                    if pendingQueueCount > 0 {
                        Text("\(pendingQueueCount) items queued locally")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: handleEnqueue) {
                        HStack {
                            Image(systemName: "paperplane.fill")
                            Text("Enqueue Capture")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(10)
                    }
                    .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .navigationTitle("Quick Capture")
            .onAppear {
                // Auto-focus content body on view load (Quickdown pattern)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.isContentFocused = true
                }
            }
        }
    }

    private func handleEnqueue() {
        let parsedTags = tagsText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        let payload = CapturePayload(
            category: selectedCategory,
            title: title.isEmpty ? "Untitled Capture" : title,
            content: content,
            tags: parsedTags,
            visibility: isPrivate ? "private" : "public"
        )
        
        // TODO: Pass to QueueManager for local persistence & background transport
        print("Staged Payload for Queue: \(payload)")
        QueueManager.shared.enqueue(payload)
        
        // Reset form
        title = ""
        content = ""
        tagsText = ""
        pendingQueueCount += 1
    }
}