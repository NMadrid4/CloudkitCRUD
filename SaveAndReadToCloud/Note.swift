//
//  Note.swift
//  SaveAndReadToCloud
//
//  Created by Melanie on 12/12/18.
//

import Foundation
import CloudKit

class Note {
    var content: String
    var recorName: String
    
    init(content: String, recordName: String) {
        self.content = content
        self.recorName = recordName
    }
    
    static func from(record: CKRecord) -> Note {
        return Note.init(content: record.value(forKey: "content") as! String, recordName: record.recordID.recordName)
    }
   
}
