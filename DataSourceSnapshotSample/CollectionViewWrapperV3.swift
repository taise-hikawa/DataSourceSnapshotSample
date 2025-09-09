import UIKit
import SwiftUI

// MARK: - V3 Models (Section with items property but custom hash excluding items)

struct SectionV3: Hashable {
    let id: String
    let title: String
    var items: [Item]
    
    // Hashableの実装（itemsを含めない）
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        // items は hash に含めない
    }
    
    static func == (lhs: SectionV3, rhs: SectionV3) -> Bool {
        // 等価性には items を含める
        return lhs.id == rhs.id && lhs.title == rhs.title && lhs.items == rhs.items
    }
}

// MARK: - CollectionViewWrapperV3

class CollectionViewWrapperV3: UIViewController {
    
    // MARK: - Properties
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<SectionV3, Item>!
    private var itemCounter = 0
    
    // セクションデータを保持
    private var sections: [SectionV3] = []
    
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
        let layout = UICollectionViewFlowLayout.createStandardLayout()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        
        collectionView.register(ItemCell.self, forCellWithReuseIdentifier: "ItemCell")
        collectionView.register(SectionHeaderV3.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeaderV3")
        
        view.addSubview(collectionView)
    }
    
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<SectionV3, Item>(
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
                withReuseIdentifier: "SectionHeaderV3",
                for: indexPath
            ) as! SectionHeaderV3
            
            let section = self.sections[indexPath.section]
            header.configure(with: section, delegate: self)
            return header
        }
    }
    
    private func setupInitialData() {
        // 初期セクションデータを作成
        sections = [
            SectionV3(
                id: "section1",
                title: "セクション1 (V3)",
                items: [
                    Item(id: "1-1", title: "アイテム1-1", color: colors[0]),
                    Item(id: "1-2", title: "アイテム1-2", color: colors[1])
                ]
            ),
            SectionV3(
                id: "section2",
                title: "セクション2 (V3)",
                items: [
                    Item(id: "2-1", title: "アイテム2-1", color: colors[2]),
                    Item(id: "2-2", title: "アイテム2-2", color: colors[3])
                ]
            ),
            SectionV3(
                id: "section3",
                title: "セクション3 (V3)",
                items: []
            )
        ]
        
        applySnapshot()
    }
    
    private func applySnapshot() {
        print("🔄 [V3] Applying snapshot...")
        var snapshot = NSDiffableDataSourceSnapshot<SectionV3, Item>()
        
        // セクションを追加
        snapshot.appendSections(sections)
        
        // 各セクションのアイテムを追加
        for section in sections {
            snapshot.appendItems(section.items, toSection: section)
        }
        
        print("📊 [V3] Snapshot state:")
        print("   Sections: \(snapshot.sectionIdentifiers.map { $0.title })")
        for section in snapshot.sectionIdentifiers {
            print("   \(section.title): \(snapshot.itemIdentifiers(inSection: section).map { $0.id })")
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - SectionHeaderDelegate

extension CollectionViewWrapperV3: SectionHeaderDelegate {
    func addItemToSection(sectionId: String) {
        print("🟢 [V3] セクションにアイテムを追加: \(sectionId)")
        
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
        print("🔴 [V3] セクションからアイテムを削除: \(sectionId)")
        
        guard let sectionIndex = sections.firstIndex(where: { $0.id == sectionId }) else {
            return
        }
        
        if !sections[sectionIndex].items.isEmpty {
            sections[sectionIndex].items.removeLast()
            applySnapshot()
        }
    }
}

// MARK: - SectionHeaderV3

class SectionHeaderV3: SectionHeaderBase {
    private var section: SectionV3?
    
    func configure(with section: SectionV3, delegate: SectionHeaderDelegate) {
        self.section = section
        self.delegate = delegate
        self.sectionId = section.id
        titleLabel.text = section.title
    }
}

// MARK: - UIViewRepresentable

struct CollectionViewWrapperV3Representable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        let wrapper = CollectionViewWrapperV3()
        wrapper.title = "V3 - Hash除外"
        return UINavigationController(rootViewController: wrapper)
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // Nothing to update
    }
}