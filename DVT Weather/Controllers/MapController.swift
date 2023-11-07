//
//  MapController.swift
//  DVT Weather
//
//  Created by Oneh Zinde on 2023/04/23.
//

import UIKit
import MapKit
import CoreLocation
import CoreData
import Network

class MapController: UIViewController, UIGestureRecognizerDelegate {
    
    /// Variables
    private var coordinate = CLLocationCoordinate2D()
    private var locationManager = CLLocationManager()
    private var annotations = [MKPointAnnotation]()
    private var cityName = String()
    private var NetworkCheck = false
    private var fetchedResultsController:NSFetchedResultsController<Location>!
    
    /// Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Lifecycle Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        mapView.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        addSegmentedControl()
        checkNetwork()
        
        // Register a long tap gesture recognizer
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action:#selector(handleTap))
        gestureRecognizer.delaysTouchesEnded = true
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Set fetchedResultsController to nil to save memory
        setupFetchedResultsController()
        
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        
        // Add favorite locations if any have been saved to the Location entity
        if let locations = fetchedResultsController.fetchedObjects {
            // Place past pins onto the map
            for pin in locations {
                let pointAnnotation = MKPointAnnotation()
                pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                
                self.mapView.addAnnotation(pointAnnotation)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    // MARK: Functions
    
    /// Control map appearance with the segmented control
    @objc fileprivate func mapTypeChanged(_ segControl: UISegmentedControl) {
        switch segControl.selectedSegmentIndex {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .hybrid
        case 2:
            mapView.mapType = .satellite
        default:
            break
        }
    }
    
    /// Function that control how map should respond to a long tap
    @objc fileprivate func handleTap(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            let pin = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(pin, toCoordinateFrom: mapView)
            
            let annotation = MKPointAnnotation()
            // Add annotation
            annotation.coordinate = coordinate
            
            // We place the annotation in an array of annotations.
            annotations.append(annotation)
            
            // We place the annotation on the map
            mapView.addAnnotation(annotation)
            
            let geoCoder = CLGeocoder()
            // Find the name of a location given its coordinates
            let place = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            geoCoder.reverseGeocodeLocation(place) { placemarks, error in
                guard let placemark = placemarks?.first, error == nil else {
                    print("No Placemarks")
                    return
                }
                
                if let place = placemark.locality {
                    self.cityName = place
                } else if let country = placemark.country {
                    self.cityName = "A city in \(country)"
                } else {
                    self.cityName = "Name Unavailable"
                }
                
                // Save the location to Core Data
                let location = Location(context: DataController.shared.viewContext)
                location.name = self.cityName
                location.latitude = coordinate.latitude
                location.longitude = coordinate.longitude
                
                do {
                    try DataController.shared.viewContext.save()
                    
                    print("Favorite saved")
                } catch {
                    print("Could not save favourite location")
                }
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
        do {
            // Fetch results
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    /// Function that configures the appearance of the segmented control
    fileprivate func addSegmentedControl() {
        
        //Configure the segmented control's labels
        let standardString = NSLocalizedString("Standard", comment: "Standard map view")
        let hybridString = NSLocalizedString("Hybrid", comment: "Hybrid map view")
        let satelliteString = NSLocalizedString("Satellite", comment: "Satellite map view")
        
        let segmentedControl = UISegmentedControl(items: [standardString, hybridString, satelliteString])
        segmentedControl.backgroundColor = UIColor.systemBackground
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(mapTypeChanged(_:)), for: .valueChanged)
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl)
        
        // Provide the constraints
        let topConstraint = segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8)
        let margins = view.layoutMarginsGuide
        let leadingConstraint = segmentedControl.leadingAnchor.constraint(equalTo: margins.leadingAnchor)
        let trailingConstraint = segmentedControl.trailingAnchor.constraint(equalTo: margins.trailingAnchor)
        
        topConstraint.isActive = true
        leadingConstraint.isActive = true
        trailingConstraint.isActive = true
    }
    
    /// Function that monitors the network
    fileprivate func checkNetwork() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = {
            path in
            if path.status != .satisfied {
                
                DispatchQueue.main.async {
                    self.NetworkCheck = false
                }
            } else {
                print("There is an internet connection")
                self.NetworkCheck = true
            }
        }
        
        let queue = DispatchQueue(label: "Network2")
        monitor.start(queue: queue)
    }

}

// MARK: Location Manager Functions

extension MapController: CLLocationManagerDelegate {
    
    /// Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        // Pan into the user's location
        coordinate = location.coordinate
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.8, longitudeDelta: 0.8))
        self.mapView.setRegion(region, animated: true)
    }
    
    /// Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            manager.requestWhenInUseAuthorization()
            print("Location access was restricted.")
        case .denied:
            manager.requestWhenInUseAuthorization()
            print("User denied access to location.")
        case .notDetermined:
            print("Location status not determined.")
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways:
            print("Location status is alright.")
            manager.requestLocation()
        case .authorizedWhenInUse:
            print("Location status is OK.")
            manager.requestLocation()
        @unknown default:
            print("Error with location")
            showFailure(message: "Unable to access your location.")
        }
    }
    
    /// Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      locationManager.stopUpdatingLocation()
      print("Error: \(error)")
    }
    
}

// MARK: Map View Functions

extension MapController: MKMapViewDelegate {
    
    /// Delegate method to configure the appearance of location pin.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKMarkerAnnotationView
        if pinView == nil {
            // Create the pin view
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            pinView!.canShowCallout = false
            pinView!.markerTintColor = .red
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    /// Delegate method to respond to a pin selection
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView){
        print("didSelectAnnotationTapped")
        if view.annotation is MKUserLocation {
            return
        }
        
        if NetworkCheck {
            let annotation = (view.annotation as? MKPointAnnotation)!
            let coordinate = annotation.coordinate
            
            //Find the name of the location
            let geoCoder = CLGeocoder()
            let place = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            geoCoder.reverseGeocodeLocation(place) { placemarks, error in
                guard let placemark = placemarks?.first, error == nil else {
                    print("No Placemarks")
                    return
                }
                
                if let place = placemark.locality {
                    self.cityName = place
                } else {
                    self.cityName = "No Name Found"
                }
                
                self.tapVibe()
                
                // Segue to the HomeController with coordinates of the pin's location
                let navController = self.storyboard?.instantiateViewController(withIdentifier: "NavHomeController") as! UINavigationController
                let vc = navController.topViewController as! HomeController
                vc.mapCheck = true
                vc.latitude = coordinate.latitude
                vc.longitude = coordinate.longitude
                vc.cityName = self.cityName
                vc.modalTransitionStyle = .flipHorizontal
                self.present(navController, animated: true, completion: nil)
            }
        } else {
            showFailure(message: "Please check your network connection.")
        }
    }
}

