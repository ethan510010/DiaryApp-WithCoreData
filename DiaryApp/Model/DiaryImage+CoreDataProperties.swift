//
//  DiaryImage+CoreDataProperties.swift
//  
//
//  Created by EthanLin on 2018/2/1.
//
//

import Foundation
import CoreData


extension DiaryImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DiaryImage> {
        return NSFetchRequest<DiaryImage>(entityName: "DiaryImage")
    }

    @NSManaged public var diaryImage: NSData?
    @NSManaged public var parentDiary: Diary?

}
