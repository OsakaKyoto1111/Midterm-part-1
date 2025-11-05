//
//  MovieCell.swift
//  MovieDB-CSS214
//
//  Created by Sapuan Talaspay on 11/5/25.
//


import UIKit
import SnapKit

final class MovieCell: UICollectionViewCell {

    private let posterImageView = UIImageView()
    private let titleLabel = UILabel()
    private let ratingBadge = UIView()
    private let ratingLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
        titleLabel.text = nil
        ratingLabel.text = nil
        ratingBadge.backgroundColor = .clear
        ratingLabel.textColor = .label
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        posterImageView.layer.cornerRadius = 16
        posterImageView.clipsToBounds = true
    }

    private func setupUI() {
        contentView.backgroundColor = .clear
        contentView.clipsToBounds = false

        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 16

        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2

        ratingBadge.layer.cornerRadius = 12
        ratingBadge.clipsToBounds = true

        ratingLabel.font = .systemFont(ofSize: 13, weight: .bold)
        ratingLabel.textAlignment = .center

        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(ratingBadge)
        ratingBadge.addSubview(ratingLabel)

        posterImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.82)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(posterImageView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(8)
            make.bottom.equalToSuperview()
        }

        ratingBadge.snp.makeConstraints { make in
            make.top.equalTo(posterImageView).inset(10)
            make.leading.equalTo(posterImageView).inset(10)
            make.height.equalTo(28)
        }

        ratingLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10))
        }
    }

    func configure(with movie: Result) {
        titleLabel.text = movie.title ?? "—"

        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 16

        if let path = movie.posterPath {
            NetworkManager.shared.loadImage(posterPath: path) { [weak self] data in
                guard let self = self else { return }
                self.posterImageView.image = UIImage(data: data)
                self.posterImageView.layer.cornerRadius = 16
                self.posterImageView.clipsToBounds = true
            }
        } else {
            posterImageView.image = UIImage(systemName: "film")
            posterImageView.contentMode = .scaleAspectFit
        }

        let rating = movie.voteAverage ?? 0.0
        ratingLabel.text = String(format: "%.1f", rating)

        let (bg, text) = colorsFor(rating: rating)
        ratingBadge.backgroundColor = bg
        ratingLabel.textColor = text
    }

    private func colorsFor(rating: Double) -> (UIColor, UIColor) {
        let bg: UIColor
        switch rating {
        case ..<5: bg = .systemRed
        case 5..<7: bg = .systemGray
        case 7..<8: bg = .systemGreen
        case 8...10: bg = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0) 
        default: bg = .systemGray2
        }
        let text: UIColor = rating < 8 ? .white : .black
        return (bg, text)
    }
}
