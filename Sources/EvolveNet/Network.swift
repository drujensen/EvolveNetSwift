public protocol Network {
    var error: Double { get set }

    func clone() -> Network
    func randomize() -> Network
    func mutate()
    func punctuate(pos: Int)
    func evaluate(data: [[[Double]]])
    func run(data: [Double]) -> [Double]
}
