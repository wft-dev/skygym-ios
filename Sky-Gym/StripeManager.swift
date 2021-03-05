//
//  StripeManager.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 05/03/21.
//  Copyright © 2021 KP iOSDev. All rights reserved.
//

import Foundation
import Stripe
import Alamofire



class StripeManager: NSObject {
    static let shared = StripeManager()
    private override init() {}
    
    let stripeClient = STPAPIClient.shared
    
    private lazy var baseURL:URL = {
        guard var url = URL(string: AppManager.shared.getBaseURLStr()) else {
            fatalError("Invalid url")
        }
        url.appendPathComponent("create_payment_intent")
        return url
    }()
    
    
    func completePayment(token:STPToken,amount:Int, completion:@escaping (PaymentResult) -> Void) {
        let params:[String:Any] = [
            "token": token.tokenId,
            "amount": amount,
            "currency": AppManager.shared.getDefaultCurrency(),
            "description": AppManager.shared.getDefaultDescription()
        ]
        
        AF.request(baseURL,method: .post,parameters: params)
            .validate(statusCode: 200..<300)
        .responseString(completionHandler: {
            response in
            switch response.result {
            case .success(_):
                completion(.success)
            case let .failure(err):
                completion(.failure(err))
            }
        })
    }
    
    func createTokenForPayment(cardParmas:STPCardParams,handler:@escaping (STPToken?,Error?) -> Void) {
        stripeClient.createToken(withCard: cardParmas, completion: {
            (token,err) in
            guard let tokenForPayment:STPToken = token else {
                return
            }
            handler(tokenForPayment,err)
        })
    }
    
}
