import UIKit

final class OnboardingViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private var typeTitle: UILabel = {
        let typeTitle = UILabel()
        typeTitle.textColor = .ypBlackAny
        typeTitle.font = .systemFont(ofSize: 32, weight: .bold)
        typeTitle.numberOfLines = 2
        typeTitle.textAlignment = .center
        return typeTitle
    }()
    
    private var image: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    // MARK: - Initializers
    
    init(image: String, text: String) {
        self.typeTitle.text = text
        self.image.image = UIImage(named: image) ?? UIImage()
        
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

//MARK: - OnboardingViewController

extension OnboardingViewController {
    
    private func setupUI() {
        [image, typeTitle].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            image.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            image.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            image.widthAnchor.constraint(equalTo: view.widthAnchor),
            image.heightAnchor.constraint(equalTo: view.heightAnchor),

            typeTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 432),
            typeTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            typeTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            typeTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
}
