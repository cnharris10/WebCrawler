require "resque"

require_relative "../../src/crawler/page"
require_relative "../../src/tasks/crawl"
require_relative "../../src/tasks/email"

describe Crawler::Crawl do

  context "#fetch_html" do

    before(:each) do
      @url = "http://google.com"
    end

    it "should fetch nothing with a blank page" do
      page_double = double("Crawler::Page")
      expect(Crawler::Page).to receive(:new).with(@host) { page_double }
      expect(page_double).to receive(:url) { nil }
      expect(Crawler::Crawl.fetch_html(@host)).to eq(nil)
    end

    it "should fetch html" do
      html = """
              <html><body>
              <a href='http://link1.com'>Link 1</a>
              <a href='http://link2.com'>Link 2</a>
              </body></html>
            """

      link1 = "http://link1.com"
      link2 = "http://link2.com"
      page_double = double(Crawler::Page)
      subpage_doubles = [double(Crawler::Page), double(Crawler::Page)]
      url_double = double(Crawler::Url)
      suburl_doubles = [double(Crawler::Url), double(Crawler::Url)]

      # Page
      expect(Crawler::Page).to receive(:new).with(@url) { page_double }
      expect(page_double).to receive(:html) { html }
      expect(page_double).to receive(:anchors) { Nokogiri::HTML(html).css("a") }
      expect(page_double).to receive(:url).exactly(4).times { url_double }
      expect(url_double).to receive(:to_s).exactly(3).times { @url }
      expect(REDIS_CLIENT).to receive(:hset).with("urls", @url, 1) { true }

      # Subpages
      expect(Crawler::Page).to receive(:new).with(link1) { subpage_doubles[0] }
      expect(Crawler::Page).to receive(:new).with(link2) { subpage_doubles[1] }
      expect(subpage_doubles[0]).to receive(:is_related_to?).with(page_double) { true }
      expect(subpage_doubles[1]).to receive(:is_related_to?).with(page_double) { true }
      expect(subpage_doubles[0]).to receive(:url).twice { suburl_doubles[0] }
      expect(subpage_doubles[1]).to receive(:url).twice { suburl_doubles[1] }
      expect(suburl_doubles[0]).to receive(:to_s).twice { link1 }
      expect(suburl_doubles[1]).to receive(:to_s).twice { link2  }
      expect(Resque).to receive(:enqueue).with(Crawler::Email, html)
      expect(Resque).to receive(:enqueue).with(Crawler::Crawl, link1)
      expect(Resque).to receive(:enqueue).with(Crawler::Crawl, link2)
      Crawler::Crawl.fetch_html(@url)
    end

  end

  context "#enqueues_subpage" do

    before(:each) do
      @link1 = "http://link1.com"
      @page_double = double("Crawler::Page")
      @url_double = double("Crawler::Url")
      stub_const("REDIS_CLIENT", double("Redis"))
    end

    it "enqueues a subpage to be crawled when it's link is found for the first time" do
      subpage_double = double("Crawler::Page")
      suburl_double = double("Crawler::Url")
      expect(@page_double).to receive(:url).twice { @url_double }
      expect(@url_double).to receive(:to_s).twice { @link1 }
      expect(REDIS_CLIENT).to receive(:hget).with("urls", @link1) { false }
      expect(Resque).to receive(:enqueue) { true }  
      Crawler::Crawl.enqueue_subpage(@page_double)
    end

    it "does not enqueue a subpage to be crawled if it has already been crawled" do
      expect(@page_double).to receive(:url) { @url_double }
      expect(@url_double).to receive(:to_s) { @link1 }
      expect(REDIS_CLIENT).to receive(:hget).with("urls", @link1) { true }
      Crawler::Crawl.enqueue_subpage(@page_double)
    end

  end
 
end