import Foundation

class QuadradicNetwork: Network {
    var error: Double
    var a: Double
    var b: Double
    var c: Double

    init() {
        self.error = 1.0
        self.a = 0.0
        self.b = 0.0
        self.c = 0.0
    }

    func clone() -> Network {
        let network = QuadradicNetwork()
        network.a = self.a
        network.b = self.b
        network.c = self.c
        return network
    }

    func randomize() -> Network {
        self.a = Double.random(in: -1.0...1.0)
        self.b = Double.random(in: -1.0...1.0)
        self.c = Double.random(in: -1.0...1.0)
        return self
    }

    func mutate() {
        self.a += Double.random(in: -0.1...0.1)
        self.b += Double.random(in: -0.1...0.1)
        self.c += Double.random(in: -0.1...0.1)
    }

    func punctuate(pos: Int) {
        let precision: Double = Double(truncating: pow(10.0, pos) as NSNumber)
        self.a = round(self.a * precision) / precision
        self.b = round(self.b * precision) / precision
        self.c = round(self.c * precision) / precision
    }

    func run(data: [Double]) -> [Double] {
        let x = data[0]
        return [(self.a * pow(x, 2)) + (self.b * x) + self.c]
    }

    func evaluate(data: [[[Double]]]) {
        var sum: Double = 0.0
        for row in data {
            let actual = run(data: row[0])
            let expected = row[1]
            let diff = expected[0] - actual[0]
            sum += (diff * diff)
        }
        self.error = sum / Double(2 * data.count)
    }
}
