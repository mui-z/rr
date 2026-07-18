class Rr < Formula
  desc "A simple CLI QR code generator"
  homepage "https://github.com/mui-z/rr"
  version "1.0.0"
  license "MIT"

  on_arm do
    url "https://github.com/mui-z/rr/releases/download/v#{version}/rr.artifactbundle.zip"
    sha256 "REPLACE_WITH_ARM64_SHA256"
  end

  on_intel do
    url "https://github.com/mui-z/rr/releases/download/v#{version}/rr.artifactbundle.zip"
    sha256 "REPLACE_WITH_X86_64_SHA256"
  end

  def install
    if Hardware::CPU.arm?
      bin.install "rr.artifactbundle/rr-macos-arm64/bin/rr"
    else
      bin.install "rr.artifactbundle/rr-macos-x86_64/bin/rr"
    end
  end

  test do
    system "#{bin}/rr", "--help"
  end
end
