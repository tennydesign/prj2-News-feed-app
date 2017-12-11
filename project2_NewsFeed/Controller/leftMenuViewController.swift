//
//  leftMenuViewController.swift
//  project2_NewsFeed
//
//  Created by Tennyson Pinheiro on 10/17/17.
//  Copyright © 2017 Tenny. All rights reserved.
// call singleton function


import UIKit
import CoreData

class leftMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIObjectsDelegationProtocol {

    
    @IBOutlet weak var searchBox: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var outputDebug: UITextField!
    @IBOutlet weak var arrow: UIImageView!
    
    @IBOutlet weak var searchLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        animationSingleton.sharedInstance.delegate = self
        
        tableView.register(UINib.init(nibName: TableViewCells.keywordCellClassName, bundle: nil), forCellReuseIdentifier: TableViewCells.keywordCell)
        
        self.searchBox.delegate = self
        
        // close and fade out.
        NotificationCenter.default.addObserver(self, selector: #selector(fadeOutControls), name: NSNotification.Name(rawValue: "fadeOutControls"), object: nil)

        // open and fade in.
        NotificationCenter.default.addObserver(self, selector: #selector(fadeInControls), name: NSNotification.Name(rawValue: "fadeInControls"), object: nil)
        
        // creating tap at arrow
        self.arrow.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(userTapOnArrow))
        self.arrow.addGestureRecognizer(tapRecognizer)
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text != ""{
            if let typedContent = textField.text {
                News.sharedINstance.keywords.append(typedContent)
                textField.text = ""

                let indexPath = IndexPath(row: News.sharedINstance.keywords.count - 1 , section: 0)

                tableView.insertRows(at: [indexPath], with: .left)

            }

        }
        textField.resignFirstResponder()
        return true
            
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return News.sharedINstance.keywords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCells.keywordCell, for: indexPath) as! SearchTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
 
         cell.keyword.text = News.sharedINstance.keywords[indexPath.row]

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        News.sharedINstance.keywords.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .left)

    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
    
    
    @IBAction func brandClicked(_ sender: UIButton) {
        let alertController = UIAlertController(title: "And... Here is the alert.", message: "Thanks 🤘", preferredStyle: .actionSheet)
        
        let defaultAction = UIAlertAction(title: "Weekend 😴", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    // Mark: Animation
    
    @objc func fadeOutControls() {
        self.tableView.fadeOut()
        self.searchBox.fadeOut()
        self.searchLabel.fadeOut()
        // arrow do the opposite
        self.arrow.arrowFadeIn()
        searchBox.resignFirstResponder()
    }
    
    @objc func fadeInControls() {
        self.tableView.fadeIn()
        self.searchBox.fadeIn()
        self.searchLabel.fadeIn()
        // arrow do the opposite
        self.arrow.arrowFadeOut()
    }

    func fadeInArrow() {
        self.arrow.arrowFadeIn()
    }
    
    func fadeOutArrow() {
        self.arrow.arrowFadeOut()
    }
    
    //not being called by the delegate
    func resizeArrow() {
       // self.arrow.layer.contentsRect = CGRect(x:0,y:0,width:1.3,height:1.3)
    }
    

    @objc func userTapOnArrow(sender: UIImageView) {
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = true
        }
    }
    
}



extension UIView {
    
    func fadeIn(){
        UIView.animate(withDuration: 0.4, delay: 0.3, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: nil)
    }
    
    
    func fadeOut(){
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.alpha = 0.0
        }, completion: nil)
    }
    
    func arrowFadeIn(){
        UIView.animate(withDuration: 0.6, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.95
        }, completion: nil)
    }
    
    func arrowFadeOut(){
        UIView.animate(withDuration: 1.0, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.alpha = 0.0
        }, completion: nil)
    }
    
    
}


