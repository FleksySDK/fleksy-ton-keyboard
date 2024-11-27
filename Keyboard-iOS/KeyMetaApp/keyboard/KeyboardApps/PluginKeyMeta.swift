//  PluginKeyMeta.swift
//  Keyboard
//
//  Copyright © 2024 Thingthing. All rights reserved.
//
//

import UIKit
import FleksyAppsCore


class PluginKeyMeta : KeyboardApp{
    
    let appId = "keymeta.coins"
    var configuration: AppConfiguration?
    var listener: AppListener?
    var metaView: UIView?
    
    func initialize(listener: AppListener, configuration: AppConfiguration) {
        self.listener = listener
        self.configuration = configuration
    }
    
    func dispose() {
        listener = nil
        configuration = nil
    }
    
    ///
    /// From the keyboardViewController you can decide when to call this method,
    /// which will show the view that you send here.
    ///
    func open(viewMode: KeyboardAppViewMode, theme: AppTheme) -> UIView? {
        if metaView == nil {
            createMetaView()
        }
        return metaView
    }
    
    /// This is gonna be called automatically by the system when you close the View.
    func close() {
        // Free all references created from the open()
        metaView = nil
    }
    
    func onThemeChanged(_ theme: AppTheme) {
        // Change the color of the theme if you want
        //
    }
    
    func appIcon() -> UIImage? {
        // Add any image if you want.
        return UIImage(named: "IconK")
    }
    
    @MainActor @objc func hideMyself() {
        listener?.hide()
    }
    
    func createMetaView() {
        
        let metaView = UIView()
        
        // Configure the example View
        metaView.backgroundColor = UIColor.init(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1.0)
        
        // Add a simple close button
        let btnClose = UIButton()
        btnClose.setImage(UIImage(named: "ArrowBack"), for: .normal)
        btnClose.imageView?.contentMode = .scaleAspectFit
        btnClose.translatesAutoresizingMaskIntoConstraints = false
        
        metaView.addSubview(btnClose)
        
        // Add constraints for cosmetics
        NSLayoutConstraint.activate([
            btnClose.leadingAnchor.constraint(equalTo: metaView.leadingAnchor, constant: 5),
            btnClose.topAnchor.constraint(equalTo: metaView.topAnchor, constant: 10),
            btnClose.widthAnchor.constraint(equalToConstant: 40),
            btnClose.heightAnchor.constraint(equalToConstant: 25)
        ])

        btnClose.addTarget(self, action: #selector(hideMyself), for: .touchUpInside)
        
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.darkGray
        label.font = UIFont.boldSystemFont(ofSize: 60.0)
        label.layer.cornerRadius = 75
        label.layer.borderWidth = 2.5
        label.layer.shadowColor = UIColor.lightGray.cgColor
        label.layer.borderColor = UIColor.darkGray.cgColor
        label.layer.masksToBounds = true
    
        label.text = "2.0"
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let labelCoin = UILabel()
        labelCoin.textAlignment = .left
        labelCoin.textColor = UIColor.darkGray
        labelCoin.font = UIFont.boldSystemFont(ofSize: 14.0)
    
        labelCoin.text = "KMC"
        labelCoin.translatesAutoresizingMaskIntoConstraints = false
        
        
        metaView.addSubview(label)
        metaView.addSubview(labelCoin)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: metaView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: metaView.centerYAnchor),
            label.widthAnchor.constraint(equalToConstant: 150),
            label.heightAnchor.constraint(equalToConstant: 150),
            labelCoin.widthAnchor.constraint(equalToConstant: 40),
            labelCoin.heightAnchor.constraint(equalToConstant: 20),
            labelCoin.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 0.0),
            labelCoin.centerYAnchor.constraint(equalTo: metaView.centerYAnchor, constant: 50.0)
        ])
        
        // Add anything else here.
        self.metaView = metaView
    }
    
    
    
}
