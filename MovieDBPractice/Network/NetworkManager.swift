//
//  NetworkManager.swift
//  MovieDBPractice
//
//  Created by Alwan on 06/11/24.
//

import Alamofire
import SwiftyJSON
import RxSwift

class NetworkManager {
    
    static let shared = NetworkManager()
    var sessionManager = SessionManager()
    
    private init() {}
    
    // Rx
    func rxConnectApi(url: String, method: HTTPMethod = .get, parameters: [String: Any]) -> Observable<JSON?> {
        return Observable.create { observer in
            
            self.sessionManager.request(url, method: method, parameters: parameters)
                .validate()
                .responseJSON { response in
                    print("response = \(response)")
                    if response.result.isSuccess {
                        if let data = response.result.value {
                            let jsonObj = JSON(data)
                            observer.onNext(jsonObj)
                            observer.onCompleted()
                        }
                        else {
                            print("handle response.result.value == nil")
                        }
                    }
                    else {
                        if let error = response.result.error {
                            observer.onError(error)
                        }
                        else {
                            print("handle !response.result.isSuccess && response.result.error == nil")
                        }
                    }
                }
            
            return Disposables.create()
        }
    }
    
    // nonRx
    func connectApi(url: String, method: HTTPMethod = .get, parameters: [String: Any], completion:@escaping (_ jsonObj: JSON?) -> Void) {
        sessionManager.request(url, method: method, parameters: parameters)
            .validate()
            .responseJSON { response in
                print("response = \(response)")
                if response.result.isSuccess {
                    if let data = response.result.value {
                        let jsonObj = JSON(data)
                        completion(jsonObj)
                    }
                    else {
                        completion(nil)
                    }
                }
                else {
                    completion(nil)
                }
                
            }
    }
    
}
