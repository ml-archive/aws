class Trie<ValueType> {
    var key: UInt8
    var value: ValueType?
    
    var children: [Trie] = []
    
    var isLeaf: Bool {
        return children.count == 0
    }
    
    convenience init() {
        self.init(key: 0x00)
    }
    
    init(key: UInt8, value: ValueType? = nil) {
        self.key = key
        self.value = value
    }
}

extension Trie {
    subscript(_ key: UInt8) -> Trie? {
        get { return children.first(where: { $0.key == key }) }
        set {
            guard let index = children.index(where: { $0.key == key }) else {
                guard let newValue = newValue else { return }
                children.append(newValue)
                return
            }
            
            guard let newValue = newValue else {
                children.remove(at: index)
                return
            }
            
            let child = children[index]
            guard child.value == nil else {
                print("warning: inserted duplicate tokens into Trie.")
                return
            }
            
            child.value = newValue.value
        }
    }
    
    func insert(_ keypath: [UInt8], value: ValueType) {
        insert(value, for: keypath)
    }
    
    func insert(_ value: ValueType, for keypath: [UInt8]) {
        var current = self
        
        for (index, key) in keypath.enumerated() {
            guard let next = current[key] else {
                let next = Trie(key: key)
                current[key] = next
                current = next
                
                if index == keypath.endIndex - 1 {
                    next.value = value
                }
                
                continue
            }
            
            if index == keypath.endIndex - 1 && next.value == nil {
                next.value = value
            }
            
            current = next
        }
    }
    
    func contains(_ keypath: [UInt8]) -> ValueType? {
        var current = self
        
        for key in keypath {
            guard let next = current[key] else { return nil }
            current = next
        }
        
        return current.value
    }
}
