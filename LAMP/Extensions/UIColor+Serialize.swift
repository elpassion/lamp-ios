import UIKit

extension UIColor {

    func serialize() -> Data {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0
        getHue(&h, saturation: &s, brightness: &b, alpha: nil)

        let serialized = [h, s, b].map { String(format: "%.6f", $0) }.joined(separator: "|")
        print("Serialized: \(serialized)")
        return Data(serialized.utf8)
    }

}
