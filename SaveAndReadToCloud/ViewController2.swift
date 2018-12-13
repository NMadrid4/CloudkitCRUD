//
//  ViewController2.swift
//  SaveAndReadToCloud
//
//  Created by Melanie on 12/12/18.
//

import UIKit
import CloudKit

class ViewController2: UIViewController {
    
    @IBOutlet weak var contentTextField: UITextField!
    var note: Note?
    let database = CKContainer.default().privateCloudDatabase
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let note = note {
            contentTextField.text = note.content
        }
    }
    
    func updateRecord(recordName: String, newValue: String, key: String) {
        let recordId = CKRecord.ID(recordName: recordName)
        print(recordId)
        database.fetch(withRecordID: recordId) { (updateRecord, error) in
            if let error = error {
                print(error)
                return
            }
            updateRecord?.setValue(newValue, forKey: key)
            self.database.save(updateRecord!, completionHandler: { (_, _) in
                DispatchQueue.main.async {
                    print("actualizado")
                    self.contentTextField.text = ""
                }
            })
        }
    }
    
    @IBAction func updateAction(_ sender: Any) {
        if !contentTextField.text!.isEmpty {
            updateRecord(recordName: self.note!.recorName, newValue: contentTextField.text!, key: "content")
        }else {
            print("llene campo")
        }
        
    }
}
