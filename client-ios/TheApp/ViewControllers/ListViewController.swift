import UIKit

protocol ListViewControllerDelegate: AnyObject {
    func listViewControllerDelegate<T>(_: ListViewController<T>, didSelectRow data: T)
    func listViewControllerDelegateDidRefresh<T>(_: ListViewController<T>)
}

class ListViewController<T: ListViewPresentable & Hashable>: UIViewController, UICollectionViewDelegate {
    
    private lazy var collectionView = makeCollectionView()
    private lazy var dataSource = makeDataSource()
    private lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return rc
    }()
    
    private var data: [T]
    private let supportsMultipleSelection: Bool
    private let supportsRefresh: Bool
    
    weak var delegate: ListViewControllerDelegate?
    
    init(data: [T], supportsMultipleSelection: Bool = false, supportsRefresh: Bool = false) {
        self.data = data
        self.supportsMultipleSelection = supportsMultipleSelection
        self.supportsRefresh = supportsRefresh
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpConstraints()
        updateList()
    }
    
    private func setUpView() {
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        if supportsRefresh {
            collectionView.addSubview(refreshControl)
        }
        view.addSubview(collectionView)
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    public func triggerUpdate(with newData: [T]) {
        DispatchQueue.main.async {
            self.data = newData
            self.updateList()
            self.refreshControl.endRefreshing()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let row = collectionView.cellForItem(at: indexPath) as? UICollectionViewListCell {
            let index = indexPath.item
            if supportsMultipleSelection {
                row.tintColor = Constants.highlightColor
                row.accessories = row.accessories.count == 0 ? [UICellAccessory.checkmark()] : []
            }
            delegate?.listViewControllerDelegate(self, didSelectRow: data[index])
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    @objc func refresh() {
        self.delegate?.listViewControllerDelegateDidRefresh(self)
    }
}

// Data source
private extension ListViewController {
    enum Section: CaseIterable {
        case main
    }
    
    func updateList() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, T>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(self.data, toSection: .main)
        dataSource.apply(snapshot)
    }
    
    func makeCollectionView() -> UICollectionView {
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        config.backgroundColor = Constants.backgroundColor
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }
    
    func makeDataSource() -> UICollectionViewDiffableDataSource<Section, T> {
        let cellRegistration = makeCellRegistration()
        
        return UICollectionViewDiffableDataSource<Section, T>(
            collectionView: collectionView,
            cellProvider: { view, indexPath, item in
                view.dequeueConfiguredReusableCell(
                    using: cellRegistration,
                    for: indexPath,
                    item: item
                )
            }
        )
    }
    
    func makeCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, T> {
        return UICollectionView.CellRegistration { cell, indexPath, data in
            var config = cell.defaultContentConfiguration()
            config.text = data.displayName
            config.textProperties.color = Constants.primaryTextColor
            
            if let setting = data as? Setting {
                config.image = UIImage(systemName: setting.iconString)
                config.imageProperties.tintColor = Constants.highlightColor
            }
            
            var backgroundConfig = UIBackgroundConfiguration.listGroupedCell()
            backgroundConfig.backgroundColor = Constants.secondaryBackgroundColor
            
            cell.contentConfiguration = config
            cell.backgroundConfiguration = backgroundConfig
        }
    }
}
