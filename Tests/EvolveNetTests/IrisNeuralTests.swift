import XCTest
@testable import EvolveNet

class IrisNeuralTests: XCTestCase {

    func testIrisDataModel() throws {
        var data: [[[Double]]] = []
        
        let url = URL(fileURLWithPath: "/Users/drujensen/workspace/swift/EvolveNet/Tests/EvolveNetTests/iris.csv")
        let contents = try String(contentsOf: url)
        let rows = contents.split(separator: "\n")

        for row in rows {
            let columns = row.split(separator: ",")

            var input: [Double] = []
            var output: [Double] = []
            for (idx, col) in columns.enumerated() {
                if idx == 4 {
                    switch col {
                    case "setosa":
                        output = [1, 0, 0]
                    case "versicolor":
                        output = [0, 1, 0]
                    case "virginica":
                        output = [0, 0, 1]
                    default:
                        print("not found")
                    }
                } else {
                    let value = Double(col)!
                    input.append(value)
                }
            }
            data.append([input, output])
        }
        
        var mins: [Double] = []
        var maxs: [Double] = []
        for idx in (0...3) {
            let min_row = data.min { a,b in a[0][idx] < b[0][idx]}
            let max_row = data.max { a,b in a[0][idx] < b[0][idx]}

            mins.append(min_row![0][idx])
            maxs.append(max_row![0][idx])
        }

        let norm_data = data.map { row -> [[Double]] in
            let output = row[1]
            let input = row[0].enumerated().map { idx, col -> Double in
                let range = maxs[idx] - mins[idx]
                return (col - mins[idx]) * (1.0 / range)
            }
            return [input, output]
        }
        
        let neural = NeuralNetwork()
        neural.push(layer: Layer(size: 4))
        neural.push(layer: Layer(size: 5))
        neural.push(layer: Layer(size: 3))
        neural.connect()
        
        let organism = EvolveNet(network: neural)
        let network = organism.evolve(data: data, generations: 10000, logEach: 100)

        var tp = 0
        var tn = 0
        var fp = 0
        var fn = 0
        var ct = 0
        for row in data {
            let actual = network.run(data: row[0])
            let expected = row[1]
            for (idx, act) in actual.enumerated() {
                ct += 1
                if act > 0.5 {
                    if expected[idx] > 0.5 {
                        tp += 1
                    } else {
                        fp += 1
                    }
                } else {
                    if expected[idx] < 0.5 {
                        tn += 1
                    } else {
                        fn += 1
                    }
                }
            }
        }
        let accuracy = Double(tn + tp) / Double(ct)
        print("Test size: \(data.count)")
        print("----------------------")
        print("TN: \(tn) | FP: \(fp)")
        print("----------------------")
        print("FN: \(fn) | TP: \(tp)")
        print("----------------------")
        print("Accuracy: \(accuracy)")

        XCTAssertGreaterThan(accuracy, 0.95)
    }

}
