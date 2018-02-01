//
//  DetailsViewController.swift
//  whatisthat
//
//  Created by 靳亚芳 on 11/27/17.
//  Copyright © 2017 yafangjin. All rights reserved.
//

import UIKit
import SafariServices
import TwitterKit
import MBProgressHUD


class DetailsViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var favoriateButton: UIBarButtonItem!
    var transitTitle: String?
    var text: DetailsModel?
    var image: UIImage?
    var favr: FavModel?
    let textRequest = WikipediaAPIManager()
    var isOn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //designate self as the receiver of the requestDetails callbacks
        textRequest.delegate = self
        requestDetails()
        self.navigationItem.title = self.transitTitle
        
        let persistance = PersistanceManager()
        isOn = persistance.isFavoriated(self.transitTitle!)
        if(isOn){
            favoriateButton.title = "unFavoriate"
        }else{
            favoriateButton.title = "Favoriate"
        }
        
    }
    
    func requestDetails() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        textRequest.requestDetails(title:transitTitle!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func favAct() {
        
        let data = UIImagePNGRepresentation(self.image!)
        let imagePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let seconds = Date().ticks
        let imagename = "\(seconds).png"
        let filename = imagePath.appendingPathComponent(imagename)
        try? data?.write(to: filename)
        
        let favModel = FavModel(imageName: imagename, title: self.transitTitle!)
        let persistManager = PersistanceManager()
        persistManager.saveFav(favModel)
        
        let alertController = UIAlertController(title: "Save success!", message: nil, preferredStyle: .alert)
        self.present(alertController, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.presentedViewController?.dismiss(animated: false, completion: nil)
        }
        
        isOn = true
        favoriateButton.title = "unFavoriate"
    }
    
    func unfavAct() {
        let persistManager = PersistanceManager()
        let seconds = Date().ticks
        let imagename = "\(seconds).png"
        let favModel = FavModel(imageName: imagename, title: self.transitTitle!)
        persistManager.removeFav(favModel)
        favoriateButton.title = "Favoriate"
        isOn = false
        
        let alertController = UIAlertController(title: "Delete success!", message: nil, preferredStyle: .alert)
        self.present(alertController, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.presentedViewController?.dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func favoriateButtonAction(_ sender: Any) {
        if isOn == false {
            favAct()
        } else {
            unfavAct()
        }
    }
    
    func showWiki(_ what: String) {
        // if using curid, the web page is for computer; if using title, the web page is for phone
        //if let url = URL(string: "https://en.wikipedia.org/wiki/\(self.transitTitle!)") {
        if let url = URL(string: "https://en.wikipedia.org/?curid=\(what)") {
            let vc = SFSafariViewController(url:url)
            present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func showWikiPage(_ sender: Any) {
        showWiki((self.text?.page?.stringValue)!)
    }
    
    @IBAction func showTweets(_ sender: Any) {
        let dataSource = TWTRSearchTimelineDataSource(searchQuery: "\(self.transitTitle ?? "")", apiClient: TWTRAPIClient())
        dataSource.resultType = "popular"
        let twitterVC = TWTRTimelineViewController(dataSource: dataSource)
        twitterVC.showTweetActions = true
        twitterVC.navigationItem.title = self.transitTitle
        self.navigationController?.pushViewController(twitterVC, animated: true)
    }
    
    
    @IBAction func shareDetails(_ sender: Any) {
        let text = textView.text
        let activityVC = UIActivityViewController(activityItems: [text!], applicationActivities: nil)
        
        if let popoverController = activityVC.popoverPresentationController{
            popoverController.sourceView = self.view
            popoverController.sourceRect = self.view.bounds
        }
        self.present(activityVC, animated: true, completion: nil)
    }
}

//adhere to the GoogleVisionAPIManagerDelegate protocol
extension DetailsViewController: UITextViewDelegate, WikipediaAPIManagerDelegate{
    
    func detailsFound(details: DetailsModel) {
        self.text = details
        let con = details.content
        DispatchQueue.main.async(execute: {
            let htmlString = "<html>" +
                "<head>" +
                "<style>" +
                "body {" +
                "background-color: rgb(230, 230, 230);" +
                "font-family: 'Arial';" +
                "text-decoration:none;" +
                "}" +
                "</style>" +
                "</head>" +
                "<body>\(con!)" +
            "</body></head></html>"
            
            let htmlData = NSString(string: htmlString).data(using: String.Encoding.unicode.rawValue)
            
            let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
            
            let attributedString = try! NSAttributedString(data: htmlData!, options: options, documentAttributes: nil)
            
            self.textView.attributedText = attributedString
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
        })
    }
    
    func detailsNotFound(reason: WikipediaAPIManager.FailureReason) {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
            let alertController = UIAlertController(title: "Problem fetching items", message: reason.rawValue, preferredStyle: .alert)
            
            switch reason {
            case .networkRequestFailed:
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: { (action) in
                    self.requestDetails()
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                
                alertController.addAction(retryAction)
                alertController.addAction(cancelAction)
                
            case .badJSONResponse, .noData, .defaultReason:
                let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alertController.addAction(okayAction)
            }
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FavoritesSegue"{
            let favVC = segue.destination as! FavoritesTableViewController
            
            favVC.transitTitle = transitTitle
            favVC.favImage = image
        }
    }
}
extension Date {
    var ticks: UInt64 {
        return UInt64((self.timeIntervalSince1970 + 62_135_596_800) * 10_000_000)
    }
}
