import UIKit

extension UIColor {

    func serialize() -> Data {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0
        getHue(&h, saturation: &s, brightness: &b, alpha: nil)

        let serialized = [h, s, b]
            .map { String(format: "%.6f", $0) }
            .joined(separator: "|")
            .appending("|")

        return Data(serialized.utf8)
    }

    func normalized() -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: nil)

        r = max(min(r, 1), 0)
        g = max(min(g, 1), 0)
        b = max(min(b, 1), 0)

        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }

    func updating(brightness: CGFloat) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0
        getHue(&h, saturation: &s, brightness: nil, alpha: nil)

        return UIColor(hue: h, saturation: s, brightness: brightness, alpha: 1.0)
    }

}
