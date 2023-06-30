//
//  ToDoItemsHeader.swift
//  ToDoList
//
//  Created by Fedor Bebinov on 29.06.2023.
//

import UIKit

class ToDoItemsHeaderView: UITableViewHeaderFooterView {
    var showHandler: (() -> Void)?
    private lazy var hasDoneLabel: UILabel = {
        let hasDoneLabel = UILabel()
        hasDoneLabel.translatesAutoresizingMaskIntoConstraints = false
        hasDoneLabel.text = "Выполнено - "
        hasDoneLabel.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        return hasDoneLabel
    }()
    
    private lazy var showCompletedButton: UIButton = {
        let showCompletedButton = UIButton()
        showCompletedButton.translatesAutoresizingMaskIntoConstraints = false
        showCompletedButton.setTitle("Показать", for: .normal)
        showCompletedButton.setTitleColor(.systemBlue, for: .normal)
        showCompletedButton.addTarget(self, action: #selector(showCompleted), for: .touchUpInside)
        return showCompletedButton
    }()
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        self.addSubview(hasDoneLabel)
        NSLayoutConstraint.activate([hasDoneLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16), hasDoneLabel.topAnchor.constraint(equalTo: self.topAnchor), hasDoneLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)])
        
        self.addSubview(showCompletedButton)
        NSLayoutConstraint.activate([showCompletedButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16), showCompletedButton.topAnchor.constraint(equalTo: self.topAnchor), showCompletedButton.bottomAnchor.constraint(equalTo: self.bottomAnchor)])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(completedCount: Int, isShown: Bool){
        if isShown{
            showCompletedButton.setTitle("Скрыть", for: .normal)
        } else {
            showCompletedButton.setTitle("Показать", for: .normal)
        }
        hasDoneLabel.text = "Выполнено - \(completedCount)"
    }
    
    @objc func showCompleted(){
        showHandler?()
    }
}
