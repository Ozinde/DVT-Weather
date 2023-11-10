//
//  PhotoFilterViewController.swift
//  DVT Weather
//
//  Created by Oneh Zinde on 2023/11/09.
//

import UIKit
import AVFoundation

class PhotoFilterViewController: UIViewController {
    
    /// Variables
    private let manager = FilterManager()
    var selectedRestaurantID: Int?
    var data = Data()
    private var thumbnail: UIImage?
    private var finalImage: UIImage?
    private var filters: [ImageFilterItem] = []
    
    /// Outlets
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tickButton: UIButton!
    
    /// Actions
    @IBAction func closeTapped(_ sender: UIButton) {
        tapVibe()
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func saveTapped(_ sender: UIButton) {
        tapVibe()
        guard let image = finalImage else {
            print("A")
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(didSaveImage(_:withError:contextInfo:)), nil)
    }
    
    // MARK: Lifecycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupCollectionView()
        
        guard let image = UIImage(data: data) else {
            return
        }
        
        filters = manager.fetch()
        mainImageView.image = image
        finalImage = image
        thumbnail = image.preparingThumbnail(of: CGSize(width: 100, height: 100))
        collectionView.reloadData()
    }
    
    // MARK: Functions
    
    /// Function that saves image to photo library
    @objc func didSaveImage(_ image: UIImage, withError error: Error?, contextInfo: UnsafeRawPointer) {
      guard error == nil else { return }
      saveSuccessAlert()
    }
    
    /// Function used for filter collectionView setup
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 7
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    /// Alert that is displayed when photo is saved successfully
    func saveSuccessAlert() {
        let controller = UIAlertController(title: "Success", message: "This image has been added to your library", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default){ [weak self]
            action in
            
            self?.dismiss(animated: false, completion: nil)
        }
        
        controller.addAction(okAction)
        controller.popoverPresentationController?.sourceView = self.view
        self.present(controller, animated: true, completion: nil)
    }
}

// MARK: CollectionView Methods

extension PhotoFilterViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filterCell", for: indexPath) as! FilterCell
        let filterItem = filters[indexPath.row]
        // Set collection of filters
        if let thumbnail = thumbnail {
            cell.set(filterItem: filterItem, imageForThumbnail: thumbnail)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        let filterItem = self.filters[indexPath.row]
        filterMainImage(filterItem: filterItem)
    }
}

extension PhotoFilterViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewHeight = collectionView.frame.size.height
        let topInset = 14.0
        let cellHeight = collectionViewHeight - topInset
        return CGSize(width: 150, height: cellHeight)
    }
}

// MARK: Image Filtering Delegate
extension PhotoFilterViewController: ImageFiltering {
    
    func filterMainImage(filterItem: ImageFilterItem) {
        guard let image = UIImage(data: data), let filter = filterItem.filter else {
            return
        }
        
        // Determine if filter should be applied to photo
        if filter != "None" {
            mainImageView.image = self.apply(filter: filter, originalImage: image)
            finalImage = self.apply(filter: filter, originalImage: image)
        } else {
            mainImageView.image = image
        }
    }
}
