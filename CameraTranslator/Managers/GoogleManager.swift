//
//  GoogleTranslatorManager.swift
//  CameraTranslator
//
//  Created by Miroslav Danazhiev on 11/7/17.
//  Copyright © 2017 Miroslav Danazhiev. All rights reserved.
//

import UIKit

public struct GoogleTranslateParams {
    
    var sourceLang: String
    var targetLang: String
    var text: String
}

typealias RequestCompletionHandler = ((_ result: Any?, _ error: Error?) -> Void)!

class GoogleManager: NSObject {
    static let sharedInstance = GoogleManager()
    static let apiKey = "AIzaSyAipMwdz2rIND7o73TNfxm03W_ccdTlK-k"
    fileprivate let decoder = JSONDecoder()
    func translate(params: GoogleTranslateParams, callback: @escaping (_ translatedText: String?) -> ()) {
        
        if let url = GoogleResponse.endpointForParams(params) {
            performRequest(endpoint: url) { [weak self] (result, error) in
                if let data = result as? Data {
                    
                    do {
                        let response = try self?.decoder.decode(GoogleResponse.self, from: data)
                        callback(response?.data.translations?.first?.translatedText)
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    func supportedLanguages(callback: @escaping (_ languages: [String]?) -> ()) {
        if let url = GoogleResponse.endpointForSupportedLanguages() {
            performRequest(endpoint: url) { [weak self] (result, error) in
                if let data = result as? Data {
                    
                    do {
                        let response = try self?.decoder.decode(GoogleResponse.self, from: data)
                        callback(response?.data.supportedLanguages)
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    func detectLanguageFor(text: String, callback: @escaping (_ translatedText: String?) -> ()) {
        if let url = GoogleResponse.endpointForDetectingLangOfText(text: text) {
            performRequest(endpoint: url, complition: { [weak self] (result, error) in
                if let data = result as? Data {
                    
                    do {
                        let response = try self?.decoder.decode(GoogleResponse.self, from: data)
                        callback(response?.data.detectedLanguage)
                    } catch {
                        print(error)
                    }
                }
            })
        }
    }
    
    fileprivate func performRequest(endpoint: URL, complition: RequestCompletionHandler) {
        
        let httprequest = URLSession.shared.dataTask(with: endpoint, completionHandler: { (data, response, error) in
            
            guard error == nil, (response as? HTTPURLResponse)?.statusCode == 200 else {
                print("Something went wrong: \(String(describing: error?.localizedDescription))")
                return
            }
            
            guard let responseData = data else {
                print("Error: did not receive data")
                
                complition(nil, error)
                return
            }
            
            complition(responseData, nil)
        })
        
        httprequest.resume()
    }
    
}

