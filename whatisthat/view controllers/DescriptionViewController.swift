//
//  DescriptionViewController.swift
//  whatisthat
//
//  Created by 靳亚芳 on 11/27/17.
//  Copyright © 2017 yafangjin. All rights reserved.
//

import UIKit
import MBProgressHUD

class DescriptionViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultsTableView: UITableView!
    
    var dataList:[DescriptionModel]?
    var image: UIImage?
    var transTitle: String?
    let dataRequest = GoogleVisionAPIManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = image
        // Do any additional setup after loading the view.
        //designate self as the receiver of the requestDescriptions callbacks
        dataRequest.delegate = self
        
        requestDescriptions()
    }
    
    func requestDescriptions() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        dataRequest.requestDescriptions(image: image!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//adhere to the GoogleVisionAPIManagerDelegate protocol
extension DescriptionViewController: UITableViewDelegate,UITableViewDataSource, GoogleVisionAPIManagerDelegate{
    
    func descriptionFound(descriptions: [DescriptionModel]) {
        
        //update tableview data on the main (UI) thread
        DispatchQueue.main.async(execute: {
            self.dataList = descriptions
            self.resultsTableView.reloadData()
            MBProgressHUD.hide(for: self.view, animated: true)
        })
    }
    
    func descriptionNotFound(reason: GoogleVisionAPIManager.FailureReason) {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
            
            let alertController = UIAlertController(title: "Problem fetching items", message: reason.rawValue, preferredStyle: .alert)
            
            switch reason {
            case .networkRequestFailed:
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: { (action) in
                    self.requestDescriptions()
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                
                alertController.addAction(retryAction)
                alertController.addAction(cancelAction)
                
            case .badJSONResponse, .noData:
                let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alertController.addAction(okayAction)
            }
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultsTableViewCell") as! TableViewCell
        
        // Configure the cell...
        let model = dataList?[indexPath.row]
        
        cell.titleLabel.text = model?.name
        cell.percentLabel.text = String(format: "%.2f", model?.percent ?? 0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = dataList?[indexPath.row]
        transTitle = model?.name
        performSegue(withIdentifier: "DetailsVCSegue", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailsVCSegue"{
            let detVC = segue.destination as! DetailsViewController
        
            detVC.transitTitle = transTitle
            detVC.image = image

        }
    }
    
    
    
}






