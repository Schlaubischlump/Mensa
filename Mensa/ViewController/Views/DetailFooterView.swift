//
//  DetailView.swift
//  Mensa
//
//  Created by David Klopp on 28.06.22.
//

import UIKit

class DetailFooterView: UICollectionReusableView {
    public private(set) var detailContent = DetailContentView()

    public var indexPath: IndexPath?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.layer.borderWidth = 2.0
        self.layer.cornerRadius = UIFloat(5.0)

        self.addSubview(detailContent)

        let pad = UIFloat(10.0)
        self.detailContent.translatesAutoresizingMaskIntoConstraints = false

        // Fix Layout constraint conflict
        let topAnchorConstraint = self.detailContent.topAnchor.constraint(equalTo: self.topAnchor, constant: pad)
        topAnchorConstraint.priority = .defaultHigh
        topAnchorConstraint.isActive = true

        self.detailContent.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -pad).isActive = true
        self.detailContent.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: pad*2).isActive = true
        self.detailContent.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -pad*2).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.borderColor = UIColor.defaultGreen.cgColor
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.detailContent.reset()
        self.indexPath = nil
    }
}
