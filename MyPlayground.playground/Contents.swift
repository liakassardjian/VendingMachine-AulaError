import Foundation

class VendingMachineProduct {
    var name: String
    var amount: Int
    var price: Double
    
    init(name: String, amount: Int, price: Double) {
        self.name = name
        self.amount = amount
        self.price = price
    }
}

enum VendingMachineError: Error {
    case productNotFound
    case productUnavailable
    case insufficientFunds
    case productStuck
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
        self.money += money
        
        let item = estoque.first { (product) -> Bool in
            return product.name == name
        }
        guard let product = item else { throw VendingMachineError.productNotFound }
        
        guard product.amount > 0 else { throw VendingMachineError.productUnavailable }
        
        guard product.price <= self.money else { throw VendingMachineError.insufficientFunds }
        
        self.money -= product.price
        product.amount -= 1
        
        if Int.random(in: 0...100) < 10 {
            throw VendingMachineError.productStuck
        }
        
        print("Produto entregue!")
    }
    
    func getTroco() -> Double {
        let money = self.money
        self.money = 0
        
        return money
    }
}

let vendingMachine = VendingMachine(products: [
    VendingMachineProduct(name: "Carregador de iPhone", amount: 5, price: 150),
    VendingMachineProduct(name: "Cebolitos", amount: 2, price: 5),
    VendingMachineProduct(name: "Guarda-chuva", amount: 5, price: 100)
])

do {
    try vendingMachine.getProduct(named: "Cebolitos", with: 8)
    try vendingMachine.getProduct(named: "Cebolitos", with: 0)
} catch {
    print(error.localizedDescription)
}

print("Seu troco é \(vendingMachine.getTroco())")

