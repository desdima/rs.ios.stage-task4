import Foundation

public extension Int {
    
    var roman: String? {
        
        if ((self <= 0) || (self > 3999)) {return nil}
        
        let numberValue = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1]
        let romanNumeral = [
              "M",
              "CM",
              "D",
              "CD",
              "C",
              "XC",
              "L",
              "XL",
              "X",
              "IX",
              "V",
              "IV",
              "I"
            ]
        
        var value =  self
        var countForRoman : [(roman: String, num: Int)] = []

        for (index, number) in numberValue.enumerated() {
            let x = value / number
            if x > 0 {
                countForRoman.append((romanNumeral[index], x))
                value = value - x * number
            }
        }

        var romanString = ""
        for pairs in countForRoman {
            let iteration = pairs.num
            for _ in 1 ... iteration { romanString += pairs.roman }
        }
        
        return romanString
    }
}
