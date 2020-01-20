//
//  CarouselCollectionView.swift
//  PhotoEditKit
//
//  Created by Shawn Wu on 1/11/20.
//  Copyright © 2020 Shawn Wu. All rights reserved.
//

import UIKit
import SnapKit

let colorBlack: UIColor = UIColor(red: 17 / 255, green: 17 / 255, blue: 17 / 255, alpha: 1)
let colorBlue: UIColor = UIColor(red: 28 / 255, green: 158 / 255, blue: 220 / 255, alpha: 1)

class CarouselCollectionView: UICollectionView {
    let flowLayout: UICollectionViewFlowLayout
    
    init() {
        flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        super.init(frame: .null, collectionViewLayout: flowLayout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TemplateCarouselCollectionView: CarouselCollectionView {
    override init() {
        super.init()
        
        self.register(PhotoTemplateCell.self, forCellWithReuseIdentifier: PhotoTemplateCell.reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PhotoTemplateCell: UICollectionViewCell {
    static let reuseIdentifier: String = "\(type(of: self)) reuseIdentifier"
    
    let imageView: UIImageView = UIImageView()
    let titleLabel: UILabel = UILabel()
    
    override var isHighlighted: Bool {
        didSet {
            imageView.backgroundColor = isHighlighted ? .white : colorBlack
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = colorBlack
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(contentView.snp.width).inset(8)
            make.height.equalTo(imageView.snp.width)
        }
        
        titleLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 14)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(4)
        }
    }
    
    func configure(name: String) {
        titleLabel.text = name
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
