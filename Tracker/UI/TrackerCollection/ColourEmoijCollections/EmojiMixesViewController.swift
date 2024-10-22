import UIKit

protocol EmojiMixesDelegate: AnyObject {
    func didEmojiSelected(_ emoji: String)
}

final class EmojiMixesViewController: UIViewController {
    var selectedEmoji: String?
    
    weak var delegate: EmojiMixesDelegate?
    
    private let emojies = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸",  "🏝",  "😪"
    ]
    
    private let params: GeometricParams = GeometricParams(cellCount: 6,
                                                          leftInset: 18,
                                                          rightInset: 0,
                                                          cellSpacing: 5)

    private let emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        layout.headerReferenceSize = .init(width: 50, height: 50)
        collectionView.isScrollEnabled = false
        
        collectionView.register(EmojiMixCollectionViewCell.self, forCellWithReuseIdentifier: EmojiMixCollectionViewCell.emojiCellID)
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
        emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emojiCollectionView)
        NSLayoutConstraint.activate([
            emojiCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            emojiCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emojiCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emojiCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
    }
}

extension EmojiMixesViewController: UICollectionViewDataSource {
    func collectionView( _ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojies.count
    }
    
    func collectionView( _ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiMixCollectionViewCell.emojiCellID, for: indexPath) as? EmojiMixCollectionViewCell else { return UICollectionViewCell() }

        cell.updateLabel(title: emojies[indexPath.row])

        if selectedEmoji == emojies[indexPath.row] {
            cell.backgroundColor = .ypLightGay
            cell.layer.cornerRadius = 16
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
            view.titleLabel.text = "Emoji"
            return view
        default:
            return UICollectionReusableView()
        }
    }
}

extension EmojiMixesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth =  availableWidth / CGFloat(params.cellCount)
        
        return CGSize(width: cellWidth,
                      height: cellWidth)
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? EmojiMixCollectionViewCell else {
            return
        }

        cell.backgroundColor = .ypLightGay
        cell.layer.cornerRadius = 16
        cell.layer.masksToBounds = true
        guard let emoji = cell.getLabelText() else {
            return
        }

        delegate?.didEmojiSelected(emoji)

        guard let selectedEmoji else { return }
        guard let selectedIndex = emojies.firstIndex(of: selectedEmoji) else { return }

        let indexPath = IndexPath(row: selectedIndex, section: 0)
        guard let cell = emojiCollectionView.cellForItem(at: indexPath) as? EmojiMixCollectionViewCell else { return }
        cell.backgroundColor = nil

        self.selectedEmoji = emoji
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell =  collectionView.cellForItem(at: indexPath) as? EmojiMixCollectionViewCell
        
        guard let cell else {
            return
        }
        
        cell.backgroundColor = nil
    }
}
