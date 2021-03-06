class Mockolo < Formula
  desc "Efficient Mock Generator for Swift"
  homepage "https://github.com/uber/mockolo"
  url "https://github.com/uber/mockolo/archive/1.4.0.tar.gz"
  sha256 "e40add783327a3684f22b16067c0d69aed695d9c5d3d4b08cc3a6e73b9788b9d"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "2a4dd6209018834007ed19d331c10530f89311f3f4857e7f20eceb86847c4824"
    sha256 cellar: :any_skip_relocation, big_sur:       "bb70522736fff22ed26734d0955ab1f40c12853687bf01a6c0f902ec2220e58d"
  end

  depends_on xcode: ["12.5", :build]

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox"
    bin.install ".build/release/mockolo"
  end

  test do
    (testpath/"testfile.swift").write("
    /// @mockable
    public protocol Foo {
        var num: Int { get set }
        func bar(arg: Float) -> String
    }")
    system "#{bin}/mockolo", "-srcs", testpath/"testfile.swift", "-d", testpath/"GeneratedMocks.swift"
    assert_predicate testpath/"GeneratedMocks.swift", :exist?
    assert_equal "
    ///
    /// @Generated by Mockolo
    ///
    public class FooMock: Foo {
      public init() { }
      public init(num: Int = 0) {
          self.num = num
      }

      public private(set) var numSetCallCount = 0
      public var num: Int = 0 { didSet { numSetCallCount += 1 } }

      public private(set) var barCallCount = 0
      public var barHandler: ((Float) -> (String))?
      public func bar(arg: Float) -> String {
          barCallCount += 1
          if let barHandler = barHandler {
              return barHandler(arg)
          }
          return \"\"
      }
    }".gsub(/\s+/, "").strip, shell_output("cat #{testpath/"GeneratedMocks.swift"}").gsub(/\s+/, "").strip
  end
end
