//
//  ApplePayViewModal.swift
//  RCRC
//
//  Created by Aashish Singh on 16/11/22.
//

import Foundation
import PassKit

typealias ApplePayCompletionHandler = (ApplePayModal) -> Void

class ApplePayViewModal: NSObject {
    
    static let shared = ApplePayViewModal()
    
    var paymentController: PKPaymentAuthorizationController?
    var paymentSummaryItems = [PKPaymentSummaryItem]()
    //var paymentStatus = PKPaymentAuthorizationStatus.failure
    var completionHandler: ApplePayCompletionHandler!
    var applePayModal = ApplePayModal(paymentStatus: .failure)
    
    let supportedNetworks: [PKPaymentNetwork] = [
        .discover,
        .masterCard,
        .visa,
        .quicPay
    ]
    
    func applePayStatus() -> (canMakePayments: Bool, canSetupCards: Bool) {
        return (PKPaymentAuthorizationController.canMakePayments(),
                PKPaymentAuthorizationController.canMakePayments(usingNetworks: supportedNetworks))
    }
    
    // Define the shipping methods.
    /*
    func shippingMethodCalculator() -> [PKShippingMethod] {
        // Calculate the pickup date.
        
        let today = Date()
        let calendar = Calendar.current
        
        let shippingStart = calendar.date(byAdding: .day, value: 3, to: today)!
        let shippingEnd = calendar.date(byAdding: .day, value: 5, to: today)!
        
        let startComponents = calendar.dateComponents([.calendar, .year, .month, .day], from: shippingStart)
        let endComponents = calendar.dateComponents([.calendar, .year, .month, .day], from: shippingEnd)
        
        let shippingDelivery = PKShippingMethod(label: "Delivery", amount: NSDecimalNumber(string: "0.00"))
        if #available(iOS 15.0, *) {
            shippingDelivery.dateComponentsRange = PKDateComponentsRange(start: startComponents, end: endComponents)
        } else {
            // Fallback on earlier versions
        }
        shippingDelivery.detail = "Ticket sent to you address"
        shippingDelivery.identifier = "DELIVERY"
        
        let shippingCollection = PKShippingMethod(label: "Collection", amount: NSDecimalNumber(string: "0.00"))
        shippingCollection.detail = "Collect ticket at festival"
        shippingCollection.identifier = "COLLECTION"
        
        return [shippingDelivery, shippingCollection]
    }
    */
    
    func startPayment(product: FareMediaAvailableProduct?, completion: @escaping ApplePayCompletionHandler) {
        
        completionHandler = completion
        applePayModal = ApplePayModal(paymentStatus: .failure)

        let name = "\(product?.name ?? emptyString) \(product?.productCategory?.displayName ?? emptyString)"
        var productPrice: Double = 0.0
        if let currentProductPrice = product?.price {
            productPrice = Double(currentProductPrice / 100)
        }
        let productDetail = PKPaymentSummaryItem(label: name, amount: NSDecimalNumber(value: productPrice), type: .final)
        paymentSummaryItems = [productDetail]
        
        let paymentRequest: PKPaymentRequest = PKPaymentRequest()
        paymentRequest.paymentSummaryItems = paymentSummaryItems
        paymentRequest.merchantIdentifier = Constants.merchantIdentifier
        paymentRequest.merchantCapabilities = .capability3DS
        
        /*check for default countryCode & currencyCode after login & signin*/
        paymentRequest.countryCode = Constants.countryCode //UserDefaultService.getCountryISOCode()
        paymentRequest.currencyCode = Constants.currencyCode
        paymentRequest.supportedNetworks = supportedNetworks
        
        //paymentRequest.shippingType = .delivery
        //paymentRequest.shippingMethods = shippingMethodCalculator()
        //paymentRequest.requiredShippingContactFields = [.name, .postalAddress]
        //paymentRequest.supportsCouponCode = true
        
        /* Display the payment request.*/
        paymentController = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
        paymentController?.delegate = self
        
        
        
        paymentController?.present(completion: { (presented: Bool) in
            if presented {
                debugPrint("Presented payment controller")
            } else {
                debugPrint("Failed to present payment controller")
                self.completionHandler(self.applePayModal)
            }
        })
    }
}

//MARK: Set up PKPaymentAuthorizationControllerDelegate conformance.

extension ApplePayViewModal: PKPaymentAuthorizationControllerDelegate {
    
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
                
        /* var errors = [Error]()
         var status = PKPaymentAuthorizationStatus.failure
         let token = payment.token*/
        
        let transactionID = payment.token.transactionIdentifier
        let paymentData = payment.token.paymentData
        
      
        
        /*do {
            let jsonResponse = try JSONSerialization.jsonObject(with: paymentData, options: .mutableContainers) as? String
            print(jsonResponse ?? "")
            //status = .success
            applePayModal = ApplePayModal(paymentStatus: .success, transactionIdentifier: transactionID, paymentData: jsonResponse)
            completion(PKPaymentAuthorizationResult(status: .success, errors: [Error]()))
            
        } catch {
            print(error)
            /*status = .failure
             errors = [error]*/
            applePayModal = ApplePayModal(paymentStatus: .failure, error: error)
            completion(PKPaymentAuthorizationResult(status: .failure, errors: [error]))
        }*/
        
