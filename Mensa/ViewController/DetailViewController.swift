//
//  DetailViewController.swift
//  Mensa
//
//  Created by David Klopp on 28.06.22.
//

import UIKit

class DetailViewController: UIViewController {

    public var location: Location

    private var data: [Date: [Row]] = [:]

    private var sectionKeys: [Date] = []

    public init(location: Location) {
        self.location = location
        super.init(nibName: nil, bundle: nil)

        self.title = location.name
        self.navigationItem.largeTitleDisplayMode = .never
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func makeCompositionalLayout(numberOfItemsPerRow: Int) -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout(sectionProvider: {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            let spacing = UIFloat(10.0)
            let minItemWidth: CGFloat = min(UIScreen.main.bounds.width, UIFloat(370))
            let containerWidth = layoutEnvironment.container.contentSize.width
            let totalSpace = spacing * max((CGFloat(numberOfItemsPerRow) - 1), 2)
            let groupWidth = max(minItemWidth*CGFloat(numberOfItemsPerRow), containerWidth) - totalSpace
            let groupHeight = UIFloat(400.0)

            // Item
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0/CGFloat(numberOfItemsPerRow)),
                heightDimension: .estimated(UIFloat(50))
            ))

            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(groupWidth), heightDimension: .estimated(groupHeight*0.7)
                ),
                subitem: item,
                count: numberOfItemsPerRow
            )
            group.interItemSpacing = .fixed(spacing)

            // Section
            let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                    heightDimension: .estimated(groupHeight*0.3))
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                    heightDimension: .absolute(
                                                        DetailHeaderView.minHeaderHeight + spacing * 4
                                                    ))
            let footer = NSCollectionLayoutBoundarySupplementaryItem(
                            layoutSize: footerSize,
                            elementKind: UICollectionView.elementKindSectionFooter,
                            alignment: .bottom
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                            layoutSize: headerSize,
                            elementKind: UICollectionView.elementKindSectionHeader,
                            alignment: .top
            )

            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [header, footer]
            section.orthogonalScrollingBehavior = .continuous
            section.contentInsets = NSDirectionalEdgeInsets(
              top: spacing, leading: spacing, bottom: spacing, trailing: spacing
            )

            // Show a scroll progress indicator on iOS
            #if !targetEnvironment(macCatalyst)
            section.visibleItemsInvalidationHandler = { [weak self] visibleItems, point, environment in
                guard let collectionView = self?.view as? UICollectionView, let currentItem = visibleItems.last else {
                    return
                }

                let scrollableArea = groupWidth - environment.container.contentSize.width
                let scrollOffset = max(0, min(1, point.x / scrollableArea))

                let headerKind = UICollectionView.elementKindSectionHeader
                let views = collectionView.visibleSupplementaryViews(ofKind: headerKind)
                let header = views.filter { view in
                    currentItem.indexPath.section == (view as? DetailHeaderView)?.indexPath?.section
                }.last as? DetailHeaderView

                header?.progressView.setProgress(Float(scrollOffset), animated: false)
            }
            #endif

            return section
        })
    }

    override func loadView() {
        let layout = self.makeCompositionalLayout(numberOfItemsPerRow: self.location.numberOfCounters)
        let collectionView =  UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(DetailCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.register(DetailFooterView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: "FooterCell")
        collectionView.register(DetailHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "HeaderCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: UIFloat(20), right: 0)

        self.view = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .defaultBackground

        #if targetEnvironment(macCatalyst)
        self.navigationController?.isNavigationBarHidden = true
        #else
        self.navigationController?.isNavigationBarHidden = false
        #endif

        Task {
            do {
                try await self.reloadData()
            } catch {
                // TODO: Show an error
                print(error)
            }
        }
    }

    public func reloadData() async throws {
        // Fetch all data from the server  and filter based on the location and date
        let rows = try await API.fetchRows()
        let locationData = rows.filter { row in
            let today = Calendar.current.startOfDay(for: Date.now)
            let targetDate = Calendar.current.startOfDay(for: row.date)
            return row.consumeLocation == self.location && targetDate.timeIntervalSince(today) >= 0
        }

        // Group all entries by date
        self.data = Dictionary(grouping: locationData, by: {
            $0.date
        })
        // Keep a fixed order for all sections
        self.sectionKeys = data.keys.sorted { $0 < $1 }

        let collectionView = self.view as? UICollectionView
        collectionView?.reloadData()

        // TODO: Remove this debug help
        self.data.forEach { key, value in
            value.forEach { row in
                switch row.counter {
                case .unknown:
                    print("Found unknown counter: ", row.counter.rawValue, ": ", row.date, ": ", row.description)
                default: break
                }
            }
        }
    }
}


extension DetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.sectionKeys.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.location.numberOfCounters
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let identifier = kind == UICollectionView.elementKindSectionFooter ? "FooterCell" : "HeaderCell"
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier,
                                                                   for: indexPath)

        guard let date = self.sectionKeys[safe: indexPath.section] else {
            return cell
        }

        if let cell = cell as? DetailHeaderView {
            cell.titleLabel.text = date.formatted(date: .complete, time: .omitted)
            cell.indexPath = indexPath
        } else if let cell = cell as? DetailFooterView {
            let rows = self.data[date]?.filter ({ $0.counter.orderIndex == .side }) ?? []

            if rows.count > 0 {
                cell.detailContent.data = rows
            } else {
                cell.detailContent.data = [
                    Row(location: self.location, consumeLocation: self.location, counter: .sideDishes(0),
                        date: Date.now, description: "Keine Gerichte")
                ]
            }
            cell.indexPath = indexPath
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)

        // Display the data for all main counters (that means counters with order index 1 to 4)
        if let cell = cell as? DetailCell {
            if let date = self.sectionKeys[safe: indexPath.section] {
                let rows = self.data[date]?.filter { $0.counter.orderIndex.rawValue == indexPath.row } ?? []
                if rows.count > 0 {
                    cell.detailContent.data = rows
                    return cell
                }
            }

            // Create dummy data to show a placeholder
            var counter: Counter = .one(0)
            switch indexPath.row {
            case 1: counter = .two(0)
            case 2: counter = .three(0)
            case 3: counter = .four(0)
            default: counter = .one(0)
            }

            cell.detailContent.data = [
                Row(location: self.location,
                    consumeLocation: self.location,
                    counter: counter, date: Date.now,
                    description: "Heute keine Ausgabe")
            ]
        }
        return cell
    }
}
