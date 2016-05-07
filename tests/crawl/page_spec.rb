require_relative "../../src/crawler/page"

describe Crawler::Page do

  before(:each) do
    @url = "http://cnn.com"
    @host = "cnn.com"
  end

  context "#initialize" do

    it "returns an instance with a valid url" do
      expect(Crawler::Page.new(@url).url.to_s).to eq(@url)
    end

    it "returns a nil url if invalid" do
      expect(Crawler::Page.new("abc").url.url).to eq(nil)
    end

  end

  context "#html" do

    it "makes a network call to a valid url" do
      html = "<html></html>"
      browser_double = double("Watir::Browser")
      expect(Watir::Browser).to receive(:new).with(:phantomjs) { browser_double }
      expect(browser_double).to receive(:goto).with(@url) { true }
      expect(browser_double).to receive(:html) { html }
      expect(browser_double).to receive(:close) { true }
      expect(Crawler::Page.new(@url).html).to eq(html)
    end

  end

  context "#structured_html" do

    it "returns a Nokogiri-parsed structure" do
      html = "<html></html>"
      nokogiri_parsed = ::Nokogiri::HTML(html)
      browser_double = double("Watir::Browser")
      expect(Watir::Browser).to receive(:new).with(:phantomjs) { browser_double }
      expect(browser_double).to receive(:goto).with(@url) { true }
      expect(browser_double).to receive(:html) { html }
      expect(browser_double).to receive(:close) { true }
      expect(Crawler::Page.new(@url).structured_html.children[0].name).to eq(nokogiri_parsed.children[0].name)
    end

  end

  context "#is_related_to?" do

    it "returns true if the page supplied is child" do
      expect(Socket).to receive(:getaddrinfo).with(@host, "http") { ["content"] }
      expect(Socket).to receive(:getaddrinfo).with("tech.#{@host}", "http") { ["content"] }
      parent = Crawler::Page.new(@url)
      child = Crawler::Page.new("http://tech.cnn.com")
      expect(child.is_related_to?(parent)).to be(true)
    end

    it "returns false if the page supplied is not a child" do
      different_host = "abc.def.com"
      expect(Socket).to receive(:getaddrinfo).with(@host, "http") { ["content"] }
      expect(Socket).to receive(:getaddrinfo).with(different_host, "http") { ["content"] }
      parent = Crawler::Page.new(@url)
      child = Crawler::Page.new("http://#{different_host}")
      expect(child.is_related_to?(parent)).to be(false)
    end

  end
 
end