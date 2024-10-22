import UIKit

protocol ColorDelegate: AnyObject {
    func didColorSelected(_ color: UIColor)
}

final class ColorCollectionViewController: UIViewController {
    weak var delegate: ColorDelegate?
    var selectedColor: UIColor?

    private let colors: [UIColor] = [
        .ypSelection1, .ypSelection2, .ypSelection3, .ypSelection4, .ypSelection5, .ypSelection6,
        .ypSelection7, .ypSelection8, .ypSelection9, .ypSelection10, .ypSelection11, .ypSelection12,
        .ypSelection13, .ypSelection14, .ypSelection15, .ypSelection16, .ypSelection17,  .ypSelection18
    ]
    
    private let params: GeometricParams = GeometricParams(cellCount: 6,
                                                          leftInset: 18,
                                                          rightInset: 0,
                                                          cellSpacing: 5)
    
    let colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        layout.headerReferenceSize = .init(width: 50, height: 50)
        collectionView.isScrollEnabled = false
        
        collectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: ColorCollectionViewCell.cellID)
        collectionView.register(
            SupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "\(SupplementaryView.self)"
        )
        
        collectionView.allowsMultipleSelection = false
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        colorCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(colorCollectionView)
        NSLayoutConstraint.activate([
            colorCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            colorCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            colorCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            colorCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
    }
}

extension ColorCollectionViewController: UICollectionViewDataSource {
    func collectionView( _ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView( _ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ColorCollectionViewCell.cellID,
            for: indexPath) as? ColorCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.colorView.backgroundColor = colors[indexPath.row]

        if let selectedColor, selectedColor == colors[indexPath.row] {
            cell.layer.borderWidth = 3
            cell.layer.borderColor = colors[indexPath.row].withAlphaComponent(0.3).cgColor
            cell.layer.cornerRadius = 8
            cell.layer.masksToBounds = true
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "\(SupplementaryView.self)",
                for: indexPath) as? SupplementaryView else {
                    return UICollectionReusableView()
                }
            view.titleLabel.text = "Цвет"
            return view
        default:
            return UICollectionReusableView()
        }
    }
}

extension ColorCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth =  availableWidth / CGFloat(params.cellCount)
        
        return CGSize(width: cellWidth,
                      height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 6, left: params.leftInset, bottom: 6, right: params.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return params.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell else {
            return
        }
        
        guard let currentSelectedColor = cell.colorView.backgroundColor else {
            return
        }
        
        cell.layer.borderWidth = 3
        cell.layer.borderColor = currentSelectedColor.withAlphaComponent(0.3).cgColor
        cell.layer.cornerRadius = 8
        cell.layer.masksToBounds = true
        
        delegate?.didColorSelected(currentSelectedColor)

        guard let selectedColor else { return }
        guard let selectedIndex = colors.firstIndex(of: selectedColor) else { return }

        let indexPath = IndexPath(row: selectedIndex, section: 0)
        guard let cell = colorCollectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell else { return }
        cell.layer.borderWidth = 0

        self.selectedColor = currentSelectedColor
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell =  collectionView.cellForItem(at: indexPath)
        
        guard let cell else {
            return
        }
        
        cell.layer.borderWidth = 0
    }
}
