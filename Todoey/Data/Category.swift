//
//  Category.swift
//  Todoey
//
//  Created by Geet Gobind Singh on 25/04/23.
//

import Foundation

import RealmSwift

class Category : Object {
    @objc dynamic var name: String = ""
    @objc dynamic var colour: String = ""
    let items = List<Item>() //  forward relationship
}
