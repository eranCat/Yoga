import UIKit

typealias Person = (name:String,age:Int)
typealias personCmp = (Person,Person)->Bool

var arr:[Person] = [
    ("be",2),
    ("arr",3),
    ("c",1)
]

let sorter = {$0.name.lowercased() < $1.name.lowercased()} as personCmp
let ager:personCmp = {$0.age < $1.age}

print(arr)

arr.sort(by: sorter)
print(arr)

arr.sort(by: ager)
print(arr)


let ids = ["3",nil,"6","5","9",nil]

let compactMap = ids.compactMap { (id) -> String? in
    return id
}
