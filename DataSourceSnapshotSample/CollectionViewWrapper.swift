import UIKit
import SwiftUI

struct Item: Hashable {
    let id: String
    let title: String
    let color: UIColor
    let createdAt: Date
    
    init(id: String, title: String, color: UIColor) {
        self.id = id
        self.title = title
        self.color = color
        self.createdAt = Date()
    }
}

struct Section: Hashable {
    let id: String
    let title: String
}

class CollectionViewWrapper: UIViewController {
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    private var itemCounter = 0
    private let colors: [UIColor] = [.systemBlue, .systemGreen, .systemRed, .systemOrange, .systemPurple, .systemYellow, .systemPink, .systemTeal, .systemIndigo, .systemBrown]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupDataSource()
        setupNavigationBar()
        loadData()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "DiffableDataSource Sample"
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.headerReferenceSize = CGSize(width: 0, height: 50)
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        
        collectionView.register(ItemCell.self, forCellWithReuseIdentifier: "ItemCell")
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader")
        
        view.addSubview(collectionView)
    }
    
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCell
            cell.configure(with: item)
            return cell
        }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            if kind == UICollectionView.elementKindSectionHeader {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as! SectionHeader
                
                let snapshot = self.dataSource.snapshot()
                let section = snapshot.sectionIdentifiers[indexPath.section]
                header.configure(with: section.title, sectionId: section.id, delegate: self)
                return header
            }
            return nil
        }
    }
    
    private func loadData() {
        let section1 = Section(id: "section1", title: "セクション 1")
        let section2 = Section(id: "section2", title: "セクション 2") 
        let section3 = Section(id: "section3", title: "セクション 3")
        
        var items1: [Item] = []
        for i in 1...8 {
            items1.append(Item(id: "s1_item\(i)", title: "S1-\(i)", color: colors[i % colors.count]))
            itemCounter += 1
        }
        
        var items2: [Item] = []
        for i in 1...12 {
            items2.append(Item(id: "s2_item\(i)", title: "S2-\(i)", color: colors[i % colors.count]))
            itemCounter += 1
        }
        
        var items3: [Item] = []
        for i in 1...6 {
            items3.append(Item(id: "s3_item\(i)", title: "S3-\(i)", color: colors[i % colors.count]))
            itemCounter += 1
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([section1, section2, section3])
        snapshot.appendItems(items1, toSection: section1)
        snapshot.appendItems(items2, toSection: section2)
        snapshot.appendItems(items3, toSection: section3)
        
        print("📸 初期スナップショット:")
        print("  セクション数: \(snapshot.numberOfSections)")
        print("  総アイテム数: \(snapshot.numberOfItems)")
        
        for section in snapshot.sectionIdentifiers {
            let itemsInSection = snapshot.itemIdentifiers(inSection: section)
            print("  \(section.title): \(itemsInSection.count)個のアイテム")
        }
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    
    func addItemToSection(sectionId: String) {
        var currentSnapshot = dataSource.snapshot()
        
        guard let targetSection = currentSnapshot.sectionIdentifiers.first(where: { $0.id == sectionId }) else {
            print("❌ セクション \(sectionId) が見つかりません")
            return
        }
        
        itemCounter += 1
        let newItem = Item(
            id: "\(sectionId)_new\(itemCounter)",
            title: "NEW-\(itemCounter)",
            color: colors[itemCounter % colors.count]
        )
        
        let itemsInSection = currentSnapshot.itemIdentifiers(inSection: targetSection)
        if let lastItem = itemsInSection.last {
            currentSnapshot.insertItems([newItem], afterItem: lastItem)
        } else {
            currentSnapshot.appendItems([newItem], toSection: targetSection)
        }
        
        print("➕ \(targetSection.title)にアイテム追加: \(newItem.title)")
        logSnapshot(currentSnapshot)
        
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
    func removeItemFromSection(sectionId: String) {
        var currentSnapshot = dataSource.snapshot()
        
        guard let targetSection = currentSnapshot.sectionIdentifiers.first(where: { $0.id == sectionId }) else {
            print("❌ セクション \(sectionId) が見つかりません")
            return
        }
        
        let itemsInSection = currentSnapshot.itemIdentifiers(inSection: targetSection)
        guard let lastItem = itemsInSection.last else {
            print("❌ \(targetSection.title)にアイテムがありません")
            return
        }
        
        currentSnapshot.deleteItems([lastItem])
        
        print("➖ \(targetSection.title)からアイテム削除: \(lastItem.title)")
        logSnapshot(currentSnapshot)
        
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
    private func logSnapshot(_ snapshot: NSDiffableDataSourceSnapshot<Section, Item>) {
        print("📸 スナップショット状態:")
        print("  セクション数: \(snapshot.numberOfSections)")
        print("  総アイテム数: \(snapshot.numberOfItems)")
        
        for section in snapshot.sectionIdentifiers {
            let itemsInSection = snapshot.itemIdentifiers(inSection: section)
            print("  \(section.title): \(itemsInSection.count)個のアイテム")
        }
        print("")
    }
}

extension CollectionViewWrapper: SectionHeaderDelegate {
    
}

protocol SectionHeaderDelegate: AnyObject {
    func addItemToSection(sectionId: String)
    func removeItemFromSection(sectionId: String)
}

class ItemCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .white
        
        contentView.addSubview(titleLabel)
        contentView.layer.cornerRadius = 8
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -4)
        ])
    }
    
    func configure(with item: Item) {
        titleLabel.text = item.title
        contentView.backgroundColor = item.color
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        print("🎨 セル描画: \(item.title) (作成時刻: \(timeFormatter.string(from: item.createdAt)))")
    }
}

