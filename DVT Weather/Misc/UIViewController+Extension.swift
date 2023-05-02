//
//  UIViewController+Extension.swift
//  DVT Weather
//
//  Created by Oneh Zinde on 2023/04/23.
//

import Foundation
import UIKit
import Network
import CoreLocation

extension UIViewController {
    
    /// Alert controller displayed when there is an error.
    func showFailure(message: String) {
        DispatchQueue.main.async {
            let alertVC = UIAlertController(title: "Something Went Wrong", message: message, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            alertVC.popoverPresentationController?.sourceView = self.view
            // Presentation of the alert
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    /// Alert controller displayed when there is an error.
    func showPermissionMessage() {
        DispatchQueue.main.async {
            let alertVC = UIAlertController(title: "Permission Required", message: "Please grant permission to access your current location to view weather information. This can be changed in settings.", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            alertVC.popoverPresentationController?.sourceView = self.view
            // Presentation of the alert
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    /// Function that monitors the network
    func monitorNetwork() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = {
            path in
            if path.status != .satisfied {
                
                DispatchQueue.main.async {
                    self.showFailure(message: "Please check your network connection.")
                }
            } else {
                print("There is an internet connection")
            }
            
        }
        
        let queue = DispatchQueue(label: "Network")
        monitor.start(queue: queue)
    }
    
    func tapVibe() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
}

protocol ResultsViewControllerDelegate: AnyObject {
    func didTapPlace(with coordinates: CLLocationCoordinate2D, name: String)
}
