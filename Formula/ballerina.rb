class Ballerina < Formula
  desc "Programming Language for Network Distributed Applications"
  homepage "https://ballerina.io"
  url "https://dist.ballerina.io/downloads/1.2.13/ballerina-1.2.13.zip"
  sha256 "ba2b6cbf09f5129a72afa3f494da5c7304d9321b32c4a1504c5a2b11644c2c57"
  license "Apache-2.0"

  livecheck do
    url "https://ballerina.io/downloads/"
    regex(%r{href=.*?/downloads/.*?ballerina[._-]v?(\d+(?:\.\d+)+)\.}i)
  end

  bottle :unneeded

  depends_on "openjdk@8"

  def install
    # Remove Windows files
    rm Dir["bin/*.bat"]

    chmod 0755, "bin/ballerina"

    bin.install "bin/ballerina"
    libexec.install Dir["*"]
    Pathname.glob("#{libexec}/bin/*.sh") do |path|
      next if path == libexec+"bin/ballerina"

      script_name = path.basename
      bin_name    = path.basename ".sh"
      (bin+bin_name).write <<~EOS
        #!/bin/bash
        export JAVA_HOME="${JAVA_HOME:-#{Formula["openjdk"].opt_prefix}}"
        exec "#{libexec}/bin/#{script_name}" "$@"
      EOS
  end

  test do
    (testpath/"helloWorld.bal").write <<~EOS
      import ballerina/io;
      public function main() {
        io:println("Hello, World!");
      }
    EOS
    output = shell_output("#{bin}/ballerina run helloWorld.bal")
    assert_equal "Hello, World!", output.chomp
  end
end
