//
//  DetailContentView.swift
//  Mensa
//
//  Created by David Klopp on 29.06.22.
//

import UIKit

private let kTitleFontSize: CGFloat = 22

private let kBodyFontSize: CGFloat = 16


class DetailContentView: UIStackView {

    private var lastArrangedSubviewViewIsTitleLabel = false

    public var data: [Row] = [] {
        willSet(rows) {
            self.reset()

            // Sort by order index and counter name
            let sortedRows = rows.sorted { (lhs, rhs) in
                if lhs.counter.orderIndex == rhs.counter.orderIndex {
                    return lhs.counter.name < rhs.counter.name
                }
                return lhs.counter.orderIndex.rawValue < rhs.counter.orderIndex.rawValue
            }

            // Add all subviews for each data point
            var lastCounter: Counter?
            sortedRows.forEach { row in
                if row.counter.name != lastCounter?.name {
                    self.add(title: row.counter.name)
                    lastCounter = row.counter
                }
                self.add(content: row)
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.alignment = .fill
        self.axis = .vertical
        self.distribution = .fill
        self.spacing = UIFloat(10.0)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func makeTitleLabel(title: String) -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: kTitleFontSize)
        label.textColor = UIColor.defaultBlue
        label.text = title
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func makeContentLabel(text: String) -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: kBodyFontSize)
        label.textColor = .secondaryLabel
        label.text = text
        label.numberOfLines = -1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func makeIndicatorLabel(text: String) -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: kBodyFontSize)
        label.text = text
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func makePriceLabel(priceString: String) -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: kBodyFontSize)
        label.textColor = .tertiaryLabel
        label.text = priceString
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func makeSeparator() -> UIView {
        let container = UIView()
        let view = UIView()
        view.backgroundColor = .defaultGreen
        container.addSubview(view)
        container.translatesAutoresizingMaskIntoConstraints = false

        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 0).isActive = true
        view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 0).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false

        return container
    }

    public func add(title: String) {
        self.addArrangedSubview(self.makeTitleLabel(title: title))
        self.lastArrangedSubviewViewIsTitleLabel = true
    }

    public func add(content: Row) {
        if !self.lastArrangedSubviewViewIsTitleLabel {
            self.addArrangedSubview(self.makeSeparator())
        }

        self.addArrangedSubview(self.makeContentLabel(text: content.description))
        self.addArrangedSubview(self.makeIndicatorLabel(text: content.getAdditivesText()))

        if let price = content.getPriceString() {
            self.addArrangedSubview(self.makePriceLabel(priceString: price))
        }
        self.lastArrangedSubviewViewIsTitleLabel = false
    }

    func reset() {
        self.arrangedSubviews.forEach {
            self.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        self.lastArrangedSubviewViewIsTitleLabel = false
    }
}
