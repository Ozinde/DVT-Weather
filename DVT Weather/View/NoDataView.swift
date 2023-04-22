//
//  NoDataView.swift
//  DVT Weather
//
//  Created by Oneh Zinde on 2023/04/24.
//

import Foundation
import UIKit

class NoDataView: UIView {
    private var view: UIView!
    
    /// Outlets
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    /// Load the view
    func loadViewFromNib() -> UIView {
        let nib = UINib(nibName: "NoDataView", bundle: Bundle.main)
        let view = nib.instantiate(withOwner: self, options: nil) [0] as! UIView
        return view
    }
    
    /// Configure the view once loaded
    func setupView() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    /// Configure view title and description
    func set(title: String, desc: String) {
        titleLabel.text = title
        descLabel.text = desc
    }
}

