import Foundation
import SwiftUI

extension Color {
    static var blood: Color {
        return .accent
    }
}

extension Color {
    static var random: Color {
        return Color.random(seed: Int(Date().timeIntervalSince1970 * 1000))
    }
    
    static func random(seed: Int) -> Color {
        srand48(seed * 200)
        let r = CGFloat(drand48())
        
        srand48(seed)
        let g = CGFloat(drand48())
        
        srand48(seed / 200)
        let b = CGFloat(drand48())
        
        return Color(red: r, green: g, blue: b)
    }
    
    static func random(seed: String) ->  Color {
        var n = 0
        for u in seed.unicodeScalars {
            n += Int(UInt32(u))
        }
        
        return Color.random(seed: n)
    }
}
