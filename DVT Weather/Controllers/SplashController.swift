//
//  SplashController.swift
//  DVT Weather
//
//  Created by Oneh Zinde on 2023/04/27.
//

import UIKit

class SplashController: UIViewController {
    
    /// Outlets
    @IBOutlet weak var weatherLabel: UILabel!
    
    // MARK: Lifecycle Functions
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Perform animation
        animateView(desiredView: weatherLabel)
    }
    
    // MARK: Functions
    
    /// Present Home Screen
    func presentHome() {
        
        guard let storyboard = storyboard else {
            return
        }
        
        let vc = storyboard.instantiateViewController(withIdentifier: "TabController")
        vc.modalTransitionStyle = .flipHorizontal
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    func animateView(desiredView: UIView) {
        UIView.animate(withDuration: 1.5, animations: {
            desiredView.alpha = 1
        }) { _ in
            self.presentHome()
        }
    }
}
