import UIKit

protocol CategoryDelegate: AnyObject {
    func didDoneTapped(_ category: String)
}

final class CategoryViewController: UIViewController {
    
    // MARK: - Public Properties
    
    weak var delegate: CategoryDelegate?
    
    // MARK: - Private Properties

    private var viewModel: CategoryNamesViewModel

    private lazy var typeTitle: UILabel = {
        let typeTitle = UILabel()
        typeTitle.text = NSLocalizedString("category.title", comment: "")
        typeTitle.textColor = .ypBlackDay
        typeTitle.font = .systemFont(ofSize: 16, weight: .medium)
        return typeTitle
    }()

    private lazy var tableViewHeightConstraint: NSLayoutConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = true
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.register(CategoryNameTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.allowsSelection = true
        return tableView
    }()

    private lazy var addCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(addButtonTapped(_:)), for: .touchUpInside)
        button.tintColor = .ypWhite
        button.backgroundColor = .ypBlackDay
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.setTitle(NSLocalizedString("category.addCategoryButton", comment: ""), for: .normal)
        return button
    }()

    private lazy var imageStub: UIImageView = {
        let imageStub = UIImageView()
        imageStub.image = UIImage(named: "emptyTracker") ?? UIImage()
        return imageStub
    }()

    private lazy var labelStub: UILabel = {
        let labelStub = UILabel()
        labelStub.text = NSLocalizedString("category.emptyLabel", comment: "")
        labelStub.font = .systemFont(ofSize: 12, weight: .medium)
        labelStub.textColor = .ypBlackDay
        labelStub.numberOfLines = 2
        labelStub.textAlignment = .center
        return labelStub
    }()
    
    // MARK: - Initializers

    init(viewModel: CategoryNamesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        viewModel.namesBinding = { [weak self] _ in
            guard let self = self else { return }

            tableViewHeightConstraint.constant = CGFloat(75 * viewModel.names.count)
            self.tableView.reloadData()
        }
    }
}

//MARK: - CategoryViewController

extension CategoryViewController {
    private func setupUI() {
        view.backgroundColor = .ypWhite
        view.addSubview(typeTitle)
        view.addSubview(imageStub)
        view.addSubview(labelStub)
        view.addSubview(tableView)
        view.addSubview(addCategoryButton)

        if viewModel.names.count != 0 {
            imageStub.isHidden = true
            labelStub.isHidden = true
        }

        tableViewHeightConstraint.constant = CGFloat(75 * viewModel.names.count)
        tableViewHeightConstraint.isActive = true

        typeTitle.translatesAutoresizingMaskIntoConstraints = false
        addCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        imageStub.translatesAutoresizingMaskIntoConstraints = false
        labelStub.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageStub.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageStub.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            labelStub.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            labelStub.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            labelStub.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            labelStub.topAnchor.constraint(equalTo: imageStub.bottomAnchor, constant: 8),

            typeTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
            typeTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            tableView.topAnchor.constraint(equalTo: typeTitle.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    @objc private func addButtonTapped(_ sender: UIButton){
        let nextController = AddNewCategoryViewController()
        nextController.delegate = self
        present(nextController, animated: true)
    }
}

extension CategoryViewController: AddNewCategoryDelegate {
    func didAddNewCategory(_ category: String) {
        viewModel.addNewTrackerCategory(category)
        imageStub.isHidden = true
        labelStub.isHidden = true
    }
}

extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.names.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CategoryNameTableViewCell else {
            return UITableViewCell()
        }

        cell.viewModel = viewModel.names[indexPath.row]

        guard let viewModelCell = cell.viewModel else {
            return UITableViewCell()
        }

        if viewModel.getSelectedCategory().elementsEqual(viewModelCell.getName()) {
            cell.showCheckmark = true
        }

        if indexPath.row == viewModel.names.count - 1 {
            cell.showSeparator = false
        }

        return cell
    }
}

extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let cell = tableView.cellForRow(at: indexPath) as? CategoryNameTableViewCell else {
            return
        }

        guard let viewModel = cell.viewModel else {
            return
        }

        delegate?.didDoneTapped(viewModel.getName())
        dismiss(animated: true, completion: nil)
    }
}
