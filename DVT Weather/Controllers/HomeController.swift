//
//  ViewController.swift
//  DVT Weather
//
//  Created by Oneh Zinde on 2023/04/22.
//

import UIKit
import Network
import CoreLocation
import CoreData

class HomeController: UIViewController {
    
    /// Variables
    private var fiveDayForecast = [ForecastObject]()
    private var locationManager: CLLocationManager!
    private var coordinate = CLLocationCoordinate2D()
    private var contentViewColour = UIColor()
    private var fetchedResultsController: NSFetchedResultsController<OfflineForecast>!
    var weather: WeatherForecast?
    var cityName = String()
    var latitude = Double()
    var longitude = Double()
    var favoriteCheck = false
    var mapCheck = false
    private var offlineCheck = false
    private var onlineCheck = false {
        didSet {
            DispatchQueue.main.async {
                if self.favoriteCheck == false && self.mapCheck == false {
                    // Location manager used to get users current location
                    self.locationManager = CLLocationManager()
                    self.locationManager.delegate = self
                    self.locationManager.requestWhenInUseAuthorization()
                    
                } else {
                    // Methods that respond to segue from MapController or FavoritesController
                    self.coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
                    self.animateActivityIndicator(should: true)
                    if self.offlineCheck == false {
                        self.getCurrentWeather(coordinates: self.coordinate)
                    }
                }
            }
        }
    }
    private var viewsSet: Bool! {
        didSet {
            DispatchQueue.main.async {
                self.animateActivityIndicator(should: false)
                self.navigationItem.leftBarButtonItem?.isEnabled = true
                self.tableView.reloadData()
                
                if self.favoriteCheck || self.mapCheck {
                    self.navigationItem.title = self.cityName
                }
                
                // Perform animation
                UIView.animate(withDuration: 1.5) {
                    self.degreeLabel.alpha = 1
                    self.symbolOne.alpha = 1
                }
            }
        }
    }
    
    /// Outlets
    @IBOutlet weak var degreeLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var dayTempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var maxLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var symbolOne: UIImageView!
    @IBOutlet weak var symbolTwo: UIImageView!
    @IBOutlet weak var symbolThree: UIImageView!
    @IBOutlet weak var symbolFour: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var offlineView: UIView!
    @IBOutlet weak var offlineTime: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    /// Actions
    @IBAction func cameraTapped(_ sender: UIButton) {
        tapVibe()
        
        guard let storyboard = storyboard else {
            return
        }
        
        let vc = storyboard.instantiateViewController(withIdentifier: "PhotosController") as! PhotosController
        vc.coordinate = coordinate
        vc.cityname = cityName
        vc.modalTransitionStyle = .flipHorizontal
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    // MARK: Lifecycle Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        setupFetchedResultsController()
        checkNetwork()
        animateActivityIndicator(should: true)
        navigationItem.leftBarButtonItem?.isEnabled = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Set fetchedResultsController to nil to save memory
        fetchedResultsController = nil
    }
    
    // MARK: Functions
    
    /// Function that monitors the network
    func checkNetwork() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = {
            path in
            if path.status != .satisfied {
                DispatchQueue.main.async {
                    //Display offline forecast
                    self.showFailure(message: "Please check your network connection.")
                    self.showOfflineView()
                    self.offlineCheck = true
                    self.navigationItem.leftBarButtonItem?.isEnabled = false
                }
            } else {
                print("There is an internet connection")
                self.offlineCheck = false
                self.onlineCheck = true
            }
        }
        
