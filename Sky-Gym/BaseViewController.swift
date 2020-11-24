//
//  BaseViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 28/09/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import UIKit
import SWRevealViewController

class BaseViewController: UIViewController {

     var appDelgate:AppDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
       //assignbackground()
        appDelgate = UIApplication.shared.delegate as? AppDelegate
    }
    
    func assignbackground(){
                let background = UIImage(named: "Wh-bg.png")
                var imageView : UIImageView!
                imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleToFill
                imageView.clipsToBounds = true
                imageView.image = background
                imageView.center = view.center
                view.addSubview(imageView)
                self.view.sendSubviewToBack(imageView)
            }
    
    func setBackAction(toView:CustomNavigationBar) {
        toView.leftArrowBtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
    }
    @objc func backAction() {
        dismiss(animated: true, completion: nil)
    }
    
    

        func adjustFontSizeFor(label:UILabel,initialSize:CGFloat,increasingScaleBy:CGFloat, withBold:Bool) {
            let deviceType = UIDevice.current.deviceType
            var  fontSize = initialSize
            switch deviceType {
             
            case .iPhone4_4S:
                label.font = withBold == true ?  UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
//                print("iPhone4_4S")
//                print("fontSize : \(fontSize)")
             
            case .iPhones_5_5s_5c_SE:
                 fontSize += increasingScaleBy
             label.font = withBold == true ?  UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
//                print("iPhones_5_5s_5c_SE")
//                print("fontSize : \(fontSize)")
             
            case .iPhones_6_6s_7_8:
                fontSize += (increasingScaleBy*2)
          label.font = withBold == true ?  UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
//                print("iPhones_6_6s_7_8")
//                print("fontSize : \(fontSize)")
             
            case .iPhones_6Plus_6sPlus_7Plus_8Plus:
                fontSize += (increasingScaleBy*2)
         label.font = withBold == true ?  UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
//                print("iPhones_6Plus_6sPlus_7Plus_8Plus")
//                print("fontSize : \(fontSize)")
             
            case .iPhoneX:
                fontSize += (increasingScaleBy*3)
              label.font = withBold == true ?  UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
//                print("iPhoneX")
//                print("fontSize : \(fontSize)")
             
            default:
                fontSize += (increasingScaleBy*4)
                label.font = withBold == true ?  UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
//                print("iPad or Unkown device")
//                print("fontSize : \(fontSize)")
             
            }
        }
    
    
    func setAttandanceTableCellView(tableCellView:UIView)  {
     tableCellView.layer.cornerRadius = 20.0
       tableCellView.layer.borderWidth = 1.0
       tableCellView.layer.borderColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1).cgColor
        tableCellView.clipsToBounds = true
    }
    
  
    
    
}

extension UIDevice {
    enum DeviceType: String {
        case iPhone4_4S = "iPhone 4 or iPhone 4S"
        case iPhones_5_5s_5c_SE = "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE"
        case iPhones_6_6s_7_8 = "iPhone 6, iPhone 6S, iPhone 7 or iPhone 8"
        case iPhones_6Plus_6sPlus_7Plus_8Plus = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus"
        case iPhoneX = "iPhone X"
        case unknown = "iPadOrUnknown"
    }
 
    var deviceType: DeviceType {
        switch UIScreen.main.nativeBounds.height {
        case 960:
            return .iPhone4_4S
        case 1136:
            return .iPhones_5_5s_5c_SE
        case 1334:
            return .iPhones_6_6s_7_8
        case 1920, 2208:
            return .iPhones_6Plus_6sPlus_7Plus_8Plus
        case 2436:
            return .iPhoneX
        default:
            return .unknown
        }
    }
}
