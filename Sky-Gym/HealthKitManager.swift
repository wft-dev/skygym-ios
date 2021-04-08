
//
//  HealthKitManager.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 08/04/21.
//  Copyright © 2021 KP iOSDev. All rights reserved.
//

import Foundation
import HealthKit

class HealthKitManager: NSObject {
    static let shared:HealthKitManager = HealthKitManager()
    private override init() {}
    
    let healthKitStore:HKHealthStore = HKHealthStore()
    
    func healthKitRequestAuthorization(completion:@escaping (Bool) -> Void ) {
        if HKHealthStore.isHealthDataAvailable()  {
            let stepsAuthorizaiton = HKObjectType.quantityType(forIdentifier: .stepCount)!
            let heartRateAuthorization = HKObjectType.quantityType(forIdentifier: .heartRate)!
            
            self.healthKitStore.requestAuthorization(toShare: [stepsAuthorizaiton,heartRateAuthorization], read: [stepsAuthorizaiton,heartRateAuthorization]) { (flag, err) in
                completion(flag)
            }
            
        }else {
            completion(false)
        }
    }
    
    func getSteps(for sampelType:HKSampleType, completion:@escaping () -> Void) {
        
        
    
    }
    
}