        let queue = DispatchQueue(label: "Network")
        monitor.start(queue: queue)
    }
    
    /// Function that retrieves weather information
    fileprivate func getCurrentWeather(coordinates: CLLocationCoordinate2D) {
        
        Task {
            do {
                weather = try await WeatherClient.getWeatherObjects(latitude: coordinates.latitude, longitude: coordinates.longitude)
                
                guard let weather = weather else {
                    return
                }
                
                var forecast = [ForecastObject]()
                for item in weather.dailyWeather {
                    // Iterate over the items to populate the 5 day forecast
                    let date = NSDate(timeIntervalSince1970: Double(item.date))
                    let day = dayOfWeek(date: date as Date)
                    guard let day = day, let description = item.description.first else {
                        return
                    }
                    
                    let dayForecast = ForecastObject(day: day, weatherType: description.type, temperature: Int(item.dayTemperature.forTheDay))
                    forecast.append(dayForecast)
                }
                
                forecast.removeFirst()
                fiveDayForecast = Array((forecast.prefix(5)))
                updateViews(weather: weather)
              
                // Catch block
            } catch WeatherRequestErrors.invalidURL {
                animateActivityIndicator(should: false)
                showFailure(message: "An incorrect URL was used.")
            } catch WeatherRequestErrors.couldNotGetWeather {
                animateActivityIndicator(should: false)
                showFailure(message: "Weather information could not be found.")
            } catch WeatherRequestErrors.couldNotGetWeatherData {
                animateActivityIndicator(should: false)
                showFailure(message: "Weather information unavailable.")
            } catch {
                animateActivityIndicator(should: false)
                showFailure(message: "An unknown error occured.")
            }
        }
    }
    
    /// Updates views on the main thread
    @MainActor
    fileprivate func updateViews(weather: WeatherForecast) {
        
        guard let forecast = weather.dailyWeather.first, let description = weather.currentWeather.description.first else {
            return
        }
        
        let type = description.type
        let dayTemp = Int(forecast.dayTemperature.forTheDay)
        let minTemp = Int(forecast.dayTemperature.minTemperature)
        let maxTemp = Int(forecast.dayTemperature.maxTemperature)
        let currentTemp = Int(weather.currentWeather.temperature)
        
        // Configure the view controller's views
        weatherLabel.text = type
        degreeLabel.text = String(currentTemp)
        minTempLabel.text = String(minTemp)
        maxTempLabel.text = String(maxTemp)
        dayTempLabel.text = String(dayTemp)
        viewsSet = true
        setupBackground(type: type)
        
        // Save forecast to Core Data
        if self.favoriteCheck == false && self.mapCheck == false {
            saveOfflineForecast(name: cityName, type: type, dayTemp: dayTemp, minTemp: minTemp, maxTemp: maxTemp, currentTemp: currentTemp)
        }
    }
    
    /// Updates views for offline mode
    fileprivate func showOfflineView() {
        
        guard let results = fetchedResultsController else {
            return
        }
        
        if let savedForecast = results.fetchedObjects {
            
            // Check for saved forecast
            if let forecast = savedForecast.first {
                
                guard let type = forecast.weatherType, let date = forecast.saveDate else {
                    return
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy/MM/dd \nHH:mm"
                let lastUpdate = dateFormatter.string(from: date)
                
                // Display views on main thread
                DispatchQueue.main.async {
                    self.navigationItem.title = forecast.name
                    self.setupBackground(type: type)
                    self.weatherLabel.text = type
                    self.offlineTime.text = lastUpdate
                    self.degreeLabel.text = String(forecast.currentTemp)
                    self.minTempLabel.text = String(forecast.minTemp)
                    self.maxTempLabel.text = String(forecast.maxTemp)
                    self.dayTempLabel.text = String(forecast.dayTemp)
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                    self.symbolOne.isHidden = false
                    self.symbolTwo.isHidden = false
                    self.symbolThree.isHidden = false
                    self.symbolFour.isHidden = false
                    self.degreeLabel.isHidden = false
                    self.dayTempLabel.isHidden = false
                    self.minTempLabel.isHidden = false
                    self.maxTempLabel.isHidden = false
                    self.dayLabel.text = "current"
                    self.minLabel.text = "min"
                    self.maxLabel.text = "max"
                    self.weatherLabel.isHidden = false
                    self.dayLabel.text = "current"
                    self.offlineView.isHidden = false
                }
            } else {
                print("No saved forecast")
            }
        } else {
            showFailure(message: "Offline forecast unavailable")
        }
    }
    
    /// Setup saved data
    fileprivate func saveOfflineForecast(name: String, type: String, dayTemp: Int, minTemp: Int, maxTemp: Int, currentTemp: Int) {
        
        guard let results = fetchedResultsController else {
            return
        }
        
        // Check for saved data
        if let savedForecast = results.fetchedObjects {
            
            // Save first offline forecast
            if savedForecast.count == 0 {
                // Save new information
                let forecast = OfflineForecast(context: DataController.shared.viewContext)
                setOfflineData(forecast: forecast, name: name, type: type, dayTemp: dayTemp, minTemp: minTemp, maxTemp: maxTemp, currentTemp: currentTemp)
                
                do {
                    try DataController.shared.viewContext.save()
                    print("Offline saved")
                    
                } catch {
                    print("Could not save offline information")
                }
            } else {
                // Update old information
                print("Offline count: \(savedForecast.count)")
                if let forecast = savedForecast.first {
                    setOfflineData(forecast: forecast, name: name, type: type, dayTemp: dayTemp, minTemp: minTemp, maxTemp: maxTemp, currentTemp: currentTemp)
                    if DataController.shared.viewContext.hasChanges {
                        print("Update")
                        
                        do {
                            try DataController.shared.viewContext.save()
                            print("Offline saved")
                            
                        } catch {
                            print("Could not save offline information")
                        }
                        
                    } else {
                        print("No offline changes")
                    }
                    
                } else {
                    print("No saved forecast")
                }
            }
        }
    }
    
    /// Helper function to save forecast
    fileprivate func setOfflineData(forecast: OfflineForecast, name: String, type: String, dayTemp: Int, minTemp: Int, maxTemp: Int, currentTemp: Int) {
        
        forecast.name = name
        forecast.weatherType = type
        forecast.saveDate = Date()
        forecast.dayTemp = numericCast(dayTemp)
        forecast.minTemp = numericCast(minTemp)
        forecast.maxTemp = numericCast(maxTemp)
        forecast.currentTemp = numericCast(currentTemp)
    }
    
    /// Changes the background in response to forecast
    fileprivate func setupBackground(type: String) {
        // Configure view controllers background in response to weather information
        
        switch type {
        case "Clear":
            backgroundImage.image = UIImage(named: "forest_sunny")
            backgroundView.backgroundColor = UIColor(named: "sunny")
            offlineView.backgroundColor = UIColor(named: "sunny")
            if let colour = UIColor(named: "sunny") {
                contentViewColour = colour
            } else {
                contentViewColour = UIColor.green
            }
        case "Rain":
            backgroundImage.image = UIImage(named: "forest_rainy")
            backgroundView.backgroundColor = UIColor(named: "rainy")
            offlineView.backgroundColor = UIColor(named: "rainy")
            if let colour = UIColor(named: "rainy") {
                contentViewColour = colour
            } else {
                contentViewColour = UIColor.lightGray
            }
        case "Clouds":
            backgroundImage.image = UIImage(named: "forest_cloudy")
            backgroundView.backgroundColor = UIColor(named: "cloudy")
            offlineView.backgroundColor = UIColor(named: "cloudy")
            if let colour = UIColor(named: "cloudy") {
                contentViewColour = colour
            } else {
                contentViewColour = UIColor.systemGray
            }
        case "Snow":
            backgroundImage.image = UIImage(named: "forest_snowy")
            backgroundView.backgroundColor = UIColor(named: "snow")
            offlineView.backgroundColor = UIColor(named: "snow")
            if let colour = UIColor(named: "snow") {
                contentViewColour = colour
            } else {
                contentViewColour = UIColor.systemIndigo
            }
        case "Fog":
            backgroundImage.image = UIImage(named: "forest_foggy")
            backgroundView.backgroundColor = UIColor(named: "fog")
            offlineView.backgroundColor = UIColor(named: "fog")
            if let colour = UIColor(named: "fog") {
                contentViewColour = colour
            } else {
                contentViewColour = UIColor.darkGray
            }
        default:
            backgroundImage.image = UIImage(named: "forest_sunny")
            backgroundView.backgroundColor = UIColor(named: "sunny")
            offlineView.backgroundColor = UIColor(named: "sunny")
            if let colour = UIColor(named: "sunny") {
                contentViewColour = colour
            } else {
                contentViewColour = UIColor.green
            }
            print("Weather Type unaccounted for.")
        }
    }
    
    /// Function to format date
    fileprivate func dayOfWeek(date: Date) -> String? {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            return dateFormatter.string(from: date).capitalized
        }
    
    /// Function to control the activity indicator
    fileprivate func animateActivityIndicator(should: Bool) {
        self.offlineView.isHidden = true
        if should {
            DispatchQueue.main.async {
                self.activityIndicator.isHidden = false
                self.activityIndicator.startAnimating()
                self.hideViews(should: should)
            }
        } else {
            DispatchQueue.main.async {
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
                self.hideViews(should: should)
            }
        }
    }
    
    /// Function to show or hide views depending on availabilty of results
    fileprivate func hideViews(should: Bool) {
        if should {
            tableView.isHidden = true
            degreeLabel.isHidden = true
            weatherLabel.text = "Loading..."
            
            dayLabel.text = "..."
            minLabel.text = "..."
            maxLabel.text = "..."
            dayTempLabel.isHidden = true
            minTempLabel.isHidden = true
            maxTempLabel.isHidden = true
            
            symbolOne.isHidden = true
            symbolTwo.isHidden = true
            symbolThree.isHidden = true
            symbolFour.isHidden = true
        } else {
            tableView.isHidden = false
            degreeLabel.isHidden = false
            
            dayTempLabel.isHidden = false
            minTempLabel.isHidden = false
            maxTempLabel.isHidden = false
            dayLabel.text = "day"
            minLabel.text = "min"
            maxLabel.text = "max"
            
            symbolOne.isHidden = false
            symbolTwo.isHidden = false
            symbolThree.isHidden = false
            symbolFour.isHidden = false
        }
    }
    
    /// Geocoding to find city name from coordinates
    fileprivate func findCity(coordinates: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        let geoCoder = CLGeocoder()
        
        // Find the name of the location given its coordinates
        geoCoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                print("No Placemarks")
                return
            }
            
            if let city = placemark.locality {
                self.cityName = city
                self.navigationItem.title = self.cityName
            }
            
        }
    }
    
    /// Setup saved data
    fileprivate func setupFetchedResultsController() {
        // Find Objects with Location entity name
        let fetchRequest:NSFetchRequest<OfflineForecast> = OfflineForecast.fetchRequest()
        // Arrange the items in ascending order
        let sortDescriptor = NSSortDescriptor(key: #keyPath(OfflineForecast.name), ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: "offline")
        do {
            // Fetch results
            try fetchedResultsController.performFetch()
        } catch {
            print("Error with Offline data")
            showFailure(message: "Could not retrieve saved weather information")
        }
    }
}

