import Foundation

class VendingMachineProduct {
    var name: String
    var amount: Int
    var price: Double
    var expirationDate: Date
    
    init(name: String, amount: Int, price: Double, daysUntilExpiration: Int) {
        self.name = name
        self.amount = amount
        self.price = price
        
        let secondsPerDay = 60 * 60 * 24
        expirationDate = Date(timeIntervalSinceNow: TimeInterval(daysUntilExpiration * secondsPerDay))
    }
}

enum VendingMachineError: Error {
    case productNotFound
    case productUnavailable
    case insufficientFunds
    case productStuck
    case productExpired
    case changeStuck
    case moneyNotRecognized
}

extension VendingMachineError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Produto não encontrado"
        case .productUnavailable:
            return "Acabou o estoque"
        case .insufficientFunds:
            return "Dinheiro insuficiente"
        case .productStuck:
            return "Produto ficou preso"
        case .productExpired:
            return "Este produto já está estragado"
        case .changeStuck:
            return "Seu troco ficou preso"
        case .moneyNotRecognized:
            return "Não foi possível identificar o dinheiro inserido"
        }
    }
}

class VendingMachine {
    private var estoque: [VendingMachineProduct]
    private var money: Double
    
    init(products: [VendingMachineProduct]) {
        self.estoque = products
        self.money = 0
    }
    
    func getProduct(named name: String, with money: Double) throws {
        if money > 0 && Int.random(in: 0...50) < 10 {
            throw VendingMachineError.moneyNotRecognized
        }
        
        self.money += money
        
        let item = estoque.first { (product) -> Bool in
            return product.name == name
        }
        guard let product = item else { throw VendingMachineError.productNotFound }
        
        guard product.amount > 0 else { throw VendingMachineError.productUnavailable }
        
        guard product.price <= self.money else { throw VendingMachineError.insufficientFunds }
        
        guard product.expirationDate > Date() else { throw VendingMachineError.productExpired }
        
        self.money -= product.price
        product.amount -= 1
        
        if Int.random(in: 0...100) < 10 {
            throw VendingMachineError.productStuck
        }
        
        print("Produto entregue!")
    }
    
    func getTroco() throws -> Double {
        let money = self.money
        self.money = 0
        
        if Int.random(in: 0...100) < 10 {
            throw VendingMachineError.changeStuck
        }
        
        return money
    }
}

let vendingMachine = VendingMachine(products: [
    VendingMachineProduct(name: "Bolinho Ana Maria", amount: 5, price: 4, daysUntilExpiration: 50),
    VendingMachineProduct(name: "Cebolitos", amount: 7, price: 5, daysUntilExpiration: 100),
    VendingMachineProduct(name: "Iogurte", amount: 1, price: 10, daysUntilExpiration: 0)
])


print("Primeira compra")
do {
    try vendingMachine.getProduct(named: "Cebolitos", with: 30)
    try vendingMachine.getProduct(named: "Cebolitos", with: 0)
    try vendingMachine.getProduct(named: "Bolinho Ana Maria", with: 0)
    
    let troco = try vendingMachine.getTroco()
    print("Seu troco é \(troco)")
} catch {
    print(error.localizedDescription)
}

print("\nSegunda compra")
do {
    try vendingMachine.getProduct(named: "Iogurte", with: 30)
    
    let troco = try vendingMachine.getTroco()
    print("Seu troco é \(troco)")
} catch {
    print(error.localizedDescription)
}


