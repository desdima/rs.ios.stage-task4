import Foundation

final class CallStation {
    var usersList: Array<User> = Array<User>() //массив пользователей
    var callsList: Array<Call> = Array<Call>() //список звонков
    var callsUserList: Dictionary<User, Array<Call>> = Dictionary<User, Array<Call>>() //соответствие пользователя и его звонков
}

extension CallStation: Station {
      
    func users() -> [User] { return usersList }
    
    func add(user: User) {
        
        var inList: Bool = false
        for value in usersList {
            if value == user {inList = true}
        }
        if (inList != true) {
            usersList.append(user)
            callsUserList[user] = []
        }
    }
    
    func remove(user: User) {
        usersList.enumerated().forEach {index, value in
            if (value == user) {usersList.remove(at: index)}
        }
    }
        
    
    func execute(action: CallAction) -> CallID? {

        switch action {
        case .start(let user1, let user2):
            if users().contains(user1) {
                if !users().contains(user2) {
                    let call = Call(id: user1.id, incomingUser: user2, outgoingUser: user1, status: .ended(reason: .error))
                    callsList.append(call)
                    
                    callsUserList[call.incomingUser]?.append(call)
                    callsUserList[call.outgoingUser]?.append(call)
                    
                    return call.id
                }
                
                if currentCall(user: user2) != nil {
                    let call = Call(id: user1.id, incomingUser: user2, outgoingUser: user1, status: .ended(reason: .userBusy))
                    callsList.append(call)
                    
                    callsUserList[call.incomingUser]?.append(call)
                    callsUserList[call.outgoingUser]?.append(call)
                    
                    return call.id
                }
                
                if user1.id != user2.id {
                    let call = Call(id: user1.id, incomingUser: user2, outgoingUser: user1, status: .calling)
                    callsList.append(call)
                    
                    callsUserList[call.incomingUser]?.append(call)
                    callsUserList[call.outgoingUser]?.append(call)
                    
                    return call.id
                }
            }
            return nil
            
//----------------------------
            
        case .answer(let user2):
            let incomingCall = currentCall(user: user2)
            if incomingCall != nil {
                
                if users().contains(user2) {
                    let call = Call(id: incomingCall?.id ?? user2.id, incomingUser: user2, outgoingUser: incomingCall?.outgoingUser ?? user2, status: .talk)
                    callsList.removeFirst()
                    callsList.append(call)
                    return call.id
                } else {
                    let call = Call(id: incomingCall?.id ?? user2.id, incomingUser: user2, outgoingUser: incomingCall?.outgoingUser ?? user2, status: .ended(reason: .error))
                    callsList.removeFirst()
                    callsList.append(call)
                    return nil
                }
            }
            
            
//----------------------------
        
        case .end(let user1):
            
            let incomingCall = currentCall(user: user1)
            if incomingCall != nil {
                if incomingCall?.status == CallStatus.talk {
                    let call = Call(id: incomingCall?.id ?? user1.id, incomingUser: user1, outgoingUser: incomingCall?.outgoingUser ?? user1, status: .ended(reason: .end))
                    callsList.removeFirst()
                    callsList.append(call)
       
                    return call.id
                }
                
                if incomingCall?.status == CallStatus.calling {
                    let call = Call(id: incomingCall?.id ?? user1.id, incomingUser: user1, outgoingUser: incomingCall?.outgoingUser ?? user1, status: .ended(reason: .cancel))
                    callsList.removeFirst()
                    callsList.append(call)
                    
                    return call.id
                }
            }
        }
        
        return nil
    }
    
    func calls() -> [Call] { return callsList }
    
    func calls(user: User) -> [Call] {
        if callsUserList[user] != nil {
            let callsArray = callsUserList[user]!
            return callsArray
        }
        return []
    }
    
    func call(id: CallID) -> Call? {
        
        for (index, value) in callsList.enumerated() {
            if (value.id == id) {
                callsList.remove(at: index)
                return value
            }
        }
        return nil
    }
            
    func currentCall(user: User) -> Call? {
        for (index, value) in callsList.enumerated() {
            if (value.status == CallStatus.ended(reason: .end) || value.status == CallStatus.ended(reason: .error)) {
                callsList.remove(at: index)
                return nil
            }
                            
            if (value.status == CallStatus.ended(reason: .cancel))   {
                callsList.remove(at: index)
                return nil
            }
                            
            if ((value.outgoingUser == user) || (value.incomingUser == user)) {
                return value
            }
        }
        return nil
    }
}
