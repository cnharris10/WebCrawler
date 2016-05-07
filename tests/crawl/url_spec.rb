require_relative "../../src/crawler/page"

describe Crawler::Url do

  before(:each) do
    @url = "http://cnn.com"
    @host = @url.gsub(/http(s|):\/\//i,"")
  end

  context "#initialize" do

    it "returns an instance with a valid https url" do
      expect(Socket).to receive(:getaddrinfo).with(@host, "http") { nil }
      expect(Socket).to receive(:getaddrinfo).with(@host, "https") { ["content"] }
      instance = Crawler::Url.new(@url)
      expect(instance.url.to_s).to eq(@url)
    end

    it "returns an instance with a valid http url" do
      expect(Socket).to receive(:getaddrinfo).with(@host, "http") { ["content"] }
      instance = Crawler::Url.new(@url)
      expect(instance.url.to_s).to eq(@url)
    end

    it "raises an error with an invalid url (http & https)" do
      expect(Socket).to receive(:getaddrinfo).with(@host, "http") { nil }
      expect(Socket).to receive(:getaddrinfo).with(@host, "https") { nil }
      instance = Crawler::Url.new(@url)
      expect(instance.url).to be nil
    end

  end

  context "http?" do

    it "should return a verified http host" do
      expect(Socket).to receive(:getaddrinfo).twice.with(@host, "http") { ["content"] }
      instance = Crawler::Url.new(@url)
      expect(instance.http?).to be true
    end

    it "should return nil for an unverified http host" do
      expect(Socket).to receive(:getaddrinfo).with(@host, "http") { nil }
      expect(Socket).to receive(:getaddrinfo).with(@host, "https") { nil }
      instance = Crawler::Url.new(@url)
      expect(instance.http?).to be false
    end

  end

  context "https?" do

    it "should return a verified https host" do
      expect(Socket).to receive(:getaddrinfo).with(@host, "http") { nil }
      expect(Socket).to receive(:getaddrinfo).twice.with(@host, "https") { ["content"] }
      instance = Crawler::Url.new(@url)
      expect(instance.https?).to be true
    end

    it "should return nil for an unverified https host" do
      expect(Socket).to receive(:getaddrinfo).with(@host, "http") { nil }
      expect(Socket).to receive(:getaddrinfo).with(@host, "https") { nil }
      instance = Crawler::Url.new(@url)
      expect(instance.http?).to be false
    end

  end
 
  context "#sanitize_url" do

    it "returns an absolute url from url: //google.com/" do
      url = "//#{@host}/"
      expect(Socket).to receive(:getaddrinfo).with(@host, "http") { ["content"] }
      instance = Crawler::Url.new("http://#{@host}")
      expect(Crawler::Url.sanitize_url(instance, url)).to eq "http://#{@host}/"
    end

    it "returns an absolute url from url: /a/b/c" do
      url = "/a/b/c"
      expect(Socket).to receive(:getaddrinfo).with(@host, "http") { ["content"] }
      instance = Crawler::Url.new("http://#{@host}")
      expect(Crawler::Url.sanitize_url(instance, url)).to eq "http://#{@host}/a/b/c"
    end

    it "returns an absolute url from url: http://www.google.com/" do
      url = "http://www.#{@host}/"
      expect(Socket).to receive(:getaddrinfo).with(@host, "http") { ["content"] }
      instance = Crawler::Url.new("http://#{@host}")
      expect(Crawler::Url.sanitize_url(instance, url)).to eq url
    end

  end

  context "#validate" do

    before(:each) do
      @host = "google.com"
    end

    it "returns true with a valid url" do
      expect(Socket).to receive(:getaddrinfo).twice.with(@host, "http") { ["content"] }
      instance = Crawler::Url.new("http://#{@host}")
      expect(instance.send(:validate)).to eq(true)
    end

    it "returns false with an invalid url" do
      expect(Socket).to receive(:getaddrinfo).twice.with(@host, "http") { nil }
      expect(Socket).to receive(:getaddrinfo).twice.with(@host, "https") { nil }
      instance = Crawler::Url.new("http://#{@host}")
      expect(instance.send(:validate)).to eq(false)
    end

  end

  context "#split_and_construct_url" do

    it "returns a URI" do
      expect(Socket).to receive(:getaddrinfo).with(@host, "http") { ["content"] }
      instance = Crawler::Url.new("http://#{@host}")
      instance.send(:split_and_construct_url)
      expect(instance.url.to_s).to eq(@url)
    end

    it "returns nil with a bad URI" do
      expect(URI::HTTP).to receive(:build).twice.and_raise("error")
      instance = Crawler::Url.new("http://#{@host}")
      instance.send(:split_and_construct_url)
      expect(instance.url).to eq(nil)
    end

  end

end