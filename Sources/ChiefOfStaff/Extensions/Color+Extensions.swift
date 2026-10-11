import SwiftUI

#if os(iOS)
import UIKit
#endif

extension Color {
    public static var customSecondarySystemBackground: Color {
        #if os(iOS)
        return Color(UIColor.secondarySystemBackground)
        #else
        return Color.secondary.opacity(0.15)
        #endif
    }
}