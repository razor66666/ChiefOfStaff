import SwiftUI

public struct DashboardView: View {
    @ObservedObject private var queueManager = QueueManager.shared

    // Configurable Council State Array (Sanitized for Open-Source)
    @State private var councilPersonas: [PersonaConfig] = [
        PersonaConfig(
            id: "blocker_mgr",
            name: "Blocker Manager",
            role: "Critical Path Guard",
            iconName: "exclamationmark.shield.fill",
            colorHex: "red",
            metricCount: 1,
            metricLabel: "Blockers"
        ),
        PersonaConfig(
            id: "risk_mgr",
            name: "Risk Guardian",
            role: "Evidence & Security",
            iconName: "eye.fill",
            colorHex: "orange",
            metricCount: 0,
            metricLabel: "Risks"
        ),
        PersonaConfig(
            id: "logic_mgr",
            name: "Logic Challenger",
            role: "Assumption Audit",
            iconName: "bolt.horizontal.fill",
            colorHex: "purple",
            metricCount: 2,
            metricLabel: "Challenges"
        ),
        PersonaConfig(
            id: "triage_mgr",
            name: "Triage Gatekeeper",
            role: "Speculative Queue",
            iconName: "tray.full.fill",
            colorHex: "gray",
            metricCount: 4,
            metricLabel: "Queue Items"
        )
    ]

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // System Status Header Bar
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("CHIEF OF STAFF")
                                .font(.caption)
                                .bold()
                                .foregroundColor(.blue)
                            Text("Executive Dashboard")
                                .font(.title2)
                                .bold()
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 8, height: 8)
                                Text("Online")
                                    .font(.caption)
                                    .bold()
                            }
                            Text("\(queueManager.pendingQueueCount) Queued Flushes")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.customSecondarySystemBackground)
                    .cornerRadius(12)

                    // Configurable Council Grid
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Council Persona Status")
                            .font(.headline)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(councilPersonas) { persona in
                                CouncilCard(persona: persona)
                            }
                        }
                    }

                    // Active System Blockers Stream
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Active System Blockers")
                                .font(.headline)
                            Spacer()
                            Text("Priority 1")
                                .font(.caption2)
                                .bold()
                                .foregroundColor(.red)
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "xmark.octagon.fill")
                                    .foregroundColor(.red)
                                    .padding(.top, 2)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Milestone 1 Live Ingest Endpoint Verification")
                                        .font(.subheadline)
                                        .bold()
                                    Text("Pending live webhook verification test (Issue #1).")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.customTertiarySystemBackground)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Executive Center")
        }
    }
}

// Generic Reusable Council Card View
struct CouncilCard: View {
    let persona: PersonaConfig

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: persona.iconName)
                    .foregroundColor(persona.themeColor)
                    .font(.title3)
                Spacer()
                Text("\(persona.metricCount)")
                    .font(.title2)
                    .bold()
                    .foregroundColor(persona.metricCount > 0 ? persona.themeColor : .secondary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(persona.name)
                    .font(.headline)
                Text(persona.role)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.customSecondarySystemBackground)
        .cornerRadius(12)
    }
}
