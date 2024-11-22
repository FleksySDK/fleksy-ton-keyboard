//  WalletView.swift
//  KeyMetaApp
//
//  Copyright © 2024 Thingthing. All rights reserved.
//
//

import SwiftUI
import Foundation


struct DataValidation: Codable {
    let sessionId: String
    let text: String
}


func loadDataValidation() -> DataValidation?{
    
    // Obtain the shared container URL
    if let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.thingthing.KeyMeta") {
        
        let prefix = "logger_typing_validate"
        
        let pathLogger = "Resources/" + prefix + ".log"
        let dataURL = sharedContainerURL.appendingPathComponent(pathLogger)
        do {
            // Load the data from the file
            let data = try Data(contentsOf: dataURL)
                
            // Decode the JSON into the specified type
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(DataValidation.self, from: data)
            return decodedData
         } catch {
             print("Failed to decode \(error)")
            return nil
         }
    }
    return nil
}


struct WalletView: View {
        
    var body: some View {
        VStack{
            
            Text("Connect your Wallet")
                .padding()
            WebView(url: URL(string:"https://www.google.com")!)
                .frame(height:200)
                .border(Color.gray)
                .cornerRadius(5.0)
            Spacer()
            Button(action: {
                print("Button Example Tapped")
                let data = loadDataValidation()
                print("data loaded")
            }) {
                Text("This is a sample btn")
                     .foregroundColor(.white)
                     .padding()
                     .background(Color.blue)
                     .cornerRadius(8)
                }
        }
    }
}
