import UIKit
import SwiftUI

// MARK: - V2 Models (Section with items property)

struct SectionV2: Hashable {
    let id: String
    let title: String
    var items: [Item]
    
    // Hashableの実装（itemsを含める）
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(items)
    }
    
    static func == (lhs: SectionV2, rhs: SectionV2) -> Bool {
        return lhs.id == rhs.id && lhs.title == rhs.title && lhs.items == rhs.items
    }
}

// MARK: - CollectionViewWrapperV2

class CollectionViewWrapperV2: UIViewController {
    
    // MARK: - Properties
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<SectionV2, Item>!
    private var itemCounter = 0
    
    // セクションデータを保持
    private var sections: [SectionV2] = []
    
    private let colors = ColorPalette.colors
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupDataSource()
        setupInitialData()
    }
    
    // MARK: - Setup Methods
    
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
        collectionView.register(SectionHeaderV2.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeaderV2")
        
        view.addSubview(collectionView)
    }
    
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<SectionV2, Item>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ItemCell",
                for: indexPath
            ) as! ItemCell
            cell.configure(with: item)
            return cell
        }
        
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let self = self,
                  kind == UICollectionView.elementKindSectionHeader else { return nil }
            
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "SectionHeaderV2",
                for: indexPath
            ) as! SectionHeaderV2
            
            let section = self.sections[indexPath.section]
            header.configure(with: section, delegate: self)
            return header
        }
    }
    
    private func setupInitialData() {
        // 初期セクションデータを作成
        sections = [
            SectionV2(
                id: "section1",
                title: "セクション1 (V2)",
                items: [
                    Item(id: "1-1", title: "アイテム1-1", color: colors[0]),
                    Item(id: "1-2", title: "アイテム1-2", color: colors[1])
                ]
            ),
            SectionV2(
                id: "section2",
                title: "セクション2 (V2)",
                items: [
                    Item(id: "2-1", title: "アイテム2-1", color: colors[2]),
                    Item(id: "2-2", title: "アイテム2-2", color: colors[3])
                ]
            ),
            SectionV2(
                id: "section3",
                title: "セクション3 (V2)",
                items: []
            )
        ]
        
        applySnapshot()
    }
    
    private func applySnapshot() {
        print("🔄 [V2] Applying snapshot...")
        var snapshot = NSDiffableDataSourceSnapshot<SectionV2, Item>()
        
        // セクションを追加
        snapshot.appendSections(sections)
        
        // 各セクションのアイテムを追加
        for section in sections {
            snapshot.appendItems(section.items, toSection: section)
        }
        
        print("📊 [V2] Snapshot state:")
        print("   Sections: \(snapshot.sectionIdentifiers.map { $0.title })")
        for section in snapshot.sectionIdentifiers {
            print("   \(section.title): \(snapshot.itemIdentifiers(inSection: section).map { $0.id })")
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - SectionHeaderDelegate

extension CollectionViewWrapperV2: SectionHeaderDelegate {
    func addItemToSection(sectionId: String) {
        print("🟢 [V2] セクションにアイテムを追加: \(sectionId)")
        
        // セクションを見つけて更新
        guard let sectionIndex = sections.firstIndex(where: { $0.id == sectionId }) else {
            return
        }
        
        // 新しいアイテムを作成
        itemCounter += 1
        let newItem = Item(
            id: "\(sectionId)_new\(itemCounter)",
            title: "NEW-\(itemCounter)",
            color: colors[itemCounter % colors.count]
        )
        
        // セクションのitemsを更新
        sections[sectionIndex].items.append(newItem)
        
        // スナップショットを再適用
        applySnapshot()
    }
    
    func removeItemFromSection(sectionId: String) {
        print("🔴 [V2] セクションからアイテムを削除: \(sectionId)")
        
        guard let sectionIndex = sections.firstIndex(where: { $0.id == sectionId }) else {
            return
        }
        
        if !sections[sectionIndex].items.isEmpty {
            sections[sectionIndex].items.removeLast()
            applySnapshot()
        }
    }
}

// MARK: - SectionHeaderV2

class SectionHeaderV2: SectionHeaderBase {
    private var section: SectionV2?
    
    func configure(with section: SectionV2, delegate: SectionHeaderDelegate) {
        self.section = section
        self.delegate = delegate
        self.sectionId = section.id
        titleLabel.text = section.title
    }
}

// MARK: - UIViewRepresentable

struct CollectionViewWrapperV2Representable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        let wrapper = CollectionViewWrapperV2()
        wrapper.title = "V2 - Items付き"
        return UINavigationController(rootViewController: wrapper)
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // Nothing to update
    }
}
