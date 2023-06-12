require 'spec_helper'
require 'ronin/vulns/cli/commands/reflected_xss'
require_relative 'man_page_example'

describe Ronin::Vulns::CLI::Commands::ReflectedXss do
  include_examples "man_page"

  let(:url) { 'https://example.com/page.php?id=1' }

  describe "#scan_url" do
    it "must call Ronin::Vulns::ReflectedXSS.scan with the URL and #scan_kwargs" do
      expect(Ronin::Vulns::ReflectedXSS).to receive(:scan).with(
        url, **subject.scan_kwargs
      )

      subject.scan_url(url)
    end
  end

  describe "#test_url" do
    it "must call Ronin::Vulns::ReflectedXSS.scan with the URL and #scan_kwargs" do
      expect(Ronin::Vulns::ReflectedXSS).to receive(:test).with(
        url, **subject.scan_kwargs
      )

      subject.test_url(url)
    end
  end
end
