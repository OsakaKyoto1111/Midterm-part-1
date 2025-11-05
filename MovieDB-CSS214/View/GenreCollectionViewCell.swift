//
//  GenreCollectionViewCell.swift
//  MovieDB-CSS214
//
//  Created by Ерош Айтжанов on 24.10.2025.
//

import UIKit
import SnapKit

class GenreCollectionViewCell: UICollectionViewCell {
    lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.backgroundColor = .blue
        label.textAlignment = .center
        label.layer.cornerRadius = 15
        label.layer.masksToBounds = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
