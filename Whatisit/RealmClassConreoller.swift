import RealmSwift
//Realmで使うClass
//Realmは履歴のために使う
class InfomationData: Object{
    dynamic var img: Data!
    dynamic var ID: String!
    var inf = List<Infoprob>()
//    var tagInformation = List<tagList>()
    
    
}
//class tagList: Object{
//    dynamic var tag: String!
//}
class Infoprob: Object {
    dynamic var info: String!
    dynamic var prob: String!
}
