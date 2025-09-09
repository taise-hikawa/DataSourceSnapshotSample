import UIKit

// MARK: - Common Layout

extension UICollectionViewFlowLayout {
    static func createStandardLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.headerReferenceSize = CGSize(width: 0, height: 50)
        return layout
    }
}

// MARK: - Common Colors

struct ColorPalette {
    static let colors: [UIColor] = [
        .systemRed, .systemBlue, .systemGreen, .systemYellow,
        .systemPurple, .systemOrange, .systemPink, .systemTeal
    ]
}

// MARK: - ItemCell

class ItemCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
        
        titleLabel.textAlignment = .center
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -8)
        ])
    }
    
    func configure(with item: Item) {
        titleLabel.text = item.title
        contentView.backgroundColor = item.color
        print("📦 セル設定: \(item.title)")
    }
}

// MARK: - Common Header Protocol

protocol SectionHeaderDelegate: AnyObject {
    func addItemToSection(sectionId: String)
    func removeItemFromSection(sectionId: String)
}

// MARK: - Common Header Base

class SectionHeaderBase: UICollectionReusableView {
    let titleLabel = UILabel()
    let addButton = UIButton(type: .system)
    let removeButton = UIButton(type: .system)
    var sectionId: String = ""
    weak var delegate: SectionHeaderDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .secondarySystemGroupedBackground
        layer.cornerRadius = 8
        
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textColor = .label
        
        addButton.setTitle("➕", for: .normal)
        addButton.titleLabel?.font = .systemFont(ofSize: 20)
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        removeButton.setTitle("➖", for: .normal)
        removeButton.titleLabel?.font = .systemFont(ofSize: 20)
        removeButton.addTarget(self, action: #selector(removeButtonTapped), for: .touchUpInside)
        
        [titleLabel, addButton, removeButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            removeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            removeButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            removeButton.widthAnchor.constraint(equalToConstant: 44),
            removeButton.heightAnchor.constraint(equalToConstant: 44),
            
            addButton.trailingAnchor.constraint(equalTo: removeButton.leadingAnchor, constant: -8),
            addButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 44),
            addButton.heightAnchor.constraint(equalToConstant: 44),
            
            heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
    }
    
    @objc private func addButtonTapped() {
        print("🟢 追加ボタンタップ: \(sectionId)")
        delegate?.addItemToSection(sectionId: sectionId)
    }
    
    @objc private func removeButtonTapped() {
        print("🔴 削除ボタンタップ: \(sectionId)")
        delegate?.removeItemFromSection(sectionId: sectionId)
    }
}