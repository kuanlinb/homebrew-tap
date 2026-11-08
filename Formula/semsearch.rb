class Semsearch < Formula
  desc "Find files and apps on your Mac by describing them, in any language"
  homepage "https://github.com/kuanlinb/semsearch"
  url "https://github.com/kuanlinb/semsearch/archive/refs/tags/v0.1.5.tar.gz"
  sha256 "f93e5015b3e67c42fbcdd769532a406d02a41c98f0d3440f5dbd0d14aaa07d45"
  license "MIT"

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
