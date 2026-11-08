class Semsearch < Formula
  desc "Find files and apps on your Mac by describing them, in any language"
  homepage "https://github.com/kuanlinb/semsearch"
  url "https://github.com/kuanlinb/semsearch/archive/refs/tags/v0.1.4.tar.gz"
  sha256 "c9de845b86f833a405e4f1fed774a5d2daf44ed8104c46cc024cdaab95a63d73"
  license "MIT"

  bottle do
    root_url "https://github.com/kuanlinb/homebrew-tap/releases/download/semsearch-0.1.4"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "beac3caf8cc66f65967b1e9d4ab230cfbcdb2278db3eaf283ffacb73518bdb2d"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "47e9e09fb2579e38dc249a6c08268ad261891f84ace6729940f3e1d48362d9bc"
  end

  depends_on arch: :arm64
  depends_on macos: :ventura
  depends_on "python@3.12"

  def install
    libexec.install Dir["*"]
    # Compile the Swift programs here, so the bottle carries them and
    # semsearch-install needs no Command Line Tools
    system libexec/"mac/build.sh", libexec/"prebuilt"
    cp libexec/"VERSION", libexec/"prebuilt"
    # The app runs from opt_libexec, a path that stays the same across upgrades
    python = formula_opt_libexec("python@3.12")/"bin"
    %w[install uninstall].each do |action|
      (bin/"semsearch-#{action}").write <<~SH
        #!/bin/zsh
        export PATH="#{python}:$PATH" SEMSEARCH_BREW=1
        exec "#{opt_libexec}/#{action}.sh" "$@"
      SH
    end
  end

  def caveats
    <<~EOS
      Finish the install (sets up the app, downloads the model on first run, starts it at login):
        semsearch-install
      Run it again after `brew upgrade semsearch`.
      To remove SemSearch, run `semsearch-uninstall` before `brew uninstall semsearch`.
    EOS
  end

  test do
    assert_predicate libexec/"install.sh", :executable?
    assert_predicate libexec/"prebuilt/SemSearch", :executable?
    system formula_opt_libexec("python@3.12")/"bin/python3", "-c",
           "import ast; ast.parse(open('#{libexec}/semsearch/search.py').read())"
  end
end
