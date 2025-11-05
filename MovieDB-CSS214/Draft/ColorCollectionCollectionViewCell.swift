//
//  ColorCollectionCollectionViewCell.swift
//  MovieDB-CSS214
//
//  Created by Ерош Айтжанов on 10.10.2025.
//

import UIKit

class ColorCollectionCollectionViewCell: UICollectionViewCell {
    static let identifier = "ColorCollectionCollectionViewCell"
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(color: UIColor, text: String) {
        contentView.backgroundColor = color
        label.text = text
    }
}
