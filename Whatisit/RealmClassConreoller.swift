import RealmSwift
//Realmで使うClass
//Realmは履歴のために使う
class InfomationData: Object{
    dynamic var img: Data!
    dynamic var ID: String!
    var inf = List<Infoprob>()
    
}

class Infoprob: Object {
    dynamic var info: String!
    dynamic var prob: String!
}
