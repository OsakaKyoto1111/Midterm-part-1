//
//  ColorsCollectionViewController.swift
//  MovieDB-CSS214
//
//  Created by Ерош Айтжанов on 10.10.2025.
//

import UIKit

class ColorsCollectionViewController: UIViewController {
    
    let colors: [(UIColor, String)] = [
        (.systemRed, "Red"),
        (.systemBlue, "Blue"),
        (.systemGreen, "Green"),
        (.systemYellow, "Yellow"),
        (.systemOrange, "Orange"),
        (.systemPurple, "Purple"),
        (.systemRed, "Red"),
        (.systemBlue, "Blue"),
        (.systemGreen, "Green"),
        (.systemYellow, "Yellow"),
        (.systemOrange, "Orange"),
        (.systemPurple, "Purple")
    ]
    
    private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Colors (CollectionView)"
        view.backgroundColor = .systemBackground
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 150, height: 200)
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.scrollDirection = .vertical
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//            collectionView.heightAnchor.constraint(equalToConstant: 400)
        ])
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ColorCollectionCollectionViewCell.self, forCellWithReuseIdentifier: ColorCollectionCollectionViewCell.identifier)
    }

}

extension ColorsCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionCollectionViewCell.identifier, for: indexPath) as? ColorCollectionCollectionViewCell else { return UICollectionViewCell()}
        
        let item = colors[indexPath.row]
        cell.configure(color: item.0, text: item.1)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected color: \(colors[indexPath.row].1)")
    }
    
}
