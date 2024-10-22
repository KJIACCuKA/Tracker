import UIKit

final class TrackersViewController: UIViewController {
    private let viewModel = TrackersViewModal()
    private var trackerRecordStore = TrackerRecordStore()
    private let analyticsService = AnalyticsService()

    private var trackerCollection: UICollectionView!
    private var datePicker: UIDatePicker!
    private var searchController: UISearchController!
    private var filtersButton: UIButton!

    private var filteredCategories: [TrackerCategory] = []
    private var pinnedCategory: TrackerCategory = TrackerCategory(title: "Закрепленные", trackers: [])
    private var completedTrackers: Set<TrackerRecord> = []
    private var selectedFilter: Filter = .all

    private var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }

    private var isFiltering: Bool {
        searchController.isActive && !isSearchBarEmpty
    }

    private var currentDate: Date = Date().startOfDay

    private let params = GeometricParams(cellCount: 2,
                                         leftInset: 16,
                                         rightInset: 16,
                                         cellSpacing: 9)
    
    // MARK: - View Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite

        viewModel.categoriesBinding = { [weak self] categories in
            self?.filterContentForData(with: categories)
        }

        completedTrackers = trackerRecordStore.trackerRecords

        setupLayout()

        filterContentForData(with: viewModel.getCategories())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analyticsService.report(event: "open", params: ["screen": "Main"])
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analyticsService.report(event: "close", params: ["screen": "Main"])
    }
}

extension TrackersViewController {
    private func setupLayout() {
        setupNavigationBar()
        setupTrackerCollectionView()
        setupFiltersButton()
    }

    private func setupFiltersButton() {
        filtersButton = UIButton(type: .system)
        filtersButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        filtersButton.setTitle(NSLocalizedString("trakers.filters", comment: ""), for: .normal)
        filtersButton.addTarget(self, action: #selector(filtersButtonTapped(_:)), for: .touchUpInside)
        filtersButton.tintColor = .ypWhiteAny
        filtersButton.backgroundColor = .ypBlue
        filtersButton.layer.cornerRadius = 16
        filtersButton.layer.masksToBounds = true

        view.addSubview(filtersButton)
        filtersButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            filtersButton.heightAnchor.constraint(equalToConstant: 50),
            filtersButton.widthAnchor.constraint(equalToConstant: 114),
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    private func setupTrackerCollectionView() {
        let layout = UICollectionViewFlowLayout()

        trackerCollection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        trackerCollection.delegate = self
        trackerCollection.dataSource = self
        trackerCollection.backgroundColor = .ypWhite
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
            navBar.topItem?.title = NSLocalizedString("trakers.title", comment: "Text displayed navigation bar title")
        }

        setUpSearchBar()
    }

    private func setUpSearchBar() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Поиск"
        searchController.searchResultsUpdater = self

        navigationItem.searchController = searchController
    }

    private func setUpDatePicker() {
        datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = .current
        datePicker.addTarget(
            self,
            action: #selector(datePickerValueChanged(_:)),
            for: .valueChanged
        )
    }

    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date.startOfDay
        filterContentForData(with: viewModel.getCategories())
    }

    @objc private func filtersButtonTapped(_ sender: UIButton) {
        analyticsService.report(event: "click", params: ["screen": "Main", "item": "filter"])

        let nextController = FilterChoiceViewController(selectedFilter: selectedFilter)
        nextController.delegate = self
        nextController.isModalInPresentation = true
        present(nextController, animated: true)
    }

    @objc private func addTracker() {
        analyticsService.report(event: "click", params: ["screen": "Main", "item": "add_track"])

        let addTrackerViewController = ChoiceTrackerViewController()
        addTrackerViewController.delegate = self
        addTrackerViewController.modalPresentationStyle = .automatic
        present(addTrackerViewController, animated: true, completion: nil)
    }
}