class SectionHeader: UICollectionReusableView {
    private let titleLabel = UILabel()
    private let addButton = UIButton(type: .system)
    private let removeButton = UIButton(type: .system)
    private let stackView = UIStackView()
    
    private var sectionId: String = ""
    private weak var delegate: SectionHeaderDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHeader()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupHeader() {
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .label
        
        addButton.setTitle("➕", for: .normal)
        addButton.titleLabel?.font = .systemFont(ofSize: 20)
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        removeButton.setTitle("➖", for: .normal)
        removeButton.titleLabel?.font = .systemFont(ofSize: 20)
        removeButton.addTarget(self, action: #selector(removeButtonTapped), for: .touchUpInside)
        
        let buttonStackView = UIStackView(arrangedSubviews: [addButton, removeButton])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 12
        buttonStackView.distribution = .fillEqually
        
        addSubview(titleLabel)
        addSubview(buttonStackView)
        backgroundColor = .systemGray6
        layer.cornerRadius = 8
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            buttonStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            buttonStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            buttonStackView.widthAnchor.constraint(equalToConstant: 80),
            buttonStackView.heightAnchor.constraint(equalToConstant: 32),
            
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: buttonStackView.leadingAnchor, constant: -16)
        ])
        
        addButton.layer.cornerRadius = 6
        removeButton.layer.cornerRadius = 6
        addButton.backgroundColor = .systemGreen.withAlphaComponent(0.2)
        removeButton.backgroundColor = .systemRed.withAlphaComponent(0.2)
    }
    
    @objc private func addButtonTapped() {
        print("🟢 追加ボタンタップ: \(sectionId)")
        delegate?.addItemToSection(sectionId: sectionId)
    }
    
    @objc private func removeButtonTapped() {
        print("🔴 削除ボタンタップ: \(sectionId)")
        delegate?.removeItemFromSection(sectionId: sectionId)
    }
    
    func configure(with title: String, sectionId: String, delegate: SectionHeaderDelegate) {
        titleLabel.text = title
        self.sectionId = sectionId
        self.delegate = delegate
        print("🏷️ セクションヘッダー設定: \(title) (\(sectionId))")
    }
}

struct CollectionViewWrapperRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        let wrapper = CollectionViewWrapper()
        return UINavigationController(rootViewController: wrapper)
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
    }
}