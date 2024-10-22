import UIKit

final class FilterChoiceViewCell: UITableViewCell {
    
    // MARK: - Public Properties
    
    var showCheckmark: Bool = false {
        didSet {
            checkmarkView.isHidden = !showCheckmark
        }
    }

    var categoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlackDay
        label.font = .systemFont(ofSize: 17, weight: .regular)
        return label
    }()

    var filter: Filter?

    var showSeparator: Bool = true {
        didSet {
            customSeparatorView.isHidden = !showSeparator
        }
    }
    
    // MARK: - Private Properties

    private let checkmarkView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "ypCheck"))
        view.isHidden = true

        return view
    }()

    private let customSeparatorView = UIView()
    
    // MARK: - Initializers

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overrides Methods

    override func prepareForReuse() {
      super.prepareForReuse()
      customSeparatorView.isHidden = false
      checkmarkView.isHidden = true
     }
    
    // MARK: - Private Methods

    private func setupUI() {
        contentView.backgroundColor = .ypBackgroundDay
        customSeparatorView.backgroundColor = .ypLightGay

        addSubview(categoryLabel)
        addSubview(checkmarkView)
        contentView.addSubview(customSeparatorView)

        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        checkmarkView.translatesAutoresizingMaskIntoConstraints = false
        customSeparatorView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            categoryLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            categoryLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            checkmarkView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            checkmarkView.centerYAnchor.constraint(equalTo: centerYAnchor),
            checkmarkView.heightAnchor.constraint(equalToConstant: 24),
            checkmarkView.widthAnchor.constraint(equalToConstant: 24),

            customSeparatorView.heightAnchor.constraint(equalToConstant: 1),
            customSeparatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            customSeparatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            customSeparatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

