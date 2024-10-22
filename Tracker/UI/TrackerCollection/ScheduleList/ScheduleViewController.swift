import UIKit

protocol ScheduleDelegate: AnyObject {
    func didDoneTapped(_ weekdays: [WeekDay])
}

final class ScheduleViewController: UIViewController {
    
    // MARK: - Public Properties
    
    weak var delegate: ScheduleDelegate?
    
    // MARK: - Private Properties

    private let weekdays = WeekDay.allCasesRawValue

    private lazy var typeTitle: UILabel = {
        let typeTitle = UILabel()
        typeTitle.text = NSLocalizedString("schedule.title", comment: "")
        typeTitle.textColor = .ypBlackDay
        typeTitle.font = .systemFont(ofSize: 16, weight: .medium)
        return typeTitle
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.register(WeekdayTableViewCell.self, forCellReuseIdentifier: WeekdayTableViewCell.weekdayCellID)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        return tableView
    }()

    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(doneButtonTapped(_:)), for: .touchUpInside)
        button.tintColor = .ypWhite
        button.backgroundColor = .ypBlackDay
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.setTitle(NSLocalizedString("schedule.doneButton", comment: ""), for: .normal)
        return button
    }()

    private var selectedWeekdays: [WeekDay] = []
    
    // MARK: - Initializers

    init(selectedWeekdays: [WeekDay]) {
        self.selectedWeekdays = selectedWeekdays
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .ypWhite
        view.addSubview(typeTitle)
        view.addSubview(tableView)
        view.addSubview(doneButton)

        typeTitle.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            typeTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 13),
            typeTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            tableView.topAnchor.constraint(equalTo: typeTitle.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 75 * 7),

            doneButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 47),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    @objc private func doneButtonTapped(_ sender: UIButton){
        delegate?.didDoneTapped(selectedWeekdays)
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - ScheduleViewController

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weekdays.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WeekdayTableViewCell.weekdayCellID, for: indexPath) as? WeekdayTableViewCell else {
            return UITableViewCell()
        }

        let weekday = weekdays[indexPath.row]
        cell.weekday = weekday
        cell.weekdayLabel.text = weekday.localizedString
        cell.backgroundColor = .ypBackgroundDay
        cell.textLabel?.textColor = .ypBlackDay
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)

        cell.weekdaySwitchIsOn(selectedWeekdays.contains(weekday))
        cell.delegate = self

        if indexPath.row == 6 {
            cell.showSeparator = false
        }

        return cell
    }
}

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let cell = tableView.cellForRow(at: indexPath) as? WeekdayTableViewCell else {
            return
        }

        cell.weekdaySwitchSetOn()

        if cell.getWeekdaySwitchIsOn() {
            cell.setTintWeekdaySwitch()
        }

        switchStateChanged(for: cell.weekday, isOn: cell.getWeekdaySwitchIsOn())
    }
}

extension ScheduleViewController: WeekdayTableViewCellDelegate {
    func switchStateChanged(for weekday: WeekDay?, isOn: Bool) {
        guard let weekday else { return }

        if isOn {
            selectedWeekdays.append(weekday)
        } else {
            if let index = selectedWeekdays.firstIndex(of: weekday) {
                selectedWeekdays.remove(at: index)
            }
        }
    }
}

protocol WeekdayTableViewCellDelegate: AnyObject {
    func switchStateChanged(for weekday: WeekDay?, isOn: Bool)
}
