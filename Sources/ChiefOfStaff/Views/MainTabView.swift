import SwiftUI

public struct MainTabView: View {
    public init() {}

    public var body: some View {
        TabView {
            CaptureView()
                .tabItem {
                    Label("Capture", systemImage: "square.and.pencil")
                }
            
            QueryView()
                .tabItem {
                    Label("Query", systemImage: "magnifyingglass")
                }
            
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "gauge")
                }
        }
    }
}