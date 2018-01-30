//
//  DiaryImage+CoreDataProperties.swift
//  DiaryApp
//
//  Created by EthanLin on 2018/1/24.
//  Copyright © 2018年 EthanLin. All rights reserved.
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
