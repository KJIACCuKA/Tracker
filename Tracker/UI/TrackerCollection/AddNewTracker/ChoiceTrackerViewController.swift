import UIKit

protocol ChoiceTrackerDelegate: AnyObject {
    func didAddTracker(_ tracker: Tracker, with categoryName: String)
}

final class ChoiceTrackerViewController: UIViewController {
    weak var delegate: ChoiceTrackerDelegate?
    
    private var habitButton: UIButton!
    private var eventButton: UIButton!
    private var typeTitle: UILabel!
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
}

extension ChoiceTrackerViewController {
    private func setupUI() {
        view.backgroundColor = .ypWhite
        
        habitButton = setupButtonUI()
        habitButton.setTitle(NSLocalizedString("choice.habitButton", comment: "Text displayed habit button title"), for: .normal)

        eventButton = setupButtonUI()
        eventButton.setTitle(NSLocalizedString("choice.eventButton", comment: "Text displayed event button title"), for: .normal)

        typeTitle = UILabel()
        typeTitle.text = NSLocalizedString("choice.title", comment: "Text displayed view title")
        typeTitle.textColor = .ypBlackDay
        typeTitle.font = .systemFont(ofSize: 16, weight: .medium)
        
        [habitButton, eventButton, typeTitle].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            typeTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 13),
            typeTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            habitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            habitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            eventButton.heightAnchor.constraint(equalToConstant: 60),
            eventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            eventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            eventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16)
        ])
    }
    
    private func setupButtonUI() -> UIButton {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        button.tintColor = .ypWhite
        button.backgroundColor = .ypBlackDay
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        
        return button
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        var cellsNumber: Int
        
        if sender == habitButton {
            cellsNumber = 2
        } else {
            cellsNumber = 1
        }
        
        let nextController = AddTrackerViewController(cellsNumber: cellsNumber)
        nextController.delegate = self
        nextController.isModalInPresentation = true
        present(nextController, animated: true)
    }
}

extension ChoiceTrackerViewController: AddTrackerDelegate {
    func didAddTracker(_ tracker: Tracker, with categoryName: String) {
        delegate?.didAddTracker(tracker, with: categoryName)
        dismiss(animated: true, completion: nil)
    }
}