// MARK: TableView Methods

extension HomeController: UITableViewDataSource {
    
    /// Determine number of items table view should display
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fiveDayForecast.count
    }
    
    /// Configure each table view cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherViewCell", for: indexPath) as! WeatherViewCell
        let item = fiveDayForecast[indexPath.row]
        cell.contentView.backgroundColor = contentViewColour
        
        // Configure weather symbol depending on the weather type
        switch item.weatherType {
        case "Clear":
            cell.weatherSymbol.image = UIImage(named: "clear")
        case "Rain":
            cell.weatherSymbol.image = UIImage(named: "rain")
        case "Clouds":
            cell.weatherSymbol.image = UIImage(named: "clouds")
        case "Fog":
            cell.weatherSymbol.image = UIImage(named: "fog")
        case "Snow":
            cell.weatherSymbol.image = UIImage(named: "snow")
        default:
            cell.weatherSymbol.image = UIImage(named: "clear")
        }
        
        cell.dayLabel.text = item.day
        cell.degreeLabel.text = String(item.temperature)
        
        if indexPath.row == 0 {
            cell.dayLabel.text = "Tomorrow"
        }
        
        return cell
    }
    
}

// MARK: Location Manager Functions

extension HomeController: CLLocationManagerDelegate {
    
    /// Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        if offlineCheck == false {
            getCurrentWeather(coordinates: location.coordinate)
            findCity(coordinates: location.coordinate)
            coordinate = location.coordinate
        }
    }
    
    /// Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            showPermissionMessage()
            print("Location access was restricted.")
        case .denied:
            showPermissionMessage()
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
            weatherLabel.text = "..."
            print("User denied access to location.")
        case .notDetermined:
            print("Location status not determined.")
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways:
            print("Location status is alright.")
            manager.requestLocation()
            manager.desiredAccuracy = kCLLocationAccuracyBest
            animateActivityIndicator(should: true)
            
        case .authorizedWhenInUse:
            print("Location status is OK.")
            manager.requestLocation()
            manager.desiredAccuracy = kCLLocationAccuracyBest
            animateActivityIndicator(should: true)
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

