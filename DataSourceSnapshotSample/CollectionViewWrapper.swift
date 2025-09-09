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
    private let colors = ColorPalette.colors
    
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
        let layout = UICollectionViewFlowLayout.createStandardLayout()
        
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

// MARK: - SectionHeader

class SectionHeader: SectionHeaderBase {
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
        wrapper.title = "V1 - 通常"
        return UINavigationController(rootViewController: wrapper)
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
    }
}