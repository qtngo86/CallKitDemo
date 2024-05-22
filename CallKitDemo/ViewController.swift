//
//  ViewController.swift
//  CallKitDemo
//
//  Created by Quang Tuan NGO on 2024-05-21.
//

import UIKit

class ViewController: UIViewController {
    
    private var makeIncomingCallButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        makeIncomingCallButton = UIButton(type: .system)
        guard let button = makeIncomingCallButton else { return }
        
        button.addTarget(self, action: #selector(createIncomingCall), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Make Incoming Call", for: .normal)
        view.addSubview(button)
        
        let widthConstraint = NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0.5, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50)
        let xConstraint = NSLayoutConstraint(item: button, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0)
        let yConstraint = NSLayoutConstraint(item: button, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0)
        view.addConstraints([widthConstraint, heightConstraint, xConstraint, yConstraint])
    }
    
    @objc private func createIncomingCall() {
        AppDelegate.shared.displayIncomingCall(
            uuid: UUID(),
            handle: "TestHandle",
            hasVideo: false) { _ in }
    }
}

