import RealmSwift

class UnreadMessagesService {
   
    static func updateUnreadMessagesCount() {
        let realm = Realm.myRealm()
        let messages = realm.objects(DBConversation.self)
        let count = messages.reduce(0, { $0 + $1.unreadMessageCount })
        UltraCoreSettings.delegate?.unreadMessagesUpdated(count: count)
    }

}

