//
//  ResultViewController.swift
//  DVT Weather
//
//  Created by Oneh Zinde on 2023/04/24.
//

import UIKit
import CoreLocation

class ResultsViewController: UIViewController {
    
    /// Variables
    var delegate: ResultsViewControllerDelegate?
    private var places: [Place] = []
    
    /// Constants
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    // MARK: Life Cycle Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        monitorNetwork()
        view.backgroundColor = .clear
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    /// Function that provides table view with data and refreshes the view
    public func update(with places: [Place]) {
        self.tableView.isHidden = false
        self.places = places
        tableView.reloadData()
        
    }

}

// MARK: TableView Functions

extension ResultsViewController: UITableViewDelegate, UITableViewDataSource {
    
    /// Determine number of items table view should display
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    /// Configure each table view cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = places[indexPath.row].name
        return cell
    }
    
    /// Respond to taps on the table view's cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.tableView.isHidden = true
        let place = places[indexPath.row]
        
        //Find coordinaes and name of the selected location in the table
        GooglePlacesManager.shared.resloveLocation(for: place) {
            [weak self] result in
            switch result {
            case .success(let place):
                DispatchQueue.main.async {
                    self?.delegate?.didTapPlace(with: place.coordinates, name: place.name)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
