//
//  Diary+CoreDataProperties.swift
//  DiaryApp
//
//  Created by EthanLin on 2018/1/24.
//  Copyright © 2018年 EthanLin. All rights reserved.
//
//

import Foundation
import CoreData


extension Diary {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Diary> {
        return NSFetchRequest<Diary>(entityName: "Diary")
    }

    @NSManaged public var diaryContent: String?
    @NSManaged public var diaryLocation: String?
    @NSManaged public var diaryTitle: String?
    @NSManaged public var diaryImages: NSSet?

}

// MARK: Generated accessors for diaryImages
extension Diary {

    @objc(addDiaryImagesObject:)
    @NSManaged public func addToDiaryImages(_ value: DiaryImage)

    @objc(removeDiaryImagesObject:)
    @NSManaged public func removeFromDiaryImages(_ value: DiaryImage)

    @objc(addDiaryImages:)
    @NSManaged public func addToDiaryImages(_ values: NSSet)

    @objc(removeDiaryImages:)
    @NSManaged public func removeFromDiaryImages(_ values: NSSet)

}
