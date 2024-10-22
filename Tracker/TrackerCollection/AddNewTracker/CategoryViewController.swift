import UIKit

protocol CategoryDelegate: AnyObject {
}

final class CategoryViewController: UIViewController {
    weak var delegate: CategoryDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .ypSelection5
    }
}
