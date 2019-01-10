import Anchorage
import Lottie
import UIKit

class LoadingView: UIView {

    let animationView: LOTAnimationView = {
        let view = LOTAnimationView(name: "hourglass.json")
        view.loopAnimation = true
        return view
    }()

    init() {
        super.init(frame: .zero)

        setUpSelf()
        addSubviews()
        setUpConstraints()
    }

    private func setUpSelf() {
        backgroundColor = .white
    }

    private func addSubviews() {
        addSubview(animationView)
    }

    private func setUpConstraints() {
        animationView.widthAnchor == widthAnchor * 0.8
        animationView.heightAnchor == animationView.heightAnchor
        animationView.centerAnchors == centerAnchors
    }

    required init?(coder aDecoder: NSCoder) { return nil }

}
