GEM       = "stomp"
VER       = "1.0.6"
AUTHORS   = ["Brian McCallister"]
EMAILS    = ["brianm@apache.org"]
HOMEPAGE  = "http://stomp.codehaus.org/"
SUMMARY   = "Ruby client for the Stomp messaging protocol"

Gem::Specification.new do |s|
  s.name = GEM
  s.version = VER
  s.authors = AUTHORS
  s.email = EMAILS
  s.homepage = HOMEPAGE
  s.summary = SUMMARY
  s.description = s.summary
  s.platform = Gem::Platform::RUBY

  s.require_path = 'lib'
  s.executables = ["catstomp", "stompcat"]

  # get this easily and accurately by running 'Dir.glob("{lib,test}/**/*")'
  # in an IRB session.  However, GitHub won't allow that command hence
  # we spell it out.
  s.files = ["README.rdoc", "LICENSE", "CHANGELOG", "Rakefile", "lib/stomp.rb", "test/test_client.rb", "test/test_stomp.rb", "test/test_url_connections.rb", "test/test_url_connections_noauth.rb"]
  s.test_files = ["test/test_client.rb", "test/test_stomp.rb", "test/test_url_connections.rb", "test/test_url_connections_noauth.rb"]

  s.has_rdoc = true
  s.rdoc_options = ["--quiet", "--title", "stomp documentation", "--opname", "index.html", "--line-numbers", "--main", "README.rdoc", "--inline-source"]
  s.extra_rdoc_files = ["README.rdoc", "CHANGELOG", "LICENSE"]

end

