//
//  SettingsViewController.swift
//  CustomCamera
//
//  Created by Julio Brazil Bellucci Lopes on 14/09/20.
//  Copyright © 2020 Zero2Launch. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    var doneAction: (Settings) -> Void
    var settings: Settings
    
    lazy var alphaSlider: UISlider = {
        let slider = UISlider(frame: .zero)
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.setValue(Float(self.settings.alpha), animated: true)
        
        slider.addTarget(self, action: #selector(handleSlider), for: .valueChanged)
        
        return slider
    }()
    
    lazy var stack: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        stack.axis = .vertical
        stack.spacing = 16
        
        return stack
    }()
    
    init(_ currentSettings: Settings, dismissAction: @escaping (Settings)->Void) {
        self.settings = currentSettings
        self.doneAction = dismissAction
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = .systemBackground
        } else {
            self.view.backgroundColor = .white
        }

        stack.addArrangedSubview(UILabel(text: "Image Opacity"))
        stack.addArrangedSubview(alphaSlider)
        self.view.addSubview(stack)
        
        let margins = view.layoutMarginsGuide
        
        stack.topAnchor.constraint(equalTo: margins.topAnchor, constant: 16).isActive = true
        stack.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -16).isActive = true
        stack.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 16).isActive = true
        stack.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -16).isActive = true
        
//        self.alphaSlider.widthAnchor.constraint(equalTo: self.stack.widthAnchor).isActive = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.doneAction(settings)
    }
    
    @objc func handleSlider() {
        self.settings.alpha = CGFloat(self.alphaSlider.value)
    }

}

extension UILabel {
    convenience init(text: String) {
        self.init()
        
        self.text = text
    }
}
