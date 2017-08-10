import RealmSwift

class InfomationData: Object{
    dynamic var img: UIImage!
    dynamic var ID: String!
    var inf = List<Infoprob>()
}

class Infoprob: Object {
    dynamic var info: String!
    dynamic var prob: String!
}
