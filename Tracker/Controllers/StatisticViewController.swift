import UIKit

final class StatisticViewController: UIViewController {

    //MARK: - Создание UI-Элементов
    
    private lazy var statisticLabel: UILabel = {
        let label = UILabel()
        label.text = "Статистика"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 34)
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализировать пока нечего"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    private lazy var sadImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.image = UIImage(named: "Sad")
        return image
    }()
    
    //MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addViews()
        setConst()
    }
    
    //MARK: - Настройка UI-Элементов
    
    private func addViews() {
        view.addSubview(statisticLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(sadImageView)
    }
    
    private func setConst() {
        NSLayoutConstraint.activate([
            statisticLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            statisticLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 88)
        ])
        
        NSLayoutConstraint.activate([
            sadImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sadImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            sadImageView.heightAnchor.constraint(equalToConstant: 80),
            sadImageView.widthAnchor.constraint(equalToConstant: 80)
        ])
        
        NSLayoutConstraint.activate([
            descriptionLabel.centerXAnchor.constraint(equalTo: sadImageView.centerXAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 490)
        ])
    }
}
