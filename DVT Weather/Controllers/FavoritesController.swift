//
//  FavoritesController.swift
//  DVT Weather
//
//  Created by Oneh Zinde on 2023/04/24.
//

import UIKit
import GooglePlaces
import CoreLocation
import CoreData
import Network

class FavoritesController: UITableViewController, UISearchResultsUpdating {
    
    /// Constants
    private let searchVC = UISearchController(searchResultsController: ResultsViewController())
    
    /// Variables
    private var coordinate = CLLocationCoordinate2D()
    private var fetchedResultsController: NSFetchedResultsController<Location>!
    private var savedLocations: [Location] = []
    private var selectedIndex = 0
    private var networkCheck = false
    
    // MARK: Lifecycle Functions

    override func viewDidLoad() {
        super.viewDidLoad()

        searchVC.searchBar.backgroundColor = .clear
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
        navigationItem.rightBarButtonItem = editButtonItem
        checkNetwork()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changesToStoredData()
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Set fetchedResultsController to nil to save memory
        fetchedResultsController = nil
    }
    
    // MARK: Functions
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    /// Function that checks for Core Data items and responds accordingly
    fileprivate func changesToStoredData() {
        setupFetchedResultsController()
        
        // Check for saved Location items
        if let locations = fetchedResultsController.fetchedObjects {
            if locations.count != 0 {
                savedLocations = locations
            } else {
                backgroundSetup()
            }
        } else {
            backgroundSetup()
        }
        
        tableView.reloadData()
        updateEditButtonState()
    }
    
    /// Function used to determine editable state of table
    fileprivate func changes() {
        if let locations = fetchedResultsController.fetchedObjects {
            savedLocations = locations
            updateEditButtonState()
        }
    }
    
    /// Function that sets up background view of table
    fileprivate func backgroundSetup() {
        let view = NoDataView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.frame.height))
        view.set(title: "No Saved Locations", desc: "Search for a location and tap on it to save it to Favorites.")
        tableView.backgroundView = view
    }
    
    /// Function that controls the state of the edit button
    fileprivate func updateEditButtonState() {
        if let sections = fetchedResultsController.fetchedObjects {
            if sections.count == 0 {
                navigationItem.rightBarButtonItem?.isEnabled = false
            }
            else {
                navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
    }
    
    /// Set up Core Data results
    fileprivate func setupFetchedResultsController() {
        // Find Objects with Location entity name
        let fetchRequest:NSFetchRequest<Location> = Location.fetchRequest()
        // Arrange the items in ascending order
        let sortDescriptor = NSSortDescriptor(key: #keyPath(Location.name), ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: "favorites")
        fetchedResultsController.delegate = self
        do {
            // Fetch results
            try fetchedResultsController.performFetch()
        } catch {
            print("Error with Core Data")
            showFailure(message: "Could not retrieve saved locations")
        }
    }
    
    /// Function that responds to search queries in the search bar
    internal func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text, !query.trimmingCharacters(in: .whitespaces).isEmpty,
        let resultsVC = searchController.searchResultsController as? ResultsViewController else {
            return
        }
        
        resultsVC.delegate = self
        
        // Find locations with the provided search term
        GooglePlacesManager.shared.findPlace(query: query) {
            result in
            switch result {
            case .success(let places):
                DispatchQueue.main.async {
                    resultsVC.update(with: places)
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    /// Deletes the location at the specified index path
    fileprivate func deleteLocation(at indexPath: IndexPath) {
        let locationToDelete = fetchedResultsController.object(at: indexPath)
        DataController.shared.viewContext.delete(locationToDelete)
        try? DataController.shared.viewContext.save()
    }
    
    /// Function that monitors the network
    fileprivate func checkNetwork() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = {
            path in
            if path.status != .satisfied {
                
                DispatchQueue.main.async {
                    self.networkCheck = false
                }
            } else {
                print("There is an internet connection")
                self.networkCheck = true
            }
        }
        
        let queue = DispatchQueue(label: "Network")
        monitor.start(queue: queue)
    }
    
    // MARK: TableView Functions
    
    /// Determine number of items table view should display
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    /// Configure each table view cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteLocation", for: indexPath)
        guard let objects = fetchedResultsController.fetchedObjects else {
            return cell
        }
        
        let location = objects[indexPath.row]
        
        cell.textLabel?.text = location.name
        return cell
    }
    
    /// Respond to changes made to the content of the table view
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            deleteLocation(at: indexPath)
            guard let objects = fetchedResultsController.fetchedObjects else {
                return
            }
            if objects.count == 0 {
                updateEditButtonState()
            }
        default: () // Unsupported
        }
    }
    
    /// Respond to taps on the table view's cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if networkCheck {
            selectedIndex = indexPath.item
            tapVibe()
            
            // Segue to the HomeController with the coordinates of the saved location
            guard let objects = fetchedResultsController.fetchedObjects else {
                return
            }
            
            let location = objects[selectedIndex]
            
            guard let navController = self.storyboard?.instantiateViewController(withIdentifier: "NavHomeController") as? UINavigationController, let vc = navController.topViewController as? HomeController else {
                return
            }
            
            vc.favoriteCheck = true
            if let locationName = location.name {
                vc.cityName = locationName
            } else {
                vc.cityName = "Name Unavailable"
            }
            
            vc.cityName = location.name!
            vc.latitude = location.latitude
            vc.longitude = location.longitude
            vc.modalTransitionStyle = .flipHorizontal
            present(navController, animated: true, completion: nil)
        } else {
            showFailure(message: "Please check your network connection.")
        }
        
    }
}

// MARK: Results Controller Delegate

extension FavoritesController: ResultsViewControllerDelegate {
    
    /// Respond to a tap on a location in the search results
    func didTapPlace(with coordinates: CLLocationCoordinate2D, name: String) {
        searchVC.searchBar.resignFirstResponder()
        searchVC.searchBar.text = ""
        searchVC.dismiss(animated: true, completion: nil)
        coordinate = coordinates
        
        // Save the selected location to Core Data
        let location = Location(context: DataController.shared.viewContext)
        location.name = name
        location.latitude = coordinates.latitude
        location.longitude = coordinates.longitude
        
        do {
            try DataController.shared.viewContext.save()
            updateEditButtonState()
            tableView.backgroundView = nil
            
            print("Favorite saved")
        } catch {
            print("Could not save favourite location")
        }
    }
}

// MARK: Core Data Results Functions

extension FavoritesController: NSFetchedResultsControllerDelegate {
    
    /// Function that responds to edits made to the table view's items
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            break
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            break
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            print("Error with table item edits")
            showFailure(message: "Unable to complete edit.")
        }
    }
    
    /// Function that responds to edits made to the table view's sections
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert: tableView.insertSections(indexSet, with: .fade)
        case .delete: tableView.deleteSections(indexSet, with: .fade)
        case .update, .move:
            print("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
        @unknown default:
            print("Error with table section edits")
            showFailure(message: "Unable to complete edit.")
        }
    }

    /// Function that responds to table view changes to begin updates
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    /// Function that responds to table view changes to end updates
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}
