//
//  ToDoItemTableViewCell.swift
//  ToDoList
//
//  Created by Fedor Bebinov on 28.06.2023.
//

import UIKit

class ToDoItemTableViewCell: UITableViewCell {
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "test text"
        titleLabel.numberOfLines = 3
        return titleLabel
    }()
    
    private lazy var statusImageView: UIImageView = {
        let statusImageView = UIImageView()
        statusImageView.translatesAutoresizingMaskIntoConstraints = false
        statusImageView.image = UIImage(named: "off")
        return statusImageView
    }()
    
    private lazy var chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "chevron")
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor(named: "ElementsColor")
        self.addSubview(statusImageView)
        NSLayoutConstraint.activate([ statusImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16), statusImageView.widthAnchor.constraint(equalToConstant: 16), statusImageView.heightAnchor.constraint(equalToConstant: 16), statusImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor)])
        
        self.addSubview(titleLabel)
        NSLayoutConstraint.activate([titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16), titleLabel.leadingAnchor.constraint(equalTo: statusImageView.trailingAnchor, constant: 16), titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor), titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16)])
        
        self.addSubview(chevronImageView)
        NSLayoutConstraint.activate([ chevronImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16), chevronImageView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 16),  chevronImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor), chevronImageView.widthAnchor.constraint(equalToConstant: 7), chevronImageView.heightAnchor.constraint(equalToConstant: 12)])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with todoItem: ToDoItem){
        var text = todoItem.text
        if todoItem.isDone == false{
            switch todoItem.importance{
            case .basic:
                break
            case .low:
                text = "↓ " + text
            case .important:
                text = "‼️ " + text
            }
        }
        let attributesDone: [NSAttributedString.Key : Any] = [.strikethroughStyle : 2, .foregroundColor: UIColor.gray]
        let attributesNotDone: [NSAttributedString.Key : Any] = [ .foregroundColor: UIColor.black]
        let finalAttributes = todoItem.isDone ? attributesDone : attributesNotDone
        let attributedText = NSAttributedString(string: text, attributes: finalAttributes)
        titleLabel.attributedText = attributedText
        if todoItem.isDone{
            
            statusImageView.image = UIImage(named: "on")
        } else if todoItem.importance == .important {
            
            statusImageView.image = UIImage(named: "highPriority")
        } else if todoItem.importance == .low{
            
            statusImageView.image = UIImage(named: "off")
        } else {
            statusImageView.image = UIImage(named: "off")
            
        }
    }
}