extension TrackersViewController {
    private func filterContentForData(with categories: [TrackerCategory]) {
        let dayNumber = Calendar.current.component(.weekday, from: currentDate)
        let currentWeekDate = WeekDay.allCases[dayNumber - 1]
        filteredCategories.removeAll()

        guard !categories.isEmpty else { return }

        for category in categories {
            let filteredTrackers = category.trackers.filter { tracker in
                tracker.isPinned == false && tracker.timetable.contains(where: { $0 == currentWeekDate}) 
            }

            if !filteredTrackers.isEmpty {
                filteredCategories.append(TrackerCategory(title: category.title, trackers: filteredTrackers))
            }
        }

        if selectedFilter == .completed {
            let completedTrackerCurrentDay = completedTrackers.filter { $0.completedTrackerDate == currentDate }
            let categories = filteredCategories
            let completedTrackerIds = completedTrackerCurrentDay.map { $0.completedTrackerId }
            var matchingCategories: [TrackerCategory] = []

            for category in categories {
                let matchingTrackers = category.trackers.filter { tracker in
                    completedTrackerIds.contains(tracker.id)
                }

                if !matchingTrackers.isEmpty {
                    matchingCategories.append(TrackerCategory(title: category.title, trackers: matchingTrackers))
                }
            }

            filteredCategories = matchingCategories
        }

        if selectedFilter == .uncompleted {
            let completedTrackerCurrentDay = completedTrackers.filter { $0.completedTrackerDate == currentDate }
            let completedTrackerIds = completedTrackerCurrentDay.map { $0.completedTrackerId }
            var matchingCategories: [TrackerCategory] = []

            for category in filteredCategories {
                    let uncompletedTrackers = category.trackers.filter { !completedTrackerIds.contains($0.id) }

                    if !uncompletedTrackers.isEmpty {
                        matchingCategories.append(TrackerCategory(title: category.title, trackers: uncompletedTrackers))
                    }
                }
            filteredCategories = matchingCategories
        }

        if !pinnedCategory.trackers.isEmpty {
            filteredCategories = [pinnedCategory] + filteredCategories
        }

        trackerCollection.reloadData()
    }

    private func filterContentForCompletion(with categories: [TrackerCategory]) {
        trackerCollection.reloadData()
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if isFiltering {
            if filteredCategories.isEmpty {
                collectionView.setEmptyMessage(message: NSLocalizedString("emptySearch.title", comment: ""), image: "emptySearch")
                if selectedFilter == .all {
                    filtersButton.isHidden = true
                }
            } else {
                collectionView.restore()
                filtersButton.isHidden = false
            }
        } else {
            filterContentForData(with: viewModel.getCategories())

            if filteredCategories.isEmpty {
                if selectedFilter != .all {
                    collectionView.setEmptyMessage(message: NSLocalizedString("emptySearch.title", comment: ""), image: "emptySearch")
                    filtersButton.isHidden = false
                } else {
                    collectionView.setEmptyMessage(message: NSLocalizedString("emptyState.title", comment: ""), image: "emptyTracker")
                    filtersButton.isHidden = true
                }
            } else {
                filtersButton.isHidden = false
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
            let trackerDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: $0.completedTrackerDate)
            let currentDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: currentDate)

            return $0.completedTrackerId == tracker.id && trackerDateComponents == currentDateComponents
        }.isEmpty

        if flag {
            trackerCell.addButton.setImage(UIImage(systemName: "plus"), for: .normal)
            trackerCell.addButton.alpha = 1
        } else {
            trackerCell.addButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            trackerCell.addButton.alpha = 0.3
        }

        trackerCell.delegate = self

        let daysString = String.localizedStringWithFormat(
            NSLocalizedString("numberOfDays", comment: "Days of tracking a task"),
            counter
        )

