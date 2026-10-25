class Semsearch < Formula
  desc "Find files and apps on your Mac by describing them, in any language"
  homepage "https://github.com/kuanlinb/semsearch"
  url "https://github.com/kuanlinb/semsearch/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "9005e28588023561288d8d33a2d6a2bece02f1d4d64a8377bf5d0ad7f15d6d19"
  license "MIT"

  depends_on arch: :arm64
  depends_on macos: :ventura
  depends_on "python@3.12"

  def install
    libexec.install Dir["*"]
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
      Finish the install (builds the app, downloads the model on first run, starts it at login):
        semsearch-install
      Run it again after `brew upgrade semsearch`.
      To remove SemSearch, run `semsearch-uninstall` before `brew uninstall semsearch`.
    EOS
  end

  test do
    assert_predicate libexec/"install.sh", :executable?
    system formula_opt_libexec("python@3.12")/"bin/python3", "-c",
           "import ast; ast.parse(open('#{libexec}/semsearch/search.py').read())"
  end
end
