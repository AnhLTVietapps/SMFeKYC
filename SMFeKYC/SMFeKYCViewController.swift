//
//  SMFeKYCViewController.swift
//  SMFeKYC
//
//  Created by AnhLe on 2/24/21.
//

import Netverify
import SwiftTryCatch
import Alamofire
import Photos

public protocol SMFeKYCViewControllerDelegate: class {
    func sMFeKYCViewController(_ sMFeKYCViewController: SMFeKYCViewController, didFinishInitializingWithError: String?)
    func sMFeKYCViewController(_ sMFeKYCViewController: SMFeKYCViewController, didFinishWithScanReference: String?)
    func sMFeKYCViewController(_ sMFeKYCViewController: SMFeKYCViewController, didCancelWithScanError: String?, scanReference: String?)
}

public class SMFeKYCViewController: UIViewController, NetverifyViewControllerDelegate {
    public var enableVerification: Bool!
    public var enableIdentityVerification: Bool!
    public var apiToken: String!
    public var apiSecret: String!
    public var internalId: String!
    public var userReference: String!
    public var apiDomain: String!
    public var netverifyViewController:NetverifyViewController?
    public var sMFeKYCDelegate: SMFeKYCViewControllerDelegate?
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            DispatchQueue.main.async {
                self.startNetverify()
            }
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.startNetverify()
                    }
                }
            }
            
        case .denied, .restricted: // The user can't grant access due to restrictions.
            DispatchQueue.main.async {
                self.showAlert(withTitle: "Access permission", message: "You need to allow your camera access to use this feature.")
            }
        @unknown default: break
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    public func startNetverifyController() -> Void {
        //prevent SDK to be initialized on Jailbroken devices
        if JumioDeviceInfo.isJailbrokenDevice() {
            return
        }
        
        //Setup the Configuration for Netverify
        let config:NetverifyConfiguration = createNetverifyConfiguration()
        //Set the delegate that implements NetverifyViewControllerDelegate
        config.delegate = self
        
        //Perform the following call as soon as your app’s view controller is initialized. Create the NetverifyViewController instance by providing your Configuration with required API token, API secret and a delegate object.
        SwiftTryCatch.try {
            self.netverifyViewController = NetverifyViewController(configuration: config)
        } catch: { error in
            self.showAlert(withTitle: "System error", message: error?.description)
        } finally: {}
        
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
            self.netverifyViewController?.modalPresentationStyle = UIModalPresentationStyle.formSheet;  // For iPad, present from sheet
        }
    }
    
    public func showAlert(withTitle title: String?, message: String?) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        
        let closeAction = UIAlertAction(
            title: "OK",
            style: .default,
            handler: { action in
                
            })
        
        alertController.addAction(closeAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    public func createNetverifyConfiguration() -> NetverifyConfiguration {
        let config:NetverifyConfiguration = NetverifyConfiguration()
        //Provide your API token and your API secret
        //Do not store your credentials hardcoded within the app. Make sure to store them server-side and load your credentials during runtime.
        config.apiToken = apiToken
        config.apiSecret = apiSecret
        config.enableVerification = enableVerification
        config.enableIdentityVerification = enableIdentityVerification
        return config
    }
    
    public func startNetverify() -> Void {
        self.startNetverifyController()
        
        if let netverifyVC = self.netverifyViewController {
//            self.present(netverifyVC, animated: true, completion: nil)
            self.view.addSubview(netverifyVC.view)
        } else {
            showAlert(withTitle: "Netverify Mobile SDK", message: "NetverifyViewController is nil")
        }
    }
    
    /**
     * Implement the following delegate method for SDK initialization.
     * @param netverifyViewController The NetverifyViewController instance
     * @param error The error describing the cause of the problematic situation, only set if initializing failed
     **/
    public func netverifyViewController(_ netverifyViewController: NetverifyViewController, didFinishInitializingWithError error: NetverifyError?) {
        self.sMFeKYCDelegate?.sMFeKYCViewController(self, didFinishInitializingWithError: error?.message)
        print("NetverifyViewController did finish initializing")
    }
    
    /**
     * Implement the following delegate method for successful scans.
     * Dismiss the SDK view in your app once you received the result.
     * @param netverifyViewController The NetverifyViewController instance
     * @param documentData The NetverifyDocumentData of the scanned document
     * @param scanReference The scanReference of the scan
     **/
    public func netverifyViewController(_ netverifyViewController: NetverifyViewController, didFinishWith documentData: NetverifyDocumentData, scanReference: String) {
        print("NetverifyViewController finished successfully with scan reference: \(scanReference)")
        
        let selectedCountry:String = documentData.selectedCountry ?? ""
        let selectedDocumentType:NetverifyDocumentType = documentData.selectedDocumentType
        var documentTypeStr:String
        switch (selectedDocumentType) {
        case .driverLicense:
            documentTypeStr = "DL"
            break;
        case .identityCard:
            documentTypeStr = "ID"
            break;
        case .passport:
            documentTypeStr = "PP"
            break;
        case .visa:
            documentTypeStr = "Visa"
            break;
        default:
            documentTypeStr = ""
            break;
        }
        
        //id
        let idNumber:String? = documentData.idNumber
        let personalNumber:String? = documentData.personalNumber
        let issuingDate:Date? = documentData.issuingDate
        let expiryDate:Date? = documentData.expiryDate
        let issuingCountry:String? = documentData.issuingCountry
        let optionalData1:String? = documentData.optionalData1
        let optionalData2:String? = documentData.optionalData2
        
        //person
        let lastName:String? = documentData.lastName
        let firstName:String? = documentData.firstName
        let dateOfBirth:Date? = documentData.dob
        let gender:NetverifyGender = documentData.gender
        var genderStr:String;
        switch (gender) {
        case .unknown:
            genderStr = "Unknown"
            
        case .F:
            genderStr = "female"
            
        case .M:
            genderStr = "male"
            
        case .X:
            genderStr = "Unspecified"
            
        default:
            genderStr = "Unknown"
        }
        
        let originatingCountry:String? = documentData.originatingCountry
        let placeOfBirth:String? = documentData.placeOfBirth
        
        //address
        let street:String? = documentData.addressLine
        let city:String? = documentData.city
        let state:String? = documentData.subdivision
        let postalCode:String? = documentData.postCode
        
        // Raw MRZ data
        let mrzData:NetverifyMrzData? = documentData.mrzData
        
        let message:NSMutableString = NSMutableString.init()
        message.appendFormat("Selected Country: %@", selectedCountry)
        message.appendFormat("\nDocument Type: %@", documentTypeStr)
        if (idNumber != nil) { message.appendFormat("\nID Number: %@", idNumber!) }
        if (personalNumber != nil) { message.appendFormat("\nPersonal Number: %@", personalNumber!) }
        if (issuingDate != nil) { message.appendFormat("\nIssuing Date: %@", issuingDate! as CVarArg) }
        if (expiryDate != nil) { message.appendFormat("\nExpiry Date: %@", expiryDate! as CVarArg) }
        if (issuingCountry != nil) { message.appendFormat("\nIssuing Country: %@", issuingCountry!) }
        if (optionalData1 != nil) { message.appendFormat("\nOptional Data 1: %@", optionalData1!) }
        if (optionalData2 != nil) { message.appendFormat("\nOptional Data 2: %@", optionalData2!) }
        if (lastName != nil) { message.appendFormat("\nLast Name: %@", lastName!) }
        if (firstName != nil) { message.appendFormat("\nFirst Name: %@", firstName!) }
        if (dateOfBirth != nil) { message.appendFormat("\ndob: %@", dateOfBirth! as CVarArg) }
        message.appendFormat("\nGender: %@", genderStr)
        if (originatingCountry != nil) { message.appendFormat("\nOriginating Country: %@", originatingCountry!) }
        if (placeOfBirth != nil) { message.appendFormat("\nPlace of birth: %@", placeOfBirth!) }
        if (street != nil) { message.appendFormat("\nStreet: %@", street!) }
        if (city != nil) { message.appendFormat("\nCity: %@", city!) }
        if (state != nil) { message.appendFormat("\nState: %@", state!) }
        if (postalCode != nil) { message.appendFormat("\nPostal Code: %@", postalCode!) }
        if (mrzData != nil) {
            if (mrzData?.line1 != nil) {
                message.appendFormat("\nMRZ Data: %@\n", (mrzData?.line1)!)
            }
            if (mrzData?.line2 != nil) {
                message.appendFormat("%@\n", (mrzData?.line2)!)
            }
            if (mrzData?.line3 != nil) {
                message.appendFormat("%@\n", (mrzData?.line3)!)
            }
        }
        
        // Callback delegate when finish verify data
        self.sMFeKYCDelegate?.sMFeKYCViewController(self, didFinishWithScanReference: scanReference)
        
        // Call API to save infor on server
        let endPoint = "/api/v1/scan-reference"
        let urlString = apiDomain + endPoint
        let parameters = ["scanReference": scanReference,
                          "internalId": internalId,
                          "userReference": userReference,
                          "pushToken": apiToken]
        let headers: HTTPHeaders = ["Content-Type": "application/json"]
        
        AF.request(urlString, method: .post, parameters: parameters as Parameters, encoding:  URLEncoding.queryString, headers: headers).responseJSON { response in
            switch response.result {
            case .success:
                print("Validation Successful")
            case let .failure(error):
                print(error)
            }
        }
        
        //Dismiss the SDK
        self.dismiss(animated: true, completion: {
            print(message)
            self.showAlert(withTitle: "Netverify Mobile SDK", message: message as String)
            self.netverifyViewController?.destroy()
            self.netverifyViewController = nil
        })
    }
    
    /**
     * Implement the following delegate method for successful scans and user cancellation notifications. Dismiss the SDK view in your app once you received the result.
     * @param netverifyViewController The NetverifyViewController
     * @param error The error describing the cause of the problematic situation
     * @param scanReference The scanReference of the scan attempt
     **/
    public func netverifyViewController(_ netverifyViewController: NetverifyViewController, didCancelWithError error: NetverifyError?, scanReference: String?) {
        
        //handle the error cases as highlighted in our documentation: https://github.com/Jumio/mobile-sdk-ios/blob/master/docs/integration_faq.md#managing-errors
        self.sMFeKYCDelegate?.sMFeKYCViewController(self, didCancelWithScanError: error?.message, scanReference: scanReference)
        print("NetverifyViewController cancelled with error: \(error?.message ?? "") scanReference: \(scanReference ?? "")")
        
        //Dismiss the SDK
        self.dismiss(animated: true) {
            self.netverifyViewController?.destroy()
            self.netverifyViewController = nil
        }
    }
}


