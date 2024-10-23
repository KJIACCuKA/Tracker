import CoreData
import UIKit

enum TrackerCategoryStoreError: Error {
    case decodingErrorInvalidTitle
    case decodingErrorInvalidTrackers
    case addingNewTracker
    case searchingTracker
    case removingTracker
}

protocol TrackerCategoryStoreDelegate: AnyObject {
    func storeCategory()
}

final class TrackerCategoryStore: NSObject {
    var categories: [TrackerCategory] {
        guard
            let objects = self.fetchedResultsController.fetchedObjects,
            let categories = try? objects.map({ try self.trackerCategory(from: $0) })
        else { return [] }
        return categories
    }

    weak var delegate: TrackerCategoryStoreDelegate?

    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>
    private let context: NSManagedObjectContext
    private var trackerStore = TrackerStore()

    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            self.init()
            return
        }

        let context = appDelegate.context
        self.init(context: context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context

        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCategoryCoreData.title, ascending: true)
        ]

        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        self.fetchedResultsController = controller
        super.init()
        controller.delegate = self

        try? controller.performFetch()
    }

    func addNewTrackerCategory(_ trackerCategoryName: String) throws {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)

        trackerCategoryCoreData.title = trackerCategoryName

        do {
            try context.save()
        } catch {
            context.rollback()
        }
    }

    func addNew(_ tracker: Tracker, to categoryTitle: String) throws {
        guard let trackerCategoryCoreData = predicateFetchByTitle(with: categoryTitle) else {
            try addNewTrackerCategory(categoryTitle)
            try addNew(tracker, to: categoryTitle)
            return
        }

        do {
            try trackerStore.addNewTracker(tracker, with: trackerCategoryCoreData)
        } catch {
            throw TrackerCategoryStoreError.addingNewTracker
        }
    }

    func deleteTrackerFromTrackerCategory(_ tracker: Tracker) throws {
        do {
            try trackerStore.deleteTracker(tracker)
        } catch {
            throw TrackerCategoryStoreError.addingNewTracker
        }
    }

    func editTrackerAtTrackerCategory(_ tracker: Tracker) throws {
        do {
            try trackerStore.editTracker(tracker)
        } catch {
            throw TrackerCategoryStoreError.addingNewTracker
        }
    }

    func changeTrackerCategory(with categoryTitle: String, for tracker: Tracker) throws {
        guard let trackerCoreData = trackerStore.predicateFetchById(tracker.id) else {
            throw TrackerStoreError.decodingErrorInvalidId
        }

        let title = trackerCoreData.category?.title

        if let title, title != categoryTitle {
            let trackerCategoryCoreData = predicateFetchByTitle(with: categoryTitle)

            if trackerCategoryCoreData == nil {
                try addNewTrackerCategory(categoryTitle)
                let trackerCategoryCoreData = predicateFetchByTitle(with: categoryTitle)

                trackerCoreData.category = trackerCategoryCoreData
            } else {
                trackerCoreData.category = trackerCategoryCoreData
            }
        }
    }

    func fetchTrackerCategories() throws -> [TrackerCategory] {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        let trackerCategoryFromCoreData = try context.fetch(fetchRequest)
        return try trackerCategoryFromCoreData.map { try self.trackerCategory(from: $0) }
    }

    func predicateFetchByTitle(with title: String) -> TrackerCategoryCoreData? {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.title), title)
        request.fetchLimit = 1

        do {
            let results = try context.fetch(request)
            return results.first
        } catch {
            return nil
        }
    }

    func fetchTrackersInCategory(_ category: TrackerCategoryCoreData) throws -> [TrackerCoreData] {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "category == %@", category)

        do {
            let trackers = try context.fetch(fetchRequest)
            return trackers
        } catch {
            throw error
        }
    }

    func updateIsPinFor(_ tracker: Tracker) {
        do {
            try trackerStore.updateIsPinTracker(tracker)
        } catch {
            return
        }
    }

    private func trackerCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let title = trackerCategoryCoreData.title else {
            throw TrackerCategoryStoreError.decodingErrorInvalidTitle
        }

        var trackers: [Tracker] = []
        let trackersCoreData = try? fetchTrackersInCategory(trackerCategoryCoreData)
        if let trackersCoreData {
            trackers = try trackersCoreData.map { try TrackerStore().tracker(from: $0) }
        }

        return TrackerCategory(title: title, trackers: trackers)
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeCategory()
    }
}