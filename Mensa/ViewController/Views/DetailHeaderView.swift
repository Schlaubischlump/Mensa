//
//  DetailHeaderView.swift
//  Mensa
//
//  Created by David Klopp on 29.06.22.
//

import UIKit

private let kHeaderTitleFontSize: CGFloat = 30
private let kHeaderPadding = UIFloat(5)
private let kProgressControlHeight = UIFloat(4)

class DetailHeaderView: UICollectionReusableView {

    public var indexPath: IndexPath?

    public static var minHeaderHeight: CGFloat {
        let titleFont = UIFont.systemFont(ofSize: kHeaderTitleFontSize)
        let today = Date.now.formatted(date: .complete, time: .omitted)
        let labelHeight = (today as NSString).size(withAttributes: [.font: titleFont]).height + kHeaderPadding*2
        return labelHeight + kProgressControlHeight + kHeaderPadding
    }

    public lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: kHeaderTitleFontSize)
        label.textColor = UIColor.defaultBlue
        return label
    }()

    public lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.isUserInteractionEnabled = false
        progressView.progressViewStyle = .bar
        progressView.trackTintColor = .defaultBlue
        progressView.progressTintColor = .defaultGreen
        return progressView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(self.titleLabel)
        #if !targetEnvironment(macCatalyst)
        self.addSubview(self.progressView)
        #endif
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.titleLabel.text = nil
        self.indexPath = nil
        #if !targetEnvironment(macCatalyst)
        self.progressView.progress = 0
        #endif
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.titleLabel.sizeToFit()

        let pad = UIFloat(kHeaderPadding)
        let offsetY = (self.frame.size.height - self.titleLabel.frame.height) / 2 + pad
        let frame = CGRect(x: pad*2, y: offsetY, width: self.frame.width-pad*4, height: self.titleLabel.frame.height)
        self.titleLabel.frame = frame

        #if !targetEnvironment(macCatalyst)
        self.progressView.frame.origin = CGPoint(x: self.titleLabel.frame.origin.x,
                                                 y: self.frame.height - kHeaderPadding - kProgressControlHeight)
        self.progressView.frame.size = CGSize(width: self.titleLabel.frame.width, height: kProgressControlHeight)
        #endif
    }
}
