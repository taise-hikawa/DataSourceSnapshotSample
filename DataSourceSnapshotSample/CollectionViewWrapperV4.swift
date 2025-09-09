import UIKit
import SwiftUI

// MARK: - V4 Models (Section with items property, hash and equality both exclude items)

struct SectionV4: Hashable {
    let id: String
    let title: String
    var items: [Item]
    
    // Hashableの実装（itemsを含めない）
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        // items は hash に含めない
    }
    
    static func == (lhs: SectionV4, rhs: SectionV4) -> Bool {
        // 等価性からも items を除外
        return lhs.id == rhs.id && lhs.title == rhs.title
        // items は等価性比較に含めない
    }
}

// MARK: - CollectionViewWrapperV4

class CollectionViewWrapperV4: UIViewController {
    
    // MARK: - Properties
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<SectionV4, Item>!
    private var itemCounter = 0
    
    // セクションデータを保持
    private var sections: [SectionV4] = []
    
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
        collectionView.register(SectionHeaderV4.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeaderV4")
        
        view.addSubview(collectionView)
    }
    
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<SectionV4, Item>(
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
                withReuseIdentifier: "SectionHeaderV4",
                for: indexPath
            ) as! SectionHeaderV4
            
            let section = self.sections[indexPath.section]
            header.configure(with: section, delegate: self)
            return header
        }
    }
    
    private func setupInitialData() {
        // 初期セクションデータを作成
        sections = [
            SectionV4(
                id: "section1",
                title: "セクション1 (V4)",
                items: [
                    Item(id: "1-1", title: "アイテム1-1", color: colors[0]),
                    Item(id: "1-2", title: "アイテム1-2", color: colors[1])
                ]
            ),
            SectionV4(
                id: "section2",
                title: "セクション2 (V4)",
                items: [
                    Item(id: "2-1", title: "アイテム2-1", color: colors[2]),
                    Item(id: "2-2", title: "アイテム2-2", color: colors[3])
                ]
            ),
            SectionV4(
                id: "section3",
                title: "セクション3 (V4)",
                items: []
            )
        ]
        
        applySnapshot()
    }
    
    private func applySnapshot() {
        print("🔄 [V4] Applying snapshot...")
        var snapshot = NSDiffableDataSourceSnapshot<SectionV4, Item>()
        
        // セクションを追加
        snapshot.appendSections(sections)
        
        // 各セクションのアイテムを追加
        for section in sections {
            snapshot.appendItems(section.items, toSection: section)
        }
        
        print("📊 [V4] Snapshot state:")
        print("   Sections: \(snapshot.sectionIdentifiers.map { $0.title })")
        for section in snapshot.sectionIdentifiers {
            print("   \(section.title): \(snapshot.itemIdentifiers(inSection: section).map { $0.id })")
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - SectionHeaderDelegate

extension CollectionViewWrapperV4: SectionHeaderDelegate {
    func addItemToSection(sectionId: String) {
        print("🟢 [V4] セクションにアイテムを追加: \(sectionId)")
        
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
        print("🔴 [V4] セクションからアイテムを削除: \(sectionId)")
        
        guard let sectionIndex = sections.firstIndex(where: { $0.id == sectionId }) else {
            return
        }
        
        if !sections[sectionIndex].items.isEmpty {
            sections[sectionIndex].items.removeLast()
            applySnapshot()
        }
    }
}

// MARK: - SectionHeaderV4

class SectionHeaderV4: SectionHeaderBase {
    private var section: SectionV4?
    
    func configure(with section: SectionV4, delegate: SectionHeaderDelegate) {
        self.section = section
        self.delegate = delegate
        self.sectionId = section.id
        titleLabel.text = section.title
    }
}

// MARK: - UIViewRepresentable

struct CollectionViewWrapperV4Representable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        let wrapper = CollectionViewWrapperV4()
        wrapper.title = "V4 - Hash&==除外"
        return UINavigationController(rootViewController: wrapper)
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // Nothing to update
    }
}