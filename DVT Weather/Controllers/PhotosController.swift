//
//  ViewController.swift
//  DVT Weather
//
//  Created by Oneh Zinde on 2023/11/09.
//

import UIKit
import CoreLocation
import Network

class PhotosController: UIViewController {
    
    /// Variables
    var coordinate = CLLocationCoordinate2D()
    var cityname = String()
    var photos = [Data]() {
        didSet {
            if photos.count == 5 {
                animateActivityIndicator(should: false)
                cityLabel.text = cityname + "\nPhotos"
                collectionView.reloadData()
            }
        }
    }
    
    /// Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    /// Actions
    @IBAction func closeTapped(_ sender: UIButton) {
        tapVibe()
        self.dismiss(animated: false, completion: nil)
    }
    
    // MARK: Lifecycle Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = PhotosController.createLayout()
        checkNetwork()
        animateActivityIndicator(should: true)
    }
    
    // MARK: Functions
    
    /// Function that monitors the network
    func checkNetwork() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = {
            path in
            if path.status != .satisfied {
                DispatchQueue.main.async {
                    //Hide activity animator and display message if there is no network
                    self.animateActivityIndicator(should: false)
                    self.showFailure(message: "Please check your network connection.")
                    
                }
            } else {
                print("There is an internet connection")
                self.getPhotos(coordinates: self.coordinate)
            }
        }
        
        let queue = DispatchQueue(label: "Network")
        monitor.start(queue: queue)
    }
    
    /// Function to control the activity indicator
    fileprivate func animateActivityIndicator(should: Bool) {
        if should {
            DispatchQueue.main.async {
                self.activityIndicator.isHidden = false
                self.activityIndicator.startAnimating()
            }
        } else {
            DispatchQueue.main.async {
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    /// Functions that configures the compositional layout
    static func createLayout() -> UICollectionViewLayout {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(2/3), heightDimension: .fractionalHeight(1)))
        
        let topVerticalItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5)))
        
        let bottomVerticalItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(0.5)))
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        topVerticalItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        bottomVerticalItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1)), subitem: topVerticalItem, count: 2)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5)), subitems: [item, verticalGroup])
        
        let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5)), subitem: bottomVerticalItem, count: 2)
        
        let finalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(4/5)), subitems: [group, horizontalGroup])
        
        let section = NSCollectionLayoutSection(group: finalGroup)
        
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    /// Function that retrieves weather information
    fileprivate func getPhotos(coordinates: CLLocationCoordinate2D) {
        
        Task {
            do {
                // API call that requests photo onjects with URL
                let photo = try await FlickrClient.getPhotoURL(latitude: coordinates.latitude, longitude: coordinates.longitude)
                
                for item in photo.photos.photo {
                    // Conversion of URL string into URL Objects
                    if let imageURL = URL(string: item.url) {
                        getPhotoData(url: imageURL)
                    } else {
                        showFailure(message: "Photo URL unavailable.")
                    }
                }
               
                // Catch Block
            } catch PhotoRequestErrors.invalidURL {
                animateActivityIndicator(should: false)
                showFailure(message: "An incorrect URL was used.")
            } catch PhotoRequestErrors.couldNotGetPhotos {
                animateActivityIndicator(should: false)
                showFailure(message: "Photo information could not be found.")
            } catch PhotoRequestErrors.couldNotGetPhotoURL {
                animateActivityIndicator(should: false)
                showFailure(message: "Photo information unavailable.")
            } catch {
                animateActivityIndicator(should: false)
                showFailure(message: "An unknown error occured.")
            }
        }
    }
    
    /// Function that retrieves photo data
    fileprivate func getPhotoData(url: URL) {
        Task {
            do {
                //API call that downloads photo data from the image URL
                let photo = try await FlickrClient.getPhotoData(url: url)
                photos.append(photo)
            }
            
            // Catch Block
            catch PhotoRequestErrors.couldNotGetPhotoData {
                animateActivityIndicator(should: false)
                showFailure(message: "An incorrect URL was used.")
            } catch {
                animateActivityIndicator(should: false)
                showFailure(message: "An unknown error occured.")
            }
        }
    }
}

// MARK: CollectionView Methods

extension PhotosController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photo = photos[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photo", for: indexPath) as! PhotoViewCell
        cell.setPhoto(displaying: photo)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        let photo = photos[indexPath.row]
        // Segue to filter ViewController
        let vc = storyboard?.instantiateViewController(withIdentifier: "FilterController") as! PhotoFilterViewController
        vc.data = photo
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
        
}

