import UIKit
import CloudKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    let database = CKContainer.default().privateCloudDatabase
    var notes: [Note] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //      updateRecord()
        //        removeRecord()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        getData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func addNewWordAction(_ sender: Any) {
        let alert = UIAlertController(title: "", message: "Type something", preferredStyle: .alert)
        alert.addTextField { (textfield) in
            textfield.placeholder = "Note here"
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let post = UIAlertAction(title: "Post", style: .default) { (_) in
            guard let text = alert.textFields?.first?.text else {return}
            self.saveToCloud(note: text)
        }
        alert.addAction(cancel)
        alert.addAction(post)
        self.present(alert, animated: true)
    }
    
    func saveToCloud(note: String) {
        let newNote = CKRecord(recordType: "Note")
        newNote.setValue(note, forKey: "content")
        database.save(newNote) { (record, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let record = record  else {return}
            print("save record with note \(String(describing: record.object(forKey: "content")))")
            self.notes.append(Note.from(record: record))
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func getData() {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Note", predicate: predicate)
        database.perform(query, inZoneWith: nil) { (results, error) in
            if let error = error  {
                print(error.localizedDescription)
                return
            }
            self.notes.removeAll()
            for record in results! {
                self.notes.append(Note.from(record: record))
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }
    
    func removeRecord(recordName: String) {
        let recordId = CKRecord.ID(recordName: recordName)
        database.delete(withRecordID: recordId) { deletedRecordId, error in
            if let _ = deletedRecordId {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = notes[indexPath.row].content
        return cell
    }
    
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc2 = storyboard?.instantiateViewController(withIdentifier: "vc2") as! ViewController2
        vc2.note = self.notes[indexPath.row]
        self.navigationController?.pushViewController(vc2, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.removeRecord(recordName: notes[indexPath.row].recorName)
            self.notes.remove(at: indexPath.row)
        }
    }
}
