import UIKit

final class StatisticCardView: UIView {
    private let rectangular: UIView = {
        let innerRect = UIView()
        innerRect.backgroundColor = .ypWhite
        innerRect.clipsToBounds = true
        innerRect.layer.cornerRadius = 15
        return innerRect
    }()

    private let counterLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypBlackDay
        label.textAlignment = .left
        return label
    }()

    private let statisticCardNameLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("completedStatisticCard.title", comment: "")
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlackDay
        label.textAlignment = .left
        return label
    }()

    private let gradientLayer = CAGradientLayer().gradientLayer

    override init(frame: CGRect){
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupUI()
        gradientLayer.frame = bounds
    }

    func updateView(counter: Int) {
        counterLabel.text = "\(counter)"
    }
}

extension StatisticCardView {
    private func setupUI() {

        clipsToBounds = true
        layer.cornerRadius = 16

        layer.insertSublayer(gradientLayer, at: 0)

        addSubview(rectangular)
        rectangular.translatesAutoresizingMaskIntoConstraints = false

        [counterLabel, statisticCardNameLabel].forEach { rectangular.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            rectangular.topAnchor.constraint(equalTo: self.topAnchor, constant: 1),
            rectangular.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 1),
            rectangular.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -1),
            rectangular.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1),

            counterLabel.leadingAnchor.constraint(equalTo: rectangular.leadingAnchor, constant: 12),
            counterLabel.topAnchor.constraint(equalTo: rectangular.topAnchor, constant: 12),

            statisticCardNameLabel.leadingAnchor.constraint(equalTo: rectangular.leadingAnchor, constant: 12),
            statisticCardNameLabel.topAnchor.constraint(equalTo: counterLabel.bottomAnchor, constant: 7)
        ])
    }
}
