//
//  CardPaymentViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 05/03/21.
//  Copyright © 2021 KP iOSDev. All rights reserved.
//

import UIKit
import Stripe
import SVProgressHUD

class CardPaymentViewController: UIViewController {
    
    
    @IBOutlet weak var membershipDetailView: UIView!
    @IBOutlet weak var membershipPlan: UILabel!
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var endDate: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var paymentTextFieldView: UIView!
    @IBOutlet weak var payBtn: UIButton!
    
    var membershipPlanStr = ""
    var startDateStr = ""
    var endDateStr = ""
    var amountStr = ""
    var paymentTextField:STPPaymentCardTextField = STPPaymentCardTextField()
    var cardParams:STPCardParams = STPCardParams()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
        self.setCardPaymentNavigationBar()
        self.membershipPlan.text = membershipPlanStr
        self.startDate.text = startDateStr
        self.endDate.text = endDateStr
        self.amount.text = amountStr
        self.paymentTextField.delegate = self
    }

    func setUpUI()  {
        membershipDetailView.layer.cornerRadius = 15.0
        membershipDetailView.layer.borderColor = UIColor.darkGray.cgColor
        membershipDetailView.layer.borderWidth = 0.7
        membershipDetailView.layer.shadowColor = UIColor.lightGray.cgColor
        membershipDetailView.layer.shadowOpacity = 0.5
        membershipDetailView.layer.shadowRadius = 6.0
        payBtn.layer.cornerRadius = 15.0
        self.paymentTextFieldView.addSubview(paymentTextField)
        paymentTextField.translatesAutoresizingMaskIntoConstraints = false
        paymentTextField.topAnchor.constraint(equalTo: paymentTextFieldView.topAnchor, constant: 0).isActive = true
        paymentTextField.leftAnchor.constraint(equalTo: paymentTextFieldView.leftAnchor, constant: 10).isActive = true
        paymentTextField.rightAnchor.constraint(equalTo: paymentTextFieldView.rightAnchor, constant: -10).isActive = true
        paymentTextField.bottomAnchor.constraint(equalTo: paymentTextFieldView.bottomAnchor, constant: 0).isActive = true
        payBtn.addTarget(self, action: #selector(completePayment), for: .touchUpInside)
    }
    
    
    
    
    @objc func completePayment(){
        SVProgressHUD.show()
        self.view.isUserInteractionEnabled = false
        self.cardParams.number = self.paymentTextField.cardNumber
        self.cardParams.cvc = self.paymentTextField.cvc
        self.cardParams.expYear = UInt(self.paymentTextField.expirationYear)
        self.cardParams.expMonth = UInt(self.paymentTextField.expirationMonth)
        guard let amount = Int(self.amount.text!) else { return  }
        
        StripeManager.shared.createTokenForPayment(cardParmas: self.cardParams, handler: {
            (token,err) in
            
            if err == nil {
                StripeManager.shared.completePayment(token: token!, amount: amount, completion: {
                    result in
                    SVProgressHUD.dismiss()
                    self.view.isUserInteractionEnabled = true
                    switch result {
                    case .success:
                        NotificationCenter.default.post(name: NSNotification.Name("paymentSuccess"), object: nil)
                        self.navigationController?.popViewController(animated: true)
                       break
                    case let .failure(errr):
                        self.showAlert(title: "Error", msg: "Payment is not successful, something went wrong.")
                        print("Failure : \(errr)")
                        break
                    }
                    
                })
            }
            
        })
    }
    
    func showAlert(title:String,msg:String) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okAlertAction = UIAlertAction(title: "OK", style: .default, handler: {
            action in
            if title == "Success" {
                self.navigationController?.popViewController(animated: true)
            }
        })
        
        alertController.addAction(okAlertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func exitAlert() {
        let alertController = UIAlertController(title: "Attention", message: "Do you want to exit ? Your payment is in complete.", preferredStyle: .alert)
        let okAlertAction = UIAlertAction(title: "OK", style: .default, handler: {
            action in
                self.navigationController?.popToRootViewController(animated: true)
        })
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alertController.addAction(okAlertAction)
        alertController.addAction(cancelAlertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func setCardPaymentNavigationBar() {
        let title = NSAttributedString(string: "Make A Payment", attributes: [
            NSAttributedString.Key.font :UIFont(name: "Poppins-Medium", size: 22)!,
        ])
        let titleLabel = UILabel()
        titleLabel.attributedText = title
        navigationItem.titleView = titleLabel
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "left-arrow"), for: .normal)
        backButton.addTarget(self, action: #selector(addMemberBackBtnAction), for: .touchUpInside)
        backButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        backButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        let spaceBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        let stackView = UIStackView(arrangedSubviews: [spaceBtn,backButton])
        stackView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        let backBtn = UIBarButtonItem(customView: stackView)
        navigationItem.leftBarButtonItem = backBtn
    }
    
    @objc func  addMemberBackBtnAction() {
        self.exitAlert()
    }
    
}


extension CardPaymentViewController : STPPaymentCardTextFieldDelegate {

    func paymentCardTextFieldDidEndEditing(_ textField: STPPaymentCardTextField) {
        if textField.isValid == false {
            self.payBtn.isEnabled = false
            self.payBtn.alpha = 0.4
        }else {
            self.payBtn.isEnabled = true
            self.payBtn.alpha = 1.0
        }
    }
    
    
    
    
}
