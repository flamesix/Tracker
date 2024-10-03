import UIKit

final class TrackerButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    convenience init(_ title: String, _ backgroundColor: UIColor, _ titleColor: UIColor) {
        self.init(frame: .zero)
        setSolidButton(title: title, backColor: backgroundColor, titleColor: titleColor)
    }
    
    convenience init(_ title: String, _ backgroundColor: UIColor, _ titleColor: UIColor, _ borderWidth: CGFloat, _ borderColor: UIColor) {
        self.init(frame: .zero)
        setButton(title: title, backColor: backgroundColor, titleColor: titleColor, borderWidth: borderWidth, borderColor: borderColor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        layer.cornerRadius = 16
        titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setSolidButton(title: String, backColor: UIColor, titleColor: UIColor) {
        setTitle(title, for: .normal)
        backgroundColor = backColor
        setTitleColor(titleColor, for: .normal)
    }
    
    private func setButton(title: String, backColor: UIColor, titleColor: UIColor, borderWidth: CGFloat, borderColor: UIColor) {
        setTitle(title, for: .normal)
        backgroundColor = backColor
        setTitleColor(titleColor, for: .normal)
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
    }
}
