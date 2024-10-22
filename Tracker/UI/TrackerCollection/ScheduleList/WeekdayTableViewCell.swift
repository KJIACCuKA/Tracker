//
//  WeekdayTableViewCell.swift
//  Tracker
//
//  Created by Никита Козловский on 22.10.2024.
//

import UIKit

final class WeekdayTableViewCell: UITableViewCell {
    
    static let weekdayCellID = "weekdayCell"
    
    weak var delegate: WeekdayTableViewCellDelegate?

    var weekday: WeekDay?

    var weekdayLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    private let weekdaySwitch: UISwitch = {
        let weekdaySwitch = UISwitch()
        return weekdaySwitch
    }()

    private let customSeparatorView = UIView()

    var showSeparator: Bool = true {
        didSet {
            customSeparatorView.isHidden = !showSeparator
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        addSubview(weekdayLabel)
        addSubview(weekdaySwitch)

        weekdayLabel.translatesAutoresizingMaskIntoConstraints = false
        weekdaySwitch.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            weekdayLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            weekdayLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            weekdaySwitch.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            weekdaySwitch.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        setupSeparatorView()

        weekdaySwitch.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
    }

    private func setupSeparatorView() {
        contentView.addSubview(customSeparatorView)
        customSeparatorView.backgroundColor = .ypLightGay
        customSeparatorView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            customSeparatorView.heightAnchor.constraint(equalToConstant: 1),
            customSeparatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            customSeparatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            customSeparatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func switchValueChanged(_ sender: UISwitch) {
        delegate?.switchStateChanged(for: weekday, isOn: sender.isOn)
    }

    func getWeekdaySwitchIsOn() -> Bool {
        return weekdaySwitch.isOn
    }

    func weekdaySwitchIsOn(_ flag: Bool) {
        weekdaySwitch.isOn = flag
        if weekdaySwitch.isOn {
            setTintWeekdaySwitch()
        }
    }

    func setTintWeekdaySwitch() {
        weekdaySwitch.onTintColor = .ypBlue
    }

    func weekdaySwitchSetOn() {
        weekdaySwitch.setOn(!weekdaySwitch.isOn, animated: false)
    }
}
