//
//  DetailCell.swift
//  Mensa
//
//  Created by David Klopp on 28.06.22.
//

import UIKit

class DetailCell: UICollectionViewCell {
    public private(set) var detailContent = DetailContentView(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.layer.borderWidth = 2.0
        self.layer.cornerRadius = UIFloat(5.0)

        let content = self.contentView
        content.addSubview(self.detailContent)

        let pad = UIFloat(10.0)
        self.detailContent.translatesAutoresizingMaskIntoConstraints = false
        self.detailContent.topAnchor.constraint(equalTo: content.topAnchor, constant: pad).isActive = true
        self.detailContent.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -pad).isActive = true
        self.detailContent.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: pad*2).isActive = true
        self.detailContent.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -pad*2).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.detailContent.reset()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.borderColor = UIColor.defaultGreen.cgColor
    }
}
