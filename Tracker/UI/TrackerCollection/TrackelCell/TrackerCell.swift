import UIKit

protocol TrackerCellButtonDelegate: AnyObject {
    func didTapButtonInCell(_ cell: TrackerCell)
    func didTapPinCell(_ cell: TrackerCell)
    func didTapUnPinCell(_ cell: TrackerCell)
    func didTapEditCell(_ cell: TrackerCell)
    func didTapDeleteCell(_ cell: TrackerCell)
}

final class TrackerCell: UICollectionViewCell {
    
    // MARK: - Public Properties
    
    static let reuseIdentifier = "trackerCell"

    var counterLabel: UILabel!
    var addButton: UIButton!
    var isPinned: Bool = false
    var viewModel: TrackerCellViewModel? {
        didSet {
            trackerCardView.viewModel = viewModel
            trackerCardView.setUpView()
      }
    }

    weak var delegate: TrackerCellButtonDelegate?
    
    // MARK: - Private Properties

    private var trackerCardView = TrackerCardView()
    private var isButtonSelected: Bool = false
    
    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TrackerCell {
    private func setupLayout() {
        setupCounterLabel()
        setupAddButton()

        trackerCardView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(trackerCardView)
        setupConstraints()
        setupContextMenu()
    }

    private func setupContextMenu() {
        let contextMenu = UIContextMenuInteraction(delegate: self)
//        trackerCardView.isUserInteractionEnabled = true
        trackerCardView.addInteraction(contextMenu)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            trackerCardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            trackerCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackerCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            trackerCardView.heightAnchor.constraint(equalToConstant: 90),

            counterLabel.topAnchor.constraint(equalTo: trackerCardView.bottomAnchor, constant: 16),
            counterLabel.leadingAnchor.constraint(equalTo: trackerCardView.leadingAnchor, constant: 12),

            addButton.topAnchor.constraint(equalTo: trackerCardView.bottomAnchor, constant: 8),
            addButton.trailingAnchor.constraint(equalTo: trackerCardView.trailingAnchor, constant: -12),
            addButton.widthAnchor.constraint(equalToConstant: 34),
            addButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }

    private func setupCounterLabel() {
        counterLabel = UILabel()
        counterLabel.font = .systemFont(ofSize: 12, weight: .medium)
        counterLabel.textColor = .ypBlackDay
        counterLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(counterLabel)
    }

    private func setupAddButton() {
        addButton = UIButton(type: .custom)
        addButton.layer.cornerRadius = 16
        addButton.layer.masksToBounds = true
        addButton.addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)
        addButton.imageView?.tintColor = .ypWhite
        addButton.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(addButton)
    }

    @objc private func addButtonPressed() {
        guard let delegate else { return }
        delegate.didTapButtonInCell(self)
    }
}

extension TrackerCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in

            let unPin = UIAction(title: NSLocalizedString("contextMenu.unpin", comment: "")) { _ in
                self.delegate?.didTapUnPinCell(self)
            }

            let pin = UIAction(title: NSLocalizedString("contextMenu.pin", comment: "")) { _ in
                self.delegate?.didTapPinCell(self)
            }

            let edit = UIAction(title: NSLocalizedString("contextMenu.edit", comment: "")) { _ in
                self.delegate?.didTapEditCell(self)
            }

            let delete = UIAction(title: NSLocalizedString("contextMenu.delete", comment: ""), attributes: .destructive) { _ in
                self.delegate?.didTapDeleteCell(self)
            }

            if self.isPinned {
                return UIMenu(title: "", children: [unPin, edit, delete])
            }

            return UIMenu(title: "", children: [pin, edit, delete])
        }
    }
}