        trackerCell.counterLabel.text = daysString
        trackerCell.viewModel = TrackerCellViewModel(emojiLabel: tracker.emoji, titleLabel: tracker.name, viewColor: tracker.color, isPinned: tracker.isPinned)
        trackerCell.isPinned = tracker.isPinned
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

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text)
    }

    private func filterContentForSearchText(_ searchText: String?) {
        guard let searchText else { return }

        filteredCategories.removeAll()

        let categories = viewModel.getCategories()
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

extension TrackersViewController: TrackerCellButtonDelegate {
    func didTapButtonInCell(_ cell: TrackerCell) {
        analyticsService.report(event: "click", params: ["screen": "Main", "item": "track"])

        if Date().startOfDay >= currentDate {
            guard let indexPath = trackerCollection.indexPath(for: cell) else { return }

            let tracker = filteredCategories[indexPath.section].trackers[indexPath.row]
            let record = TrackerRecord(completedTrackerId: tracker.id, completedTrackerDate: currentDate)

            let flag = completedTrackers.filter {
                return $0.completedTrackerId == tracker.id && $0.completedTrackerDate == currentDate
            }.isEmpty

            if flag {
                completedTrackers.insert(record)
                try? trackerRecordStore.addNewTrackerRecord(record)
            } else {
                completedTrackers.remove(record)
                try? trackerRecordStore.deleteTrackerRecord(record)
            }
        }

        trackerCollection.reloadData()
    }

    func didTapPinCell(_ cell: TrackerCell) {
        guard let indexPath = trackerCollection.indexPath(for: cell) else { return }
        var tracker = filteredCategories[indexPath.section].trackers[indexPath.row]

        tracker.isPinned = true
        viewModel.changeTrackerIsPinned(tracker)
        pinnedCategory.trackers.append(tracker)
        filterContentForData(with: viewModel.getCategories())
    }

    func didTapUnPinCell(_ cell: TrackerCell) {
        guard let indexPath = trackerCollection.indexPath(for: cell) else { return }
        var tracker = filteredCategories[indexPath.section].trackers[indexPath.row]

        tracker.isPinned = false
        viewModel.changeTrackerIsPinned(tracker)

        let filteredTrackers = pinnedCategory.trackers.filter { $0.id != tracker.id }
        pinnedCategory.trackers = filteredTrackers
        filterContentForData(with: viewModel.getCategories())
    }

    func didTapEditCell(_ cell: TrackerCell) {
        analyticsService.report(event: "click", params: ["screen": "Main", "item": "edit"])

        guard let indexPath =  trackerCollection.indexPath(for: cell) else { return }
        let category = filteredCategories[indexPath.section]
        let tracker = category.trackers[indexPath.row]
        let editTrackerViewController = EditTrackerViewController(tracker: tracker, categoryName: category.title)
        editTrackerViewController.delegate = self
        editTrackerViewController.isModalInPresentation = true
        present(editTrackerViewController, animated: true, completion: nil)
    }

    func didTapDeleteCell(_ cell: TrackerCell) {
        analyticsService.report(event: "click", params: ["screen": "Main", "item": "delete"])

        let alertController = UIAlertController(title: nil, message: NSLocalizedString("trackersAlert.message", comment: ""), preferredStyle: .actionSheet)

        let deleteAction = UIAlertAction(title: NSLocalizedString("trackersActionDelete.title", comment: ""), style: .destructive) { [weak self] _ in

            guard let self else { return }
            guard let indexPath =  trackerCollection.indexPath(for: cell) else { return }
            let tracker = filteredCategories[indexPath.section].trackers[indexPath.row]
            viewModel.deleteTrackerFromTrackerCategory(tracker)
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("trackersActionDiscard.title", comment: ""), style: .cancel, handler: nil)

        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
}

extension TrackersViewController: ChoiceTrackerDelegate {
    func didAddTracker(_ tracker: Tracker, with categoryName: String) {
        viewModel.addNewTrackerToTrackerCategory(tracker, with: categoryName)

        dismiss(animated: true, completion: nil)
    }
}

extension TrackersViewController: FilterChoiceDelegate {
    func didDoneTapped(_ filter: Filter) {
        selectedFilter = filter

        if selectedFilter == .all {
            let components = Calendar.current.dateComponents([.year, .month, .day], from: datePicker.date)
            guard let date = Calendar.current.date(from: components) else { return }
            currentDate = date
        }

        if selectedFilter == .today {
            currentDate = Date().startOfDay
            datePicker.date = currentDate
        }

        filterContentForData(with: viewModel.getCategories())
    }
}

extension TrackersViewController: EditTrackerDelegate {
    func didEditTracker(_ tracker: Tracker, with categoryName: String) {
        viewModel.editTrackerAtTrackerCategory(tracker)
        viewModel.changeTrackerCategory(with: categoryName, for: tracker)
    }
}
