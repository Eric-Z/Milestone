import SwiftUI

struct AppColors {
    
    @Environment(\.colorScheme) static var colorScheme
    
    /**
     grey
     */
    static let grey10 = Color(hex: "#000000")
    static let grey10_95 = Color(hex: "#000000").opacity(95)
    static let grey10_80 = Color(hex: "#000000").opacity(80)
    static let grey10_0 = Color(hex: "#000000").opacity(0)
    
    static let grey9 = Color(hex: "#1A1A19")
    static let grey8 = Color(hex: "#303030")
    static let grey7 = Color(hex: "#5D5D5D")
    static let grey6 = Color(hex: "#999996")
    static let grey5 = Color(hex: "#C5C5C4")
    static let grey2 = Color(hex: "#F0F0EF")
    static let grey1 = Color(hex: "#F7F7F6")
    static let grey0 = Color(hex: "#FFFFFF")
    static let grey0_95 = Color(hex: "#FFFFFF").opacity(95)
    static let grey0_80 = Color(hex: "#FFFFFF").opacity(80)
    static let grey0_0 = Color(hex: "#FFFFFF").opacity(0)
    
    /**
     orange
     */
    static let orange6 = Color(hex: "#FFAA01")
    static let orange5 = Color(hex: "#FFB21A")
    
    /**
     blue
     */
    static let blue6 = Color(hex: "#007BBC")
    static let blue5 = Color(hex: "#1B88C3")
    
    /**
     purple
     */
    static let purple6 = Color(hex: "#787AFF")
    
    /**
     text
     */
    static func text_body() -> Color {
        return colorScheme == .light ? grey8 : grey0;
    }
    
    static func text_item_highlight_body() -> Color {
        return colorScheme == .light ? grey0 : grey0;
    }
    
    static func text_item_highlight_note() -> Color {
        return colorScheme == .light ? grey0_80 : grey0_80;
    }
    
    static func text_placeholder_disable() -> Color {
        return colorScheme == .light ? grey5 : grey7;
    }
    
    static func text_note() -> Color {
        return colorScheme == .light ? grey6 : grey6;
    }
    
    static func text_highlight_1() -> Color {
        return colorScheme == .light ? orange6 : orange6;
    }
    
    static func text_highlight_2() -> Color {
        return colorScheme == .light ? blue6 : blue6;
    }
    
    static func text_button_solid() -> Color {
        return colorScheme == .light ? grey0 : orange6;
    }
    
    /**
     area
     */
    static func area_background() -> Color {
        return colorScheme == .light ? grey0 : grey10;
    }
    
    static func area_item() -> Color {
        return colorScheme == .light ? grey1 : grey9;
    }
    
    static func area_item_light() -> Color {
        return colorScheme == .light ? grey2 : grey9;
    }
    
    static func area_button_solid() -> Color {
        return colorScheme == .light ? orange6 : grey9;
    }
    
    static func area_border() -> Color {
        return colorScheme == .light ? grey2 : grey8;
    }
    
    static func area_musk_0() -> Color {
        return colorScheme == .light ? grey0_0 : grey10_0;
    }
    
    static func area_musk_95() -> Color {
        return colorScheme == .light ? grey0_95 : grey10_95;
    }
}
