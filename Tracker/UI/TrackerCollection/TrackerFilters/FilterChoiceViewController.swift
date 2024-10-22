import UIKit

protocol FilterChoiceDelegate: AnyObject {
    func didDoneTapped(_ filter: Filter)
}

final class FilterChoiceViewController: UIViewController {
    weak var delegate: FilterChoiceDelegate?
    
    // MARK: - Private Properties

    private let filters = Filter.allCases
//    private let filters = Filter.allCasesRawValue

    private lazy var typeTitle: UILabel = {
        let typeTitle = UILabel()
        typeTitle.text = NSLocalizedString("filterChoice.title", comment: "")
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
        tableView.register(FilterChoiceViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        return tableView
    }()

    private var selectedFilter: Filter?
    
    // MARK: - Initializers

    init(selectedFilter: Filter?) {
        self.selectedFilter = selectedFilter
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

        typeTitle.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            typeTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 13),
            typeTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            tableView.topAnchor.constraint(equalTo: typeTitle.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 75 * 4)
        ])
    }
}

extension FilterChoiceViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? FilterChoiceViewCell else {
            return UITableViewCell()
        }
        
        let filter = filters[indexPath.row]
        cell.filter = filter
        cell.backgroundColor = .ypBackgroundDay
        cell.categoryLabel.text = filter.localizedString

        if filter == selectedFilter {
            cell.showCheckmark = true
        }

        if indexPath.row == filters.count - 1 {
            cell.showSeparator = false
        }

        return cell
    }
}

extension FilterChoiceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let cell = tableView.cellForRow(at: indexPath) as? FilterChoiceViewCell else {
            return
        }

        guard let filter = cell.filter else {
            return
        }

        delegate?.didDoneTapped(filter)
        dismiss(animated: true, completion: nil)
    }
}
