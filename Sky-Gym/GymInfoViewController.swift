//
//  GymInfoViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 24/12/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import UIKit
import MapKit
import SVProgressHUD


class GymInfoViewController: UIViewController {
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var gymNameLabel: UILabel!
    @IBOutlet weak var gymTimingLabel: UILabel!
    @IBOutlet weak var gymDaysLabel: UILabel!
    @IBOutlet weak var gymAddressLabel: UILabel!
    @IBOutlet weak var gymOwnerNameLabel: UILabel!
    @IBOutlet weak var gymOwnerPhoneNoLabel: UILabel!
    @IBOutlet weak var gymOwnerAddressLabel: UILabel!
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var myMapView: MKMapView!
    @IBOutlet weak var fullMapViewContainer: UIView!
    @IBOutlet weak var fullMapView: MKMapView!
    
    
    var menuBtn:UIButton = {
        let menuBtn = UIButton()
        menuBtn.setImage(UIImage(named: "icons8-menu-24"), for: .normal)
        menuBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        return menuBtn
    }()
    
    var leftBtn:UIButton = {
        let leftBtn = UIButton()
        leftBtn.setImage(UIImage(named: "left-arrow"), for: .normal)
        leftBtn.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        leftBtn.heightAnchor.constraint(equalToConstant: 20).isActive = true
        leftBtn.widthAnchor.constraint(equalToConstant: 20).isActive = true
        return leftBtn
    }()
    
//    lazy private var customAnnotationView :CustomAnnotation = {
//        var customAnnotationView = Bundle.main.loadNibNamed("CustomAnnotationView", owner: self, options: nil)?.first as! CustomAnnotation
//        customAnnotationView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
//        return customAnnotationView
//    }()
    
    var spaceBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    var stackView:UIStackView? = nil
    var location:CLLocationCoordinate2D? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGymInfoUI()
    }
    
    func setGymInfoNavigationBar(title:String,leftNavigationbtn:UIButton)  {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        let title = NSAttributedString(string: title , attributes: [
            NSAttributedString.Key.font :UIFont(name: "Poppins-Medium", size: 22)!,
        ])
        let titleLabel = UILabel()
        titleLabel.attributedText = title
        self.navigationController?.navigationBar.topItem?.titleView = titleLabel
        stackView = UIStackView(arrangedSubviews: [spaceBtn,leftNavigationbtn])
        stackView?.widthAnchor.constraint(equalToConstant: 40).isActive = true
        self.navigationItem.setLeftBarButton(UIBarButtonItem(customView: stackView!), animated: true)
    }
    
    func setGymInfoUI() {
        menuBtn.addTarget(self, action: #selector(menuChange), for: .touchUpInside)
        leftBtn.addTarget(self, action: #selector(showFullMap), for: .touchUpInside)
        
        setGymInfoNavigationBar(title: "Gym Info", leftNavigationbtn: menuBtn)
        self.fetchGymInfo(gymID: AppManager.shared.gymID)

        mapContainerView.layer.borderColor = UIColor.lightGray.cgColor
        mapContainerView.layer.borderWidth = 1.0
        mapContainerView.isUserInteractionEnabled = true
        mapContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showFullMap)))
        
        myMapView.delegate = self
        fullMapView.delegate = self

        myMapView.tag = 0
        fullMapView.tag = 1
        
        myMapView.isUserInteractionEnabled = false
        
    }
    
    @objc func showFullMap(){
        if mainScrollView.isHidden == false {
            mainScrollView.isHidden = true
            mainScrollView.alpha = 0.0
            fullMapViewContainer.isHidden = false
            fullMapViewContainer.alpha = 1.0
            
           setGymInfoNavigationBar(title: "Gym Location Map", leftNavigationbtn: leftBtn)
        }else {
            mainScrollView.isHidden = false
            mainScrollView.alpha = 1.0
            fullMapViewContainer.isHidden = true
            fullMapViewContainer.alpha = 0.0
            
            setGymInfoNavigationBar(title: "Gym Info", leftNavigationbtn: menuBtn)
            self.fetchGymInfo(gymID: AppManager.shared.gymID)
        }
    }
    
    @objc func menuChange(){
        AppManager.shared.appDelegate.swRevealVC.revealToggle(self)
    }
    
    func setupPin(address:String)  {
        DispatchQueue.global(qos: .default).async {
            let location = self.getCoordinatesFromAddress(map: self.myMapView, address: address)
            
            DispatchQueue.main.async {
            switch location {
                case let .success(placemark):
                    if placemark != nil {
                        self.setMapCoordinates(map: self.myMapView, coordinate: placemark!.coordinate)
                        self.setMapCoordinates(map: self.fullMapView, coordinate: placemark!.coordinate)
                    }
                    break
                case .failure(_):
                    break
                }
            }
        }
    }
    
    func getCoordinatesFromAddress(map:MKMapView,address:String) -> Result<MKPlacemark?,Error> {
        let semaphore = DispatchSemaphore(value: 0)
        var result:Result<MKPlacemark?,Error>!
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = address
        request.region = map.region
        
        let search = MKLocalSearch(request: request)
        search.start { (response, err) in
            if err == nil {
                print("SUCCESS : \((response?.mapItems.first?.placemark)!)")
                result = .success((response?.mapItems.first?.placemark)!)
                semaphore.signal()
            }else {
                print("FAILURE . \(err!)")
                result = .success(nil)
                semaphore.signal()
            }
        }
        
        let _ = semaphore.wait(timeout: .distantFuture)
        return result
        
    }
    
