//
//  CastCollectionViewCell.swift
//  MovieDB-CSS214
//
//  Created by Ерош Айтжанов on 24.10.2025.
//

import UIKit

class CastCollectionViewCell: UICollectionViewCell {
    private lazy var actorImage: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = image.bounds.height / 2
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private lazy var actorName: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.sizeToFit()
        return label
    }()
    
    private lazy var roleName: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 12, weight: .light)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.sizeToFit()
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        [actorImage, stackView].forEach {
            contentView.addSubview($0)
        }
        
        [actorName, roleName].forEach {
            stackView.addArrangedSubview($0)
        }
        
        actorImage.snp.makeConstraints { make in
            make.leading.equalTo(contentView.safeAreaLayoutGuide)
            make.centerY.equalTo(contentView)
            make.height.equalTo(100)
            make.width.equalTo(65)
        }
        
        stackView.snp.makeConstraints { make in
            make.leading.equalTo(actorImage.snp.trailing).offset(5)
            make.top.equalTo(actorImage.snp.top)
            make.trailing.equalTo(contentView).offset(-10)
        }
    }
    
    func conf(cast: Cast) {
        actorName.text = cast.name
        roleName.text = cast.character
        if let profilePath = cast.profilePath {
            NetworkManager.shared.loadImage(posterPath: profilePath) { data in
                self.actorImage.image = UIImage(data: data)
            }
        } else {
            actorImage.image = UIImage(systemName: "person.circle")
        }
    }
    
}
