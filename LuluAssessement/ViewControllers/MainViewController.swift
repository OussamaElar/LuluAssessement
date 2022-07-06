  //
//  ViewController.swift
//  LuluAssessement
//
//  Created by Ouss Elar on 7/1/22.
//

import UIKit

class MainViewController: UIViewController {
    
    var garmentItems: [GarmentItem] = [] {
        didSet {
            DispatchQueue.main.async {
                self.garmentTableView.reloadData()
            }
        }
    }

    private func configNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus.circle"), style: .done, target: self, action: #selector(addItems))
        navigationController?.navigationBar.tintColor = .secondaryLabel
    }
    
    
    private var garmentTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    lazy var switchControl: UISegmentedControl = {
        let switchControl = UISegmentedControl(items: ["Alpha", "Creation Time"])
        switchControl.frame = CGRect(x: 0, y: 0, width: view.bounds.width - 40, height: 40)
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.selectedSegmentIndex = 1
        switchControl.tintColor = .systemGray
        switchControl.backgroundColor = .systemBackground
        switchControl.addTarget(self, action: #selector(toggleAction), for: .valueChanged)
        return switchControl
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "List"
        configNavBar()
        view.addSubview(garmentTableView)
        view.addSubview(switchControl)
        addConstraints()
        garmentTableView.delegate = self
        garmentTableView.dataSource = self
        garmentTableView.tableHeaderView = switchControl
        fetchData()
        addObserver()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        garmentTableView.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if switchControl.selectedSegmentIndex == 1 {
            self.garmentItems = GarmentViewModel().sortByDate(model: self.garmentItems)
        } else {
            self.garmentItems = GarmentViewModel().sortByAlpha(model: self.garmentItems)
        }
    }
    
    private func addConstraints() {
        let switchConstraints = [
            switchControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            switchControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            switchControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ]
        NSLayoutConstraint.activate(switchConstraints)
    }
    
    
    @objc func addItems() {
        let vc = AddViewController()
        let nav = UINavigationController()
        nav.viewControllers = [vc]
        self.present(nav, animated: true)
    }
    
    private func fetchData() {
        PersistData().fetchItems { [weak self] result in
            switch result {
            case .success(let garments):
                self?.garmentItems = garments
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @objc func toggleAction(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 1 {
            DispatchQueue.main.async { [weak self] in
                self?.garmentItems = GarmentViewModel().sortByDate(model: self?.garmentItems ?? [])
                
            }
            
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.garmentItems = GarmentViewModel().sortByAlpha(model: self?.garmentItems ?? [])
                
            }
        }
    }
    
    func addObserver() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name("saved"), object: nil, queue: nil) { [weak self] _ in
            self?.fetchData()
            if self?.switchControl.selectedSegmentIndex == 1 {
                self?.garmentItems = GarmentViewModel().sortByDate(model: self?.garmentItems ?? [])

            } else {
                self?.garmentItems = GarmentViewModel().sortByAlpha(model: self?.garmentItems ?? [])
            }
        }
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return garmentItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = garmentItems[indexPath.row]
        cell.textLabel?.text = item.garmentName
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let item = garmentItems[indexPath.row]
        switch editingStyle {
        case .delete:
            PersistData().deleteItem(with: item.objectID) { [weak self] result in
                switch result {
                case .success(()):
                    print("item deleted")
                case .failure(let error):
                    print(error.localizedDescription)
                }
                self?.garmentItems.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        default:
            break;
        }
    }
}

