require_relative "../../src/crawler/page"
require_relative "../../src/tasks/crawl"
require_relative "../../src/tasks/email"

describe Crawler::Email do

  context "#parse_html" do

    it "returns nil for a blank page" do
      expect(Crawler::Email.parse(nil)).to eq(nil)
    end

    it "returns a new crawler page" do
      html = "<html>a@a.com<br/>b@b.com</html>"
      stub_const("REDIS_CLIENT", double("Redis"))
      expect(REDIS_CLIENT).to receive(:sadd).with("emails", "a@a.com") { true }
      expect(REDIS_CLIENT).to receive(:sadd).with("emails", "b@b.com") { true }
      Crawler::Email.parse(html)
    end

  end
 
end