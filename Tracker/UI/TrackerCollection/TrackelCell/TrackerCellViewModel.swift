import UIKit

final class TrackerCellViewModel {
    
    private let emojiLabel: String
    private let titleLabel: String
    private let viewColor: UIColor
    private let isPinned: Bool

    init(emojiLabel: String, titleLabel: String, viewColor: UIColor, isPinned: Bool) {
        self.emojiLabel = emojiLabel
        self.titleLabel = titleLabel
        self.viewColor = viewColor
        self.isPinned = isPinned
    }

    func getEmojiLabel() -> String {
        return emojiLabel
    }

    func getTitleLabel() -> String {
        return titleLabel
    }

    func getViewColor() -> UIColor {
        return viewColor
    }

    func getIsPinned() -> Bool {
        return isPinned
    }
}
