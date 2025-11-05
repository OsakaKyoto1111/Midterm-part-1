//
//  SortBottomSheetViewController.swift
//  MovieDB-CSS214
//
//  Created by Sapuan Talaspay on 11/5/25.
//

import UIKit
import SnapKit

final class SortBottomSheetViewController: UIViewController {
    
    var onSelect: ((SearchViewController.SortOrder) -> Void)?
    var selected: SearchViewController.SortOrder = .none
    
    private let container = UIView()
    private let titleLabel = UILabel()
    private let ascendingButton = UIButton(type: .system)
    private let descendingButton = UIButton(type: .system)
    private let lineView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupContainer()
        setupTitle()
        setupButtons()
    }
    
    private func setupBackground() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissSelf))
        view.addGestureRecognizer(tap)
    }
    
    private func setupContainer() {
        view.addSubview(container)
        container.backgroundColor = .white
        container.layer.cornerRadius = 20
        if #available(iOS 11.0, *) {
            container.layer.maskedCorners = [
                CACornerMask.layerMinXMinYCorner,
                CACornerMask.layerMaxXMinYCorner
            ]
        }
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.2
        container.layer.shadowRadius = 6
        
        container.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    private func setupTitle() {
        titleLabel.text = "Выберите тип сортировки"
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        
        container.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    private func setupButtons() {
        func styleButton(_ button: UIButton, text: String, isSelected: Bool) {
            let imageName = isSelected ? "largecircle.fill.circle" : "circle"
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
            button.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
            button.tintColor = .black
            button.setTitle("  \(text)", for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 16)
            button.contentHorizontalAlignment = .left
        }
        
        styleButton(ascendingButton,
                    text: "По возрастанию рейтинга",
                    isSelected: selected == .ascending)
        styleButton(descendingButton,
                    text: "По убыванию рейтинга",
                    isSelected: selected == .descending)
        
        ascendingButton.addTarget(self, action: #selector(didTapAscending), for: .touchUpInside)
        descendingButton.addTarget(self, action: #selector(didTapDescending), for: .touchUpInside)
        
        container.addSubview(ascendingButton)
        container.addSubview(descendingButton)
        
        ascendingButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(30)
        }
        
        descendingButton.snp.makeConstraints { make in
            make.top.equalTo(ascendingButton.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(30)
            make.bottom.equalToSuperview().inset(40)
        }
        
        lineView.backgroundColor = .systemGray4
        lineView.layer.cornerRadius = 2
        container.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(8)
            make.width.equalTo(40)
            make.height.equalTo(4)
        }
    }
    
    @objc private func didTapAscending() {
        dismiss(animated: true) {
            self.onSelect?(.ascending)
        }
    }
    
    @objc private func didTapDescending() {
        dismiss(animated: true) {
            self.onSelect?(.descending)
        }
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateUp()
    }
    
    private func animateUp() {
        container.transform = CGAffineTransform(translationX: 0, y: 400)
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: [.curveEaseOut]) {
            self.container.transform = .identity
        }
    }
}
