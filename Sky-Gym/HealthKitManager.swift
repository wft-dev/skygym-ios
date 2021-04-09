
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
    let interval :DateComponents = {
        var interVal = DateComponents()
        interVal.day = 1
        return interVal
    }()
    
    let df:DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMM d, yyyy"
        df.timeZone = .none
        return df
    }()
    
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
    
    func getSteps(for sampleType:HKQuantityType, start: Date, end: Date,completion:@escaping ([HealthStatics]) -> Void) {
        let stepPredicate = HKSampleQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        
        let stepQuery = HKStatisticsCollectionQuery(quantityType: sampleType , quantitySamplePredicate: stepPredicate, options: .cumulativeSum, anchorDate: end, intervalComponents: interval)
        
        stepQuery.initialResultsHandler = {
            (query,result,err ) in
            
            if err == nil {
                
                if let myResult = result {
                    var stepData:[HealthStatics] = []
                    
                    myResult.enumerateStatistics(from: start, to: end) { (statics, stop) in
                        if let quantity = statics.sumQuantity() {
                            let steps = Int(quantity.doubleValue(for: .count()))
                            stepData.append(HealthStatics(value: "\(steps)", date: "\(self.df.string(from: statics.endDate))"))
                        }
                    }
                    completion(stepData.reversed())
                }
            }
            HKHealthStore().execute(stepQuery)
        }
    }
    
    func getHeartRate(for sampleType:HKQuantityType,start:Date,end:Date,completion:@escaping ([HealthStatics]) -> Void ) {
        var heartRateData:[HealthStatics] = []
        let heartRatePredicate = HKSampleQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        
        let heartQuery = HKSampleQuery(sampleType: sampleType, predicate: heartRatePredicate, limit: 10, sortDescriptors: nil) { (query, result, err) in
            if err == nil {
                
                if let heartRateResult = result {
                    for singleHeartRateResult in heartRateResult {
                        let value = singleHeartRateResult as! HKQuantitySample
                        heartRateData.append(HealthStatics(value: "\(value.quantity.doubleValue(for: HKUnit(from: "count/min")))", date: "\(self.df.string(from: value.endDate))"))
                    }
                    completion(heartRateData.reversed())
                }
                
            }
            
        }
        
        HKHealthStore().execute(heartQuery)
        
    }
    
}
