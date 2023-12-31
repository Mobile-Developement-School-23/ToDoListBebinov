//
//  ToDoItemViewController.swift
//  ToDoList
//
//  Created by Fedor Bebinov on 20.06.2023.
//

import UIKit

class ToDoItemViewController: UIViewController{
    
    var todoItem: ToDoItem?
    
    private var fileCache:FileCache = {
        let fileCache = FileCache()
        fileCache.loadFromCoreData()
        return fileCache
    }()
    
    var updateHandler: (() -> Void)?
    
    private lazy var textView:UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor(named: "ElementsColor")
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.cornerRadius = 16
        textView.delegate = self
        textView.font = .systemFont(ofSize: 17)
        textView.textContainer.lineFragmentPadding = 16
        textView.isScrollEnabled = false
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        return textView
    }()
    
    private lazy var setParamsView:UIView = {
        let setParamsView = UIView()
        setParamsView.translatesAutoresizingMaskIntoConstraints = false
        setParamsView.layer.cornerRadius = 16
        setParamsView.backgroundColor = UIColor(named: "ElementsColor")
        return setParamsView
    }()
    
    private lazy var importanceSeparator:UIView = {
        let importanceSeparator = UIView()
        importanceSeparator.translatesAutoresizingMaskIntoConstraints = false
        importanceSeparator.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        return importanceSeparator
    }()
    
    private lazy var deadlineSeparator:UIView = {
        let deadlineSeparator = UIView()
        deadlineSeparator.translatesAutoresizingMaskIntoConstraints = false
        deadlineSeparator.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        deadlineSeparator.isHidden = true
        return deadlineSeparator
    }()
    
    private lazy var importanceLabel:UILabel = {
        let importanceLabel = UILabel()
        importanceLabel.translatesAutoresizingMaskIntoConstraints = false
        importanceLabel.text = "Важность"
        importanceLabel.font = .systemFont(ofSize: 17)
        return importanceLabel
    }()
    
    private lazy var deadlineLabel: UILabel = {
        let deadlineLabel = UILabel()
        deadlineLabel.translatesAutoresizingMaskIntoConstraints = false
        deadlineLabel.text = "Сделать до"
        deadlineLabel.font = .systemFont(ofSize: 17)
        return deadlineLabel
    }()
    
    private lazy var whatToDoLabel: UILabel = {
        let whatToDoLabel = UILabel()
        whatToDoLabel.translatesAutoresizingMaskIntoConstraints = false
        whatToDoLabel.text = "Что надо сделать?"
        whatToDoLabel.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        whatToDoLabel.font = .systemFont(ofSize: 17)
        return whatToDoLabel
    }()
    
    private lazy var imporatanceSegmentedControl: UISegmentedControl = {
        let imporatanceSegmentedControl = UISegmentedControl(items: [UIImage(named: "lowPriority")!, "нет", "‼️"])
        imporatanceSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        imporatanceSegmentedControl.selectedSegmentIndex = 2
        return imporatanceSegmentedControl
    }()
    
    private lazy var deadlineSwitch: UISwitch = {
        let deadlineSwitch = UISwitch()
        deadlineSwitch.translatesAutoresizingMaskIntoConstraints = false
        deadlineSwitch.addTarget(self, action: #selector(enableCalendar), for: .valueChanged)
        return deadlineSwitch
    }()
    
    private lazy var calendarView: UICalendarView = {
        let calendarView = UICalendarView()
        calendarView.backgroundColor = UIColor(named: "ElementsColor")
        calendarView.layer.cornerRadius = 16
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.availableDateRange = DateInterval(start: .now, end: .distantFuture)
        calendarView.calendar = .current
        return calendarView
    }()
    
    private lazy var dateButton: UIButton = {
        let dateButton = UIButton()
        dateButton.translatesAutoresizingMaskIntoConstraints = false
        dateButton.setTitle("01.01.1970", for: .normal)
        dateButton.setTitleColor(UIColor(red: 0, green: 0.478, blue: 1, alpha: 1), for: .normal)
        dateButton.titleLabel?.font = .systemFont(ofSize: 13)
        dateButton.addTarget(self, action: #selector(showCalendar), for: .touchUpInside)
        dateButton.alpha = 0
        return dateButton
    }()
    
    private lazy var calendarViewZeroHeightConstraint: NSLayoutConstraint = calendarView.heightAnchor.constraint(equalToConstant: 0)
    
    private lazy var dateButtonHeightConstraint: NSLayoutConstraint = dateButton.heightAnchor.constraint(equalToConstant: 0)
    
    private lazy var scrollViewBottomConstaint: NSLayoutConstraint = scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    private lazy var deleteButton: UIButton = {
        let deleteButton = UIButton()
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.isEnabled = false
        deleteButton.backgroundColor = UIColor(named: "ElementsColor")
        deleteButton.layer.cornerRadius = 16
        deleteButton.setTitle("Удалить", for: .normal)
        deleteButton.setTitleColor(.red, for: .normal)
        deleteButton.setTitleColor(.gray, for: .disabled)
        deleteButton.addTarget(self, action: #selector(deleteFromCache), for: .touchUpInside)
        return deleteButton
    }()
    
    private var deadlineDate: Date? {
        didSet{
            if let deadlineDate = deadlineDate{
                let formater = DateFormatter()
                formater.dateFormat = "dd.MM.yyyy"
                dateButton.setTitle(formater.string(from: deadlineDate), for: .normal)
            }
        }
    }
    
    private lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "BackgroundColor")
        title = "Дело"
        tapGestureRecognizer.isEnabled = false
        view.addGestureRecognizer(tapGestureRecognizer)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Сохранить", style: .done, target: self, action: #selector(save))
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Отменить", style: .plain, target: self, action: #selector(cancel))
        
        subscribeToKeyboard()
        
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor), scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor), scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor), scrollViewBottomConstaint ])
        
        scrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)])
        
        contentView.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16), textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16), textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16), textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120)
        ])
        
        contentView.addSubview(setParamsView)
        NSLayoutConstraint.activate([
            setParamsView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 16),
            setParamsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            setParamsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            setParamsView.heightAnchor.constraint(greaterThanOrEqualToConstant: 112.5)])
        
        setParamsView.addSubview(importanceLabel)
        NSLayoutConstraint.activate([
            importanceLabel.leadingAnchor.constraint(equalTo: setParamsView.leadingAnchor, constant: 16), importanceLabel.topAnchor.constraint(equalTo: setParamsView.topAnchor),  importanceLabel.heightAnchor.constraint(equalToConstant: 60)])
        
        setParamsView.addSubview(importanceSeparator)
        NSLayoutConstraint.activate([
            importanceSeparator.leadingAnchor.constraint(equalTo: setParamsView.leadingAnchor, constant: 16),
            importanceSeparator.trailingAnchor.constraint(equalTo: setParamsView.trailingAnchor, constant: -16),
            importanceSeparator.topAnchor.constraint(equalTo: importanceLabel.bottomAnchor),
            importanceSeparator.heightAnchor.constraint(equalToConstant: 0.5)
            ])
        
        setParamsView.addSubview(deadlineSeparator)
        NSLayoutConstraint.activate([
            deadlineSeparator.leadingAnchor.constraint(equalTo: setParamsView.leadingAnchor, constant: 16),
            deadlineSeparator.trailingAnchor.constraint(equalTo: setParamsView.trailingAnchor, constant: -16),
            deadlineSeparator.topAnchor.constraint(equalTo: importanceSeparator.bottomAnchor, constant: 56),
            deadlineSeparator.heightAnchor.constraint(equalToConstant: 0.5)
            ])
        
        setParamsView.addSubview(deadlineLabel)
        NSLayoutConstraint.activate([
            deadlineLabel.leadingAnchor.constraint(equalTo: setParamsView.leadingAnchor, constant: 16), deadlineLabel.topAnchor.constraint(equalTo: importanceSeparator.bottomAnchor, constant: 9),
            deadlineLabel.heightAnchor.constraint(equalToConstant: 22)])
        
        setParamsView.addSubview(dateButton)
        NSLayoutConstraint.activate([
            dateButton.leadingAnchor.constraint(equalTo: setParamsView.leadingAnchor, constant: 16), dateButton.topAnchor.constraint(equalTo: deadlineLabel.bottomAnchor),
            dateButton.bottomAnchor.constraint(equalTo: deadlineSeparator.topAnchor, constant: -9),
            dateButtonHeightConstraint])
        
        setParamsView.addSubview(imporatanceSegmentedControl)
        NSLayoutConstraint.activate([
            imporatanceSegmentedControl.trailingAnchor.constraint(equalTo: setParamsView.trailingAnchor,  constant: -16),
            imporatanceSegmentedControl.centerYAnchor.constraint(equalTo: importanceLabel.centerYAnchor),
            imporatanceSegmentedControl.heightAnchor.constraint(equalToConstant: 36), imporatanceSegmentedControl.widthAnchor.constraint(equalToConstant: 150)])
        
        setParamsView.addSubview(deadlineSwitch)
        NSLayoutConstraint.activate([
            deadlineSwitch.trailingAnchor.constraint(equalTo: setParamsView.trailingAnchor,  constant: -16),
            deadlineSwitch.topAnchor.constraint(equalTo: importanceSeparator.bottomAnchor, constant: 13.5)
            ])
        
        setParamsView.addSubview(calendarView)
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: deadlineSeparator.bottomAnchor), calendarView.trailingAnchor.constraint(equalTo: setParamsView.trailingAnchor),
            calendarView.leadingAnchor.constraint(equalTo: setParamsView.leadingAnchor), calendarView.bottomAnchor.constraint(equalTo: setParamsView.bottomAnchor), calendarViewZeroHeightConstraint])
        
        contentView.addSubview(deleteButton)
        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalTo: setParamsView.bottomAnchor, constant: 16), deleteButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16), deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16), deleteButton.heightAnchor.constraint(equalToConstant: 56),
            deleteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        
        textView.addSubview(whatToDoLabel)
        NSLayoutConstraint.activate([
            whatToDoLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 12), whatToDoLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 16)])
        
        loadFromCache()
    }
    
    private func subscribeToKeyboard(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func handleKeyboard(_ notification: NSNotification){
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let height = view.convert(keyboardValue.cgRectValue, from: view.window).height
        let keyboardConst: CGFloat
        if notification.name == UIResponder.keyboardWillShowNotification {
            keyboardConst = height + 16
            tapGestureRecognizer.isEnabled = true
        } else {
            keyboardConst = 0
            tapGestureRecognizer.isEnabled = false
        }
        scrollView.contentInset.bottom = keyboardConst
        UIView.animate(withDuration: 0.5) {
            self.view.layoutSubviews()
        }
    }
    
    @objc func save(){
        let selectedIndex = imporatanceSegmentedControl.selectedSegmentIndex
        let importance:Importance
        switch selectedIndex{
        case 0:
            importance = .low
        case 1:
            importance = .basic
        default:
            importance = .important
        }
        var id: String? = nil
        var creationDate = Date()
        if  let item = todoItem {
            id = item.id
            creationDate = item.creationDate
        }
        let todoItem = ToDoItem(id: id ?? UUID().uuidString, text: textView.text, importance: importance, deadline: deadlineDate, creationDate: creationDate)
        fileCache.add(todoItem)
        fileCache.saveToCoreData()
        updateHandler?()
        dismiss(animated: true)
    }
    
    func loadFromCache(){
        if  let item = todoItem {
            textView.text = item.text
            whatToDoLabel.isHidden = true
            switch item.importance{
            case .important:
                imporatanceSegmentedControl.selectedSegmentIndex = 2
            case .low:
                imporatanceSegmentedControl.selectedSegmentIndex = 0
            default:
                imporatanceSegmentedControl.selectedSegmentIndex = 1
            }
            deadlineDate = item.deadline
            deadlineSwitch.isOn = item.deadline != nil
            dateButton.alpha = deadlineSwitch.isOn ? 1 : 0
            dateButtonHeightConstraint.constant = deadlineSwitch.isOn ? 18 : 0
            deleteButton.isEnabled = true
        }
    }
    
    @objc func deleteFromCache(){
        if  let (key, _) = fileCache.items.first{
            fileCache.remove(key)
        }
        fileCache.saveToCoreData()
        updateHandler?()
        dismiss(animated: true)
    }
    
    @objc func cancel(){
        dismiss(animated: true)
    }

    @objc func showCalendar() {
        deadlineSeparator.isHidden.toggle()
        calendarViewZeroHeightConstraint.isActive.toggle()
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func enableCalendar(){
        if deadlineSwitch.isOn {
            let date = Calendar.current.date(byAdding: .day, value: 1, to: .now)!
            deadlineDate = date
            let dateSelection = UICalendarSelectionSingleDate(delegate: self)
            dateSelection.selectedDate = Calendar.current.dateComponents([.day, .month, .year], from: date)
            calendarView.selectionBehavior = dateSelection
        }
        dateButton.alpha = deadlineSwitch.isOn ? 1 : 0
        dateButtonHeightConstraint.constant = deadlineSwitch.isOn ? 18 : 0
        if !deadlineSwitch.isOn {
            calendarViewZeroHeightConstraint.isActive = true
        }
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    @objc func handleTap(){
        view.endEditing(true)
    }
}

extension ToDoItemViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        navigationItem.rightBarButtonItem?.isEnabled = textView.text.isEmpty == false
    }
    
    func textViewDidBeginEditing(_ textView: UITextView){
        whatToDoLabel.isHidden = textView.isFirstResponder
    }
    
    func textViewDidEndEditing(_ textView: UITextView){
        if !textView.isFirstResponder && textView.text.isEmpty {
            whatToDoLabel.isHidden = false
        }
    }
}

extension ToDoItemViewController: UICalendarSelectionSingleDateDelegate{
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?){
        if let dateComponents = dateComponents{
            if let date = Calendar.current.date(from: dateComponents){
                deadlineDate = date
            }
        }
    }
}
