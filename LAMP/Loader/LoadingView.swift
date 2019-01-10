import Anchorage
import Lottie
import UIKit

class LoadingView: UIView {

    let animationView: LOTAnimationView = {
        let view = LOTAnimationView(name: "hourglass.json")
        view.loopAnimation = true
        return view
    }()

    let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        label.textAlignment = .center
        label.text = "L.A.M.P."
        return label
    }()

    let container: UIView = UIView(frame: .zero)

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
        container.addSubview(titleLabel)
        container.addSubview(animationView)
        addSubview(container)
    }

    private func setUpConstraints() {
        titleLabel.topAnchor == container.topAnchor
        titleLabel.horizontalAnchors == container.horizontalAnchors

        animationView.topAnchor == titleLabel.bottomAnchor + 30
        animationView.horizontalAnchors == container.horizontalAnchors
        animationView.heightAnchor == animationView.widthAnchor
        animationView.bottomAnchor == container.bottomAnchor

        container.widthAnchor == widthAnchor * 0.8
        container.centerAnchors == centerAnchors
    }

    required init?(coder aDecoder: NSCoder) { return nil }

}
