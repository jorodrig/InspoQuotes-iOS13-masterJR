//
//  QuoteTableViewController.swift
//  InspoQuotes
//
//  Created by Angela Yu on 18/08/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit
import StoreKit

class QuoteTableViewController: UITableViewController, SKPaymentTransactionObserver {

    // NOTE: when adding a new protocol like SKPaymenTransactionObserver, and want to use a Delegate method, you have to declare a class as the delegate for the protocol.  See ViewDidLoad whereby this class is the delegate for the Observer which will monitor the paymentQueue() each time a payment is triggered and lets us know if successful or not.
    
    
    
    let productID = "com.hotcoolapps.InspoQuotesJR.premiumQuotesJR"
    
    var quotesToShow = [
        "Our greatest glory is not in never falling, but in rising every time we fall. — Confucius",
        "All our dreams can come true, if we have the courage to pursue them. – Walt Disney",
        "It does not matter how slowly you go as long as you do not stop. – Confucius",
        "Everything you’ve ever wanted is on the other side of fear. — George Addair",
        "Success is not final, failure is not fatal: it is the courage to continue that counts. – Winston Churchill",
        "Hardships often prepare ordinary people for an extraordinary destiny. – C.S. Lewis"
    ]
    
    let premiumQuotes = [
        "Believe in yourself. You are braver than you think, more talented than you know, and capable of more than you imagine. ― Roy T. Bennett",
        "I learned that courage was not the absence of fear, but the triumph over it. The brave man is not he who does not feel afraid, but he who conquers that fear. – Nelson Mandela",
        "There is only one thing that makes a dream impossible to achieve: the fear of failure. ― Paulo Coelho",
        "It’s not whether you get knocked down. It’s whether you get up. – Vince Lombardi",
        "Your true success in life begins only when you make the commitment to become excellent at what you do. — Brian Tracy",
        "Believe in yourself, take on your challenges, dig deep within yourself to conquer fears. Never let anyone bring you down. You got to keep going. – Chantal Sutherland"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        SKPaymentQueue.default().add(self)
        
        if isPuchased() {
            showPremiumQuotes()
        }

    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isPuchased() {
            return quotesToShow.count                       //This eliminates the Get More Quotes button if already purchased.
        }
        return quotesToShow.count + 1
    }

       override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath)

        if indexPath.row < quotesToShow.count {
        cell.textLabel?.text = quotesToShow[indexPath.row]
        cell.textLabel?.numberOfLines = 0
            cell.textLabel?.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)              //to avoid side effect of alternating cell's text color when scrolling
            cell.accessoryType = .none                  //ditto
        }else{
            cell.textLabel?.text = "Get More Quotes"
            cell.textLabel?.textColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
           // cell.accessoryType = .detailDisclosureButton  //makes cell content clickable like a button or hyperlink with a > symbol
            cell.accessoryType = .disclosureIndicator //
            
        }
        return cell
    }
    
    
    // MARK: - Table view delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == quotesToShow.count{   //is now 7
            buyPremiumQuotes()
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func buyPremiumQuotes(){
        if SKPaymentQueue.canMakePayments() {
            //Can make payments                         //child payments not allowed if can make payments
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = productID
            SKPaymentQueue.default().add(paymentRequest)
        } else {
            //can't make payments
            
        }
        
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        //note SKPaymentTransaction is an array of payments
        for transaction in transactions {
            if transaction.transactionState == .purchased {
                //User payment successful
                print("Trans successful")
                showPremiumQuotes()
                SKPaymentQueue.default().finishTransaction(transaction)


            } else if transaction.transactionState == .failed {
                if let error = transaction.error {
                    let errorDescription = error.localizedDescription
                    print("Trans failed due to error: \(errorDescription)")

                }
                SKPaymentQueue.default().finishTransaction(transaction)

            }else if transaction.transactionState == .restored {      //Needed if user changes devices or resets device etc.
                showPremiumQuotes()
                print("Transactions restored")
                navigationItem.setRightBarButton(nil, animated: true)
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }
    
    
    func isPuchased() -> Bool {
        let purchaseStatus = UserDefaults.standard.bool(forKey: productID)
        if purchaseStatus {
            print("Previously Purchased - can't buy again")
            return true
        }else {
            print("Never Purchased")
            //return false     // disabled for testing due to unable to test live
            return true

        }
    }

    func showPremiumQuotes(){
        UserDefaults.standard.set(true, forKey: productID)       //for non consumable, must check if already owned so don't buy again

        quotesToShow.append(contentsOf: premiumQuotes)
        tableView.reloadData()
    }
    
    
    @IBAction func restorePressed(_ sender: UIBarButtonItem) {
        SKPaymentQueue.default().restoreCompletedTransactions()   //verified in paymentQueue()
        
    }


}
