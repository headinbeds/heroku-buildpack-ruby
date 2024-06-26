require 'spec_helper'

describe "Boot Strap Config" do
  it "matches toml config" do
    require 'toml-rb'
    config = TomlRB.load_file("buildpack.toml")
    bootstrap_version = config["buildpack"]["ruby_version"]
    expect(bootstrap_version).to eq(LanguagePack::RubyVersion::BOOTSTRAP_VERSION_NUMBER)

    urls = config["publish"]["Vendor"].map {|h| h["url"] if h["dir"] != "." }.compact
    urls.each do |url|
      expect(url.include?(bootstrap_version)).to be_truthy, "expected #{url.inspect} to include #{bootstrap_version.inspect} but it did not"
    end

    expect(`ruby -v`).to match(Regexp.escape(LanguagePack::RubyVersion::BOOTSTRAP_VERSION_NUMBER))

    bootstrap_version = Gem::Version.new(LanguagePack::RubyVersion::BOOTSTRAP_VERSION_NUMBER)
    default_version = Gem::Version.new(LanguagePack::RubyVersion::DEFAULT_VERSION_NUMBER)

    expect(bootstrap_version).to be >= default_version
  end

  it "doesn't contain unexpected entries" do
    require 'toml-rb'
    config = TomlRB.load_file("buildpack.toml")

    urls = config["publish"]["Vendor"].map {|h| h["url"] if h["dir"] != "." }.compact
    heroku_20 = urls.find_all {|url| url.include?("heroku-20") }
    expect(heroku_20.length).to eq(1)

    heroku_22 = urls.find_all {|url| url.include?("heroku-22") }
    expect(heroku_22.length).to eq(1)

    heroku_24 = urls.find_all {|url| url.include?("heroku-24") }
    expect(heroku_24.length).to eq(1)

    expect(urls.length).to eq(3)
  end
end
