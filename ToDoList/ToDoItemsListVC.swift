//
//  ToDoItemsListVC.swift
//  ToDoList
//
//  Created by Fedor Bebinov on 28.06.2023.
//

import UIKit
import CocoaLumberjackSwift

class ToDoItemsListVC: UIViewController{
    
    private var showCompleted: Bool = false
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.register(ToDoItemTableViewCell.self, forCellReuseIdentifier: "ToDoItemTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ToDoItemsHeaderView.self, forHeaderFooterViewReuseIdentifier: "ToDoItemsHeaderView")
        return tableView
    }()
    
    private lazy var plusButton: UIButton = {
        let plusButton = UIButton()
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "plus")
        plusButton.setBackgroundImage(image, for: .normal)
//        plusButton.imageView?.contentMode = .scaleAspectFill
        //plusButton.configuration = .filled()
        plusButton.addTarget(self, action: #selector(createNewItem) , for: .touchUpInside)
        return plusButton
    }()
    private lazy var fileCache = FileCache()
    
    private lazy var toDoItems: [ToDoItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DDLog.add(DDOSLogger.sharedInstance)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.layoutMargins.left = 32
        navigationController?.navigationBar.layoutMargins.top = 88
        view.backgroundColor = UIColor(named: "BackgroundColor")
        title = "Мои дела"
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
        
        view.addSubview(plusButton)
        NSLayoutConstraint.activate([plusButton.widthAnchor.constraint(equalToConstant: 44), plusButton.heightAnchor.constraint(equalToConstant: 44), plusButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -54), plusButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)])
        updateToDoItems()
    }
    
    @objc func createNewItem(){
        let vc = ToDoItemViewController()
        vc.updateHandler = { [weak self] in
            self?.updateToDoItems()
        }
        let nc = UINavigationController(rootViewController: vc)
        present(nc, animated: true)
    }
    
    func updateToDoItems(){
        try? fileCache.load(from: "todoItemsCache")
        var items = [ToDoItem]()
        for (_, item) in fileCache.items {
            items.append(item)
        }
        if !showCompleted {
            items = items.filter({ todoItem in
                todoItem.isDone == false
            })
        }
        items.sort { todoitem1, todoitem2 in
            todoitem1.creationDate < todoitem2.creationDate
        }
        toDoItems = items
        DDLogDebug(toDoItems)
        tableView.reloadData()
    }
}

extension ToDoItemsListVC: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        toDoItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable:next force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemTableViewCell", for: indexPath) as! ToDoItemTableViewCell 
        let item = toDoItems[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // swiftlint:disable:next force_cast
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ToDoItemsHeaderView") as! ToDoItemsHeaderView
        let completedItems = fileCache.items.filter { (key, item) in
            item.isDone
        }
        
        headerView.showHandler = { [weak self] in
            self?.showCompleted.toggle()
            self?.updateToDoItems()
        }
        headerView.configure(completedCount: completedItems.count, isShown: showCompleted)
        return headerView
    }
}

extension ToDoItemsListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let item = toDoItems[indexPath.row]
        let vc = ToDoItemViewController()
        vc.todoItem = item
        vc.updateHandler = { [weak self] in
            self?.updateToDoItems()
        }
        let nc = UINavigationController(rootViewController: vc)
        present(nc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: nil, handler: {_,_,_ in
            self.fileCache.remove(self.toDoItems[indexPath.row].id)
            try? self.fileCache.save(to: "todoItemsCache")
            self.updateToDoItems()
        })
        let info = UIContextualAction(style: .normal, title: "info", handler: {_,_,_ in
            print("info")
        })
        delete.image = UIImage(named: "trash")
        let configuration = UISwipeActionsConfiguration(actions: [delete, info])
        return configuration
    }
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let done = UIContextualAction(style: .normal, title: nil, handler: {_,_,_ in
            let itemToChange = self.toDoItems[indexPath.row]
            let completedItem =  ToDoItem(id: itemToChange.id, text: itemToChange.text, importance: itemToChange.importance, deadline: itemToChange.deadline, isDone: true, creationDate: itemToChange.creationDate, modifiedDate: itemToChange.modifiedDate)
            self.fileCache.add(completedItem)
            try? self.fileCache.save(to: "todoItemsCache")
            self.updateToDoItems()
        })
        done.image = UIImage(named: "done")
        done.backgroundColor = .green
        let configuration = UISwipeActionsConfiguration(actions: [done])
        return configuration
    }
}


