class Semsearch < Formula
  desc "Find files and apps on your Mac by describing them, in any language"
  homepage "https://github.com/kuanlinb/semsearch"
  url "https://github.com/kuanlinb/semsearch/archive/refs/tags/v0.1.7.tar.gz"
  sha256 "f106b837329f544447b7e8f0b1561aae0482ce8705c65c90a6fc3f4b1652fcea"
  license "MIT"

  bottle do
    root_url "https://github.com/kuanlinb/homebrew-tap/releases/download/semsearch-0.1.7"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "9848595768b2b08ca7c88100d82ce72f1ea5af4088d9dd72f64373cff639c429"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "7e26219fadc72614cd5953c76c6d4623f0b6e08cc575b254b99f6ae4ba50f0a7"
  end

  depends_on arch: :arm64
  depends_on macos: :sonoma
  depends_on "python@3.12"

  def install
    libexec.install Dir["*"]
    # Compile the Swift programs here, so the bottle carries them and
    # semsearch-install needs no Command Line Tools
    system libexec/"mac/build.sh", libexec/"prebuilt"
    cp libexec/"VERSION", libexec/"prebuilt"
    # The helpers the search service runs (OCR, file watcher), so they keep working right
    # after `brew upgrade`, before semsearch-install runs again
    (libexec/"bin").mkpath
    cp libexec/"prebuilt/semsearch-ocr", libexec/"bin"
    cp libexec/"prebuilt/semsearch-fswatch", libexec/"bin"
    # The Python environment lives outside the versioned keg, so `brew upgrade` keeps it
    # (semsearch-install creates it)
    ln_s var/"semsearch/venv", libexec/".venv"
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
      Run it again after `brew upgrade semsearch` (the app tells you when it is needed).
      To remove SemSearch, run `semsearch-uninstall` before `brew uninstall semsearch`.
    EOS
  end

  test do
    assert_predicate libexec/"install.sh", :executable?
    assert_predicate libexec/"prebuilt/SemSearch", :executable?
    assert_predicate libexec/"bin/semsearch-ocr", :executable?
    assert_predicate libexec/".venv", :symlink?
    system formula_opt_libexec("python@3.12")/"bin/python3", "-c",
           "import ast; ast.parse(open('#{libexec}/semsearch/search.py').read())"
  end
end
