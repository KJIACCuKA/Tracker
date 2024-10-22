import UIKit

protocol EditTrackerDelegate: AnyObject {
    func didEditTracker(_ tracker: Tracker, with categoryName: String)
}

final class EditTrackerViewController: UIViewController {
    
    // MARK: - Public Properties
    
    weak var delegate: EditTrackerDelegate?
    
    // MARK: - Private Properties

    private var tableView: UITableView = UITableView()
    private var typeTitle: UILabel = UILabel()
    private var textField: UITextField = UITextField()
    private var saveButton: UIButton = UIButton()
    private var emojiCollectionViewController = EmojiMixesViewController()
    private var colorCollectionViewController = ColorCollectionViewController()
    private lazy var tableViewHeightConstraint: NSLayoutConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
    private var scrollView: UIScrollView = UIScrollView()
    private var selectedTitle: String = NSLocalizedString("editTracker.titleEvent", comment: "")
    private var cellTitle: [String] = [NSLocalizedString("addTracker.cellTitleCategory", comment: ""), NSLocalizedString("addTracker.cellTitleSchedule", comment: "")]
    private var selectedWeekdays: [WeekDay]
    private var selectedEmoji: String
    private var selectedColor: UIColor
    private var selectedCategory: String
    private var trackerName: String
    private var isPinned: Bool
    private var id: UUID
    
    // MARK: - Initializers

    init(tracker: Tracker, categoryName: String) {
        self.selectedWeekdays = tracker.timetable
        self.selectedEmoji = tracker.emoji
        self.selectedColor = tracker.color
        self.selectedCategory = categoryName
        self.id = tracker.id
        self.trackerName = tracker.name
        self.isPinned = tracker.isPinned

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
}

extension EditTrackerViewController {
    private func setupUI() {
        view.backgroundColor = .ypWhite

        scrollView.isScrollEnabled = true

        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.isScrollEnabled = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = UITableView.automaticDimension
        tableViewHeightConstraint.constant = CGFloat(75 * 2)
        tableViewHeightConstraint.isActive = true

        typeTitle = UILabel()
        typeTitle.text = selectedTitle

        typeTitle.textColor = .ypBlackDay
        typeTitle.font = .systemFont(ofSize: 16, weight: .medium)

        textField.delegate = self
        textField.backgroundColor = .ypBackgroundDay
        textField.layer.cornerRadius = 16
        textField.text = trackerName
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftView = leftView
        textField.leftViewMode = .always
        textField.textAlignment = .left

        let discardButton = setupActionButtonUI()
        discardButton.setTitle(NSLocalizedString("addTracker.discardButton", comment: ""), for: .normal)
        discardButton.setTitleColor(.ypRed, for: .normal)
        discardButton.backgroundColor = .ypWhite
        discardButton.layer.borderColor = UIColor.ypRed.cgColor
        discardButton.layer.borderWidth = 1.0

        saveButton = setupActionButtonUI()
        saveButton.setTitle(NSLocalizedString("addTracker.saveButton", comment: ""), for: .normal)
        saveButton.setTitleColor(.ypWhite, for: .normal)
        saveButton.backgroundColor = .ypGray
        saveButton.isEnabled = false

        let stackView = UIStackView(arrangedSubviews: [discardButton, saveButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8

        emojiCollectionViewController.selectedEmoji = selectedEmoji
        emojiCollectionViewController.delegate = self
        addChild(emojiCollectionViewController)
        emojiCollectionViewController.didMove(toParent: self)

        colorCollectionViewController.selectedColor = selectedColor
        colorCollectionViewController.delegate = self
        addChild(colorCollectionViewController)
        colorCollectionViewController.didMove(toParent: self)

        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        [typeTitle, textField, tableView, emojiCollectionViewController.view, colorCollectionViewController.view,  stackView].forEach{
            scrollView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            typeTitle.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 13),
            typeTitle.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),

            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: typeTitle.bottomAnchor, constant: 24),

            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            tableView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),

            emojiCollectionViewController.view.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            emojiCollectionViewController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            emojiCollectionViewController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            emojiCollectionViewController.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -16),
            emojiCollectionViewController.view.heightAnchor.constraint(equalToConstant: 220),


