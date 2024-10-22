import UIKit

final class TrackersViewController: UIViewController {

    private var trackerCollection: UICollectionView!
    private var datePicker: UIDatePicker!
    private var searchController: UISearchController!

    private var categories: [TrackerCategory] =
//    []
    [trackersHabits, trackersEvents]
    private var completedTrackers: Set<TrackerRecord> = []

    private var filteredCategories: [TrackerCategory] = []
    
    private var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }

    private var isFiltering: Bool {
        searchController.isActive && !isSearchBarEmpty
    }

    private var currentDate: Date = Date()

    private let params = GeometricParams(cellCount: 2,
                                 leftInset: 16,
                                 rightInset: 16,
                                 cellSpacing: 9)

    //MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite

        setupLayout()

        filterContentForData()
    }
}

//MARK: - Настройка UI-Элементов

extension TrackersViewController {
    private func setupLayout() {
        setupNavigationBar()
        setupTrackerCollectionView()
    }

    private func setupTrackerCollectionView() {
        let layout = UICollectionViewFlowLayout()

        trackerCollection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        trackerCollection.delegate = self
        trackerCollection.dataSource = self

        trackerCollection.register(
            TrackerCell.self,
            forCellWithReuseIdentifier: TrackerCell.reuseIdentifier
        )

        trackerCollection.register(
            SupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SupplementaryView.supplementaryIdentifier
        )

        view.addSubview(trackerCollection)

        trackerCollection.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            trackerCollection.topAnchor.constraint(equalTo: view.topAnchor),
            trackerCollection.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            trackerCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackerCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupNavigationBar() {
        setUpDatePicker()

        if let navBar = navigationController?.navigationBar {
            let rightButton = UIBarButtonItem(customView: datePicker)
            let leftButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTracker))
            leftButton.tintColor = .ypBlackDay

            navBar.topItem?.rightBarButtonItem = rightButton
            navBar.topItem?.leftBarButtonItem = leftButton

            navBar.prefersLargeTitles = true
            navBar.topItem?.title = "Трекеры"
        }

        setUpSearchBar()
    }

    private func setUpSearchBar() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Поиск"
        searchController.searchResultsUpdater = self

        navigationItem.searchController = searchController
    }

    @objc
    private func addTracker() {
        let newVC = CreateNewTrackerViewController()
        newVC.delegate = self
        newVC.modalPresentationStyle = .popover
        present(newVC, animated: true, completion: nil)
    }

    private func setUpDatePicker() {
        datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.calendar.firstWeekday = 2
        datePicker.maximumDate = Date()
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(
            self,
            action: #selector(datePickerValueChanged(_:)),
            for: .valueChanged
        )
    }

    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: sender.date)
        guard let date = Calendar.current.date(from: components) else { return }
        currentDate = date

        filterContentForData()
    }
    
    

    private func filterContentForData() {
        let dayNumber = Calendar.current.component(.weekday, from: currentDate)
        let dayOfWeekIndex = (dayNumber + 5) % 7
        let currentWeekDate = DayOfWeek.allCases[dayOfWeekIndex]
        filteredCategories.removeAll()

        guard !categories.isEmpty else { return }

        for category in categories {
            let filteredTrackers = category.trackers.filter { tracker in
                tracker.timetable.contains(where: { $0 == currentWeekDate})
            }

            if !filteredTrackers.isEmpty {
                filteredCategories.append(TrackerCategory(title: category.title, trackers: filteredTrackers))
            }
        }

        trackerCollection.reloadData()
    }
}

//MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if isFiltering {
            if filteredCategories.isEmpty {
                collectionView.setEmptyMessage(message: "Ничего не найдено", image: "emptySearch")
            } else {
                collectionView.restore()
            }
        } else {
            filterContentForData()
            if filteredCategories.isEmpty {
                collectionView.setEmptyMessage(message: "Что будем отслеживать?", image: "emptyTracker")
            } else {
                collectionView.restore()
            }
        }
        return filteredCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCategories[section].trackers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let trackerCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.reuseIdentifier,
            for: indexPath
        ) as? TrackerCell else {
            return UICollectionViewCell()
        }

        let tracker = filteredCategories[indexPath.section].trackers[indexPath.row]

        trackerCell.prepareForReuse()

        let counter = completedTrackers.filter {
            $0.completedTrackerId == tracker.id
        }.count

        let flag = completedTrackers.filter {
            $0.completedTrackerId == tracker.id && $0.completedTrackerDate == currentDate
        }.isEmpty

        if flag {
            trackerCell.addButton.setImage(UIImage(systemName: "plus"), for: .normal)
            trackerCell.addButton.alpha = 1
        } else {
            trackerCell.addButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            trackerCell.addButton.alpha = 0.3
        }

        trackerCell.delegate = self
        trackerCell.counterLabel.text = "\(counter) дней"
        trackerCell.emojiLabel.text = tracker.emoji
        trackerCell.titleLabel.text = tracker.name
        trackerCell.rectangleView.backgroundColor = tracker.color
        trackerCell.addButton.backgroundColor = tracker.color

        return trackerCell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        case UICollectionView.elementKindSectionHeader:
            id = "footer"
        default:
            id = ""
        }

        guard let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: id,
            for: indexPath
        ) as? SupplementaryView else {
            return UICollectionReusableView()
        }

        view.titleLabel.text = filteredCategories[indexPath.section].title
        return view
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)

        return headerView.systemLayoutSizeFitting(
            CGSize(width: collectionView.frame.width, height: UIView.layoutFittingExpandedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth =  availableWidth / CGFloat(params.cellCount)

        return CGSize(width: cellWidth,
                      height: cellWidth * 0.88)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: params.leftInset, bottom: 0, right: params.rightInset)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return params.cellSpacing
    }
}

//MARK: - UISearchResultsUpdating

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text)
    }

    private func filterContentForSearchText(_ searchText: String?) {
        guard let searchText else { return }

        filteredCategories.removeAll()

        guard !categories.isEmpty else { return }

        for category in categories {
            let filteredTrackers = category.trackers.filter { tracker in
                tracker.name.lowercased().contains(searchText.lowercased())
            }

            if !filteredTrackers.isEmpty {
                filteredCategories.append(TrackerCategory(title: category.title, trackers: filteredTrackers))
            }
        }

        trackerCollection.reloadData()
    }
}

//MARK: - TrackerCellButtonDelegate

extension TrackersViewController: TrackerCellButtonDelegate {
    func didTapButtonInCell(_ cell: TrackerCell) {
        print("before \(completedTrackers)")

        if Date() >= currentDate {
            guard let indexPath = trackerCollection.indexPath(for: cell) else { return }

            let tracker = filteredCategories[indexPath.section].trackers[indexPath.row]
            let record = TrackerRecord(completedTrackerId: tracker.id, completedTrackerDate: currentDate)

            if completedTrackers.contains(record) {
                completedTrackers.remove(record)
            } else {
                completedTrackers.insert(record)
            }

            print("after \(completedTrackers)")
            trackerCollection.reloadData()
        }
    }
}

//MARK: - AddTrackerDelegate

extension TrackersViewController: CreateTrackerViewControllerDelegate {
    func didCreateNewHabit(_ tracker: Tracker) {
        let trackerCategory = TrackerCategory(title: "Новая категория", trackers: [tracker])
        categories.append(trackerCategory)
        trackerCollection.reloadData()
    }
}

extension TrackersViewController: CreateTrackerDelegate {
    func didCreateNewTracker(_ tracker: Tracker) {
        let trackerCategory = TrackerCategory(title: "Новая категория", trackers: [tracker])
        categories.append(trackerCategory)
        trackerCollection.reloadData()
        print("Добавлена новая привычка")
    }
}
