import SwiftUI

extension Font {
    static func stacksDisplay(size: CGFloat, weight: Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    static func stacksText(size: CGFloat, weight: Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    static func instrumentSerifItalic(size: CGFloat) -> Font {
        .custom("InstrumentSerif-Italic", size: size).italic()
    }
}