//    func getCustomAnnotationView () -> UIView {
//        let customView = UIView()
//        customView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
//        customView.addSubview(self.customAnnotationView)
//        return customView
//    }
    
    func setMapCoordinates(map:MKMapView,coordinate:CLLocationCoordinate2D) {
        let mapAnnotation = MKPointAnnotation()
        var region = MKCoordinateRegion()
        region.center.latitude = coordinate.latitude
        region.center.longitude = coordinate.longitude
        region.span.latitudeDelta = 1
        region.span.longitudeDelta = 1
        
        mapAnnotation.coordinate = region.center
        mapAnnotation.title = "SKY-GYM"
        mapAnnotation.subtitle = "SGAR SAGAR SGAR ADAE SDFASDKFJL"
        
        map.addAnnotation(mapAnnotation)
        map.setRegion(region, animated: true)
    }

    func fetchGymInfo(gymID:String) {
        SVProgressHUD.show()
        DispatchQueue.global(qos: .background).async {
            let gymDetail = FireStoreManager.shared.getGymInfo(gymID: gymID)
            
            DispatchQueue.main.async {
                switch gymDetail {
                case let .failure(err):
                    print("Error in finding the gym info \(err)")
                case let .success(gymInfo) :
                    self.setGymInfo(gymDetail: gymInfo)
                    self.setupPin(address: "sector 32D, sector 32 , Chandigarh")
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    func configureDetailView(annotationView: MKAnnotationView) {
        let width = 100
        let height = 100

        let calloutView = UIView()
        calloutView.translatesAutoresizingMaskIntoConstraints = false

        let views = ["calloutView": calloutView]

        calloutView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[calloutView(100)]", options: [], metrics: nil, views: views))
        calloutView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[calloutView(100)]", options: [], metrics: nil, views: views))


        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        imageView.image = UIImage(named: "address_back")

        calloutView.addSubview(imageView)

        annotationView.detailCalloutAccessoryView = calloutView
    }

    
    func setGymInfo(gymDetail:GymDetail) {
        self.gymNameLabel.text = gymDetail.gymName
        self.gymTimingLabel.text = "\(gymDetail.gymOpeningTime)/\(gymDetail.gymClosingTime)"
        self.gymDaysLabel.text  = "\(gymDetail.gymDays) days"
        self.gymAddressLabel.text  = gymDetail.gymAddress
        self.gymOwnerNameLabel.text = gymDetail.gymOwnerName
        self.gymOwnerPhoneNoLabel.text = gymDetail.gymOwnerPhoneNumber
        self.gymOwnerAddressLabel.text = gymDetail.gymOwnerAddress
    }

}

extension GymInfoViewController:MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard  let annotation = annotation as? MKPointAnnotation else {
            return nil
        }
        
        let annotationIdentifier = "gymLocation"
        var annotatioView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotatioView == nil {
            annotatioView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
        } else {
            annotatioView?.annotation = annotation
        }
        
        annotatioView?.canShowCallout = true
        annotatioView?.image = UIImage(named: "placeholder")

//        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
//        let logoImgView = UIImageView(image: UIImage(named: "logo"))
//        logoImgView.frame = leftView.frame
//        leftView.addSubview(logoImgView)
//        annotatioView?.leftCalloutAccessoryView = leftView
        
        self.configureDetailView(annotationView: annotatioView!)

        return annotatioView
    }

}