            colorCollectionViewController.view.topAnchor.constraint(equalTo: emojiCollectionViewController.view.bottomAnchor, constant: 16),
            colorCollectionViewController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            colorCollectionViewController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            colorCollectionViewController.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -16),
            colorCollectionViewController.view.heightAnchor.constraint(equalToConstant: 240),

            stackView.heightAnchor.constraint(equalToConstant: 60),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: colorCollectionViewController.view.bottomAnchor, constant: 34),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0)
        ])
    }

    private func setupActionButtonUI() -> UIButton {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(actionButtonTapped(_:)), for: .touchUpInside)
        button.tintColor = .ypWhite
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true

        return button
    }

    @objc private func actionButtonTapped(_ sender: UIButton) {
        trackerName = textField.text ?? ""

        if sender == saveButton {
            let newTracker = Tracker(
                id: id,
                name: trackerName,
                color: selectedColor,
                emoji: selectedEmoji,
                timetable: selectedWeekdays,
                isPinned: isPinned
            )

            delegate?.didEditTracker(newTracker, with: selectedCategory)
            dismiss(animated: true, completion: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    private func checkConditions() {
        let flag: Bool
        let text = textField.text ?? ""

        flag = !text.isEmpty && !selectedWeekdays.isEmpty && !selectedEmoji.isEmpty && selectedColor != nil && !selectedCategory.isEmpty

        if flag {
            saveButton.backgroundColor = .ypBlackDay
            saveButton.isEnabled = true
        }
    }

    private func formatSelectedWeekdays() -> String {
        if selectedWeekdays.count == WeekDay.allCases.count {
            return NSLocalizedString("addTracker.detailTextLabelEveryday", comment: "")
        }

        var resultString = ""

        for day in selectedWeekdays {
            switch day {
            case .monday:
                resultString += NSLocalizedString("addTracker.detailTextLabelMonday", comment: "")
            case .tuesday:
                resultString += NSLocalizedString("addTracker.detailTextLabelTuesday", comment: "")
            case .wednesday:
                resultString += NSLocalizedString("addTracker.detailTextLabelWednesday", comment: "")
            case .thursday:
                resultString += NSLocalizedString("addTracker.detailTextLabelThursday", comment: "")
            case .friday:
                resultString += NSLocalizedString("addTracker.detailTextLabelFriday", comment: "")
            case .saturday:
                resultString += NSLocalizedString("addTracker.detailTextLabelSaturday", comment: "")
            case .sunday:
                resultString += NSLocalizedString("addTracker.detailTextLabelSunday", comment: "")
            }

            if day != selectedWeekdays.last {
                resultString += ", "
            }
        }

        return resultString
    }
}

extension EditTrackerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.row == 0 {
            let selectedCategoryViewModel = CategoryNamesViewModel(selectedCategory: selectedCategory)
            let destinationViewController = CategoryViewController(viewModel: selectedCategoryViewModel)
            destinationViewController.delegate = self
            present(destinationViewController, animated: true, completion: nil)
        } else {
            let destinationViewController = ScheduleViewController(selectedWeekdays: selectedWeekdays)
            destinationViewController.delegate = self
            present(destinationViewController, animated: true, completion: nil)
        }
    }
}

extension EditTrackerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)

        cell.backgroundColor = .ypBackgroundDay

        if indexPath.row == 0 {
            cell.detailTextLabel?.text = selectedCategory
        } else {
            cell.detailTextLabel?.text = formatSelectedWeekdays()
        }

        cell.detailTextLabel?.textColor = .ypGray
        cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)

        cell.textLabel?.text = cellTitle[indexPath.row]
        cell.textLabel?.textColor = .ypBlackDay
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.accessoryType = .disclosureIndicator

        return cell
    }
}

extension EditTrackerViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return self.textLimit(existingText: textField.text,
                              newText: string,
                              limit: 38)
    }

    private func textLimit(existingText: String?,
                           newText: String,
                           limit: Int) -> Bool {
        let text = existingText ?? ""
        let isAtLimit = text.count + newText.count <= limit
        return isAtLimit
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        checkConditions()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension EditTrackerViewController: EmojiMixesDelegate {
    func didEmojiSelected(_ emoji: String) {
        selectedEmoji = emoji

        checkConditions()
    }
}

extension EditTrackerViewController: ColorDelegate {
    func didColorSelected(_ color: UIColor) {
        selectedColor = color

        checkConditions()
    }
}

extension EditTrackerViewController: ScheduleDelegate {
    func didDoneTapped(_ weekdays: [WeekDay]) {
        selectedWeekdays = weekdays
        checkConditions()
        tableView.reloadData()
    }
}

extension EditTrackerViewController: CategoryDelegate {
    func didDoneTapped(_ category: String) {
        selectedCategory = category
        checkConditions()
        tableView.reloadData()
    }
}
