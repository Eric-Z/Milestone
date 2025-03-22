import SwiftUI

extension Color {
    init(hex: String) {
        // 移除 `#`
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let red, green, blue, alpha: Double
        switch hex.count {
        case 6: // RGB (默认 alpha 为 1)
            red   = Double((int >> 16) & 0xFF) / 255.0
            green = Double((int >> 8) & 0xFF) / 255.0
            blue  = Double(int & 0xFF) / 255.0
            alpha = 1.0
        case 8: // RGBA
            red   = Double((int >> 24) & 0xFF) / 255.0
            green = Double((int >> 16) & 0xFF) / 255.0
            blue  = Double((int >> 8) & 0xFF) / 255.0
            alpha = Double(int & 0xFF) / 255.0
        default:
            red = 0; green = 0; blue = 0; alpha = 1
        }
        
        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }
}
