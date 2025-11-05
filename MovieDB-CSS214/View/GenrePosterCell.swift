//
//  GenrePosterCell.swift
//  MovieDB-CSS214
//
//  Created by Sapuan Talaspay on 11/5/25.
//

import UIKit
import SnapKit  

class GenrePosterCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let overlay = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)

        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        contentView.addSubview(overlay)

        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)

        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        overlay.snp.makeConstraints { $0.edges.equalToSuperview() }
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.bottom.equalToSuperview().inset(16)
        }
    }

    func configure(with title: String, posterURL: URL?) {
        titleLabel.text = title
        imageView.image = nil
        if let url = posterURL {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async { self.imageView.image = image }
                }
            }.resume()
        }
    }
}
