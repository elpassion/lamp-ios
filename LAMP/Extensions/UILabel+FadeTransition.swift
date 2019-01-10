import UIKit

extension UILabel {

    func fade(to text: String, duration: CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = .fade
        animation.duration = duration
        layer.add(animation, forKey: kCATransition)

        self.text = text
    }

}
