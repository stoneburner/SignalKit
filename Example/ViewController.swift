//
//  ViewController.swift
//  Example
//
//  Created by Alexander Kasimir on 09.07.2019.
//  Copyright © 2019 SignalKit. All rights reserved.
//

import UIKit
import SignalKit

// MARK: - ViewController

/// The ViewController
class ViewController: UIViewController {

    // MARK: Properties
    
    /// The Label
    lazy var label: UILabel = {
        let label = UILabel()
        label.text = "🚀\nSignalKit\nExample"
        label.font = .systemFont(ofSize: 25, weight: .semibold)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        return label
    }()
    
    // MARK: View-Lifecycle
    
    /// View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white

        let signal = SignalConnection(a: .vccPos(volt: 2.0), b: .vccPos(volt: 2.0))
        print("\(signal.isValid)")
    }
    
    /// LoadView
    override func loadView() {
        self.view = self.label
    }

}