//        do {
//            let json = try JSONSerialization.jsonObject(with: paymentData, options: []) as! [String : Any]
//
//           // print("json payment token",json)
//           // applePayModal = ApplePayModal(paymentStatus: .success, transactionIdentifier: transactionID, paymentData: json)
//
//            jsonToData(json: json)
//        } catch {
//            print("errorMsg")
//        }
        
    
        let jsonString: String? = String(decoding: paymentData, as: UTF8.self)
        
       
        do {
            let json = try JSONSerialization.jsonObject(with: payment.token.paymentData, options: []) as? [String : Any]
            
           
            
            applePayModal = ApplePayModal(paymentStatus: .success, transactionIdentifier: transactionID, paymentData: jsonString)
            //applePayModal = ApplePayModal(paymentStatus: .success, transactionIdentifier: transactionID, paymentData: json)
            completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
        } catch {
            print("errorMsg")
            
            let error = NSError(domain: "",
                                  code: 500,
                              userInfo: [NSLocalizedDescriptionKey: "Empty Json"])
            applePayModal = ApplePayModal(paymentStatus: .failure, error: error)
            
            completion(PKPaymentAuthorizationResult(status: .failure, errors: [error]))
        }
       
        print("paymentData json string: \(jsonString ?? "") ////////////")
        
       
        
//        if let jsonResponse = jsonResponse, !jsonResponse.isEmpty {
//            applePayModal = ApplePayModal(paymentStatus: .success, transactionIdentifier: transactionID, paymentData: jsonResponse)
//            completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
//        } else {
//            let error = NSError(domain: "",
//                                  code: 500,
//                              userInfo: [NSLocalizedDescriptionKey: "Empty Json"])
//            applePayModal = ApplePayModal(paymentStatus: .failure, error: error)
//            completion(PKPaymentAuthorizationResult(status: .failure, errors: [error]))
//        }
        
        /*
         if payment.shippingContact?.postalAddress?.isoCountryCode != Constants.countryCode {
         let pickupError = PKPaymentRequest.paymentShippingAddressUnserviceableError(withLocalizedDescription: "Sample App only available in the Saudi Arabia")
         let countryError = PKPaymentRequest.paymentShippingAddressInvalidError(withKey: CNPostalAddressCountryKey, localizedDescription: "Invalid country")
         errors.append(pickupError)
         errors.append(countryError)
         status = .failure
         } else {
         // Send the payment token to your server or payment provider to process here.
         // Once processed, return an appropriate status in the completion handler (success, failure, and so on).
         }
         */
        
        /*self.paymentStatus = status
         completion(PKPaymentAuthorizationResult(status: status, errors: errors))*/
    }
    
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss {
            DispatchQueue.main.async {
                self.completionHandler!(self.applePayModal)
            }
        }
    }
    
    // Coupon Code Logic
    /*
    @available(iOS 15.0, *)
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController,
                                        didChangeCouponCode couponCode: String,
                                        handler completion: @escaping (PKPaymentRequestCouponCodeUpdate) -> Void) {
        // The `didChangeCouponCode` delegate method allows you to make changes when the user enters or updates a coupon code.
        
        func applyDiscount(items: [PKPaymentSummaryItem]) -> [PKPaymentSummaryItem] {
            let tickets = items.first!
            let couponDiscountItem = PKPaymentSummaryItem(label: "Coupon Code Applied", amount: NSDecimalNumber(string: "-2.00"))
            let updatedTax = PKPaymentSummaryItem(label: "Tax", amount: NSDecimalNumber(string: "0.80"), type: .final)
            let updatedTotal = PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(string: "8.80"), type: .final)
            let discountedItems = [tickets, couponDiscountItem, updatedTax, updatedTotal]
            return discountedItems
        }
        
        if couponCode.uppercased() == "FESTIVAL" {
            // If the coupon code is valid, update the summary items.
            let couponCodeSummaryItems = applyDiscount(items: paymentSummaryItems)
            completion(PKPaymentRequestCouponCodeUpdate(paymentSummaryItems: applyDiscount(items: couponCodeSummaryItems)))
            return
        } else if couponCode.isEmpty {
            // If the user doesn't enter a code, return the current payment summary items.
            completion(PKPaymentRequestCouponCodeUpdate(paymentSummaryItems: paymentSummaryItems))
            return
        } else {
            // If the user enters a code, but it's not valid, we can display an error.
            let couponError = PKPaymentRequest.paymentCouponCodeInvalidError(localizedDescription: "Coupon code is not valid.")
            completion(PKPaymentRequestCouponCodeUpdate(errors: [couponError], paymentSummaryItems: paymentSummaryItems, shippingMethods: shippingMethodCalculator()))
            return
        }
    }
    */
    
    
    
    
}

