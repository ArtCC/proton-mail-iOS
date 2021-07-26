import UIKit
import ProtonCore_UIFoundations

class ConversationExpandedMessageView: UIView {

    var topArrowTapAction: (() -> Void)?

    let contentContainer = SubviewsFactory.container
    let topArrowControl = SubviewsFactory.topArrowControl
    private let arrowImageView = SubviewsFactory.arrowImageView

    init() {
        super.init(frame: .zero)
        backgroundColor = UIColorManager.BackgroundSecondary
        addSubviews()
        setUpLayout()
        setUpActions()
    }

    private func addSubviews() {
        addSubview(contentContainer)
        addSubview(topArrowControl)
        topArrowControl.addSubview(arrowImageView)
    }

    private func setUpLayout() {
        [
            topArrowControl.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            topArrowControl.leadingAnchor.constraint(equalTo: leadingAnchor),
            topArrowControl.trailingAnchor.constraint(equalTo: trailingAnchor),
            topArrowControl.bottomAnchor.constraint(equalTo: contentContainer.topAnchor),
            topArrowControl.heightAnchor.constraint(equalToConstant: 22)
        ].activate()

        [
            contentContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2)
        ].activate()

        [
            arrowImageView.centerYAnchor.constraint(equalTo: topArrowControl.centerYAnchor),
            arrowImageView.centerXAnchor.constraint(equalTo: topArrowControl.centerXAnchor)
        ].activate()
    }

    private func setUpActions() {
        topArrowControl.addTarget(self, action: #selector(topArrowTap), for: .touchUpInside)
    }

    @objc private func topArrowTap() {
        topArrowTapAction?()
    }

    required init?(coder: NSCoder) {
        nil
    }

}

private enum SubviewsFactory {

    static var arrowImageView: UIImageView {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        imageView.image = Asset.collapseArrow.image
        return imageView
    }

    static var topArrowControl: UIControl {
        let control = UIControl(frame: .zero)
        control.backgroundColor = UIColorManager.BackgroundNorm
        return control
    }

    static var container: UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColorManager.BackgroundNorm
        return view
    }

}