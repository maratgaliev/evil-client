describe "request", :fake_api do
  before { stub_request :any, /localhost/ }

  let(:client) { Evil::Client.with(base_url: "http://localhost") }

  context "in GET request" do
    before  { client.get "baz" => "qux" }
    subject { a_request(:get, "http://localhost?baz=qux") }

    it { is_expected.to have_been_made_with_body "" }
  end

  context "in POST request" do
    before  { client.post "baz" => "qux" }
    subject { a_request(:post, "http://localhost") }

    it { is_expected.to have_been_made_with_body('{"baz":"qux"}') }
  end

  context "in POST multipart request" do
    let(:tmpfile) { Tempfile.create("example.txt") }

    before  { client.post "baz" => "qux", "file" => tmpfile }
    after   { tmpfile.close; File.unlink(tmpfile) }

    subject { a_request(:post, "http://localhost") }

    it { is_expected.to have_been_made_with_header("Content-Type", %r{multipart/form-data}) }

    it { is_expected.to have_been_made_with_body(/Content-Disposition: form-data/) }
    it { is_expected.to have_been_made_with_body(/filename="example\.txt.*"/) }
  end

  context "in PATCH request" do
    before  { client.patch "baz" => "qux" }
    subject { a_request(:patch, "http://localhost") }

    it { is_expected.to have_been_made_with_body(/"baz":"qux"/) }
  end

  context "in PUT request" do
    before  { client.put "baz" => "qux" }
    subject { a_request(:put, "http://localhost") }

    it { is_expected.to have_been_made_with_body(/"baz":"qux"/) }
  end

  context "in DELETE request" do
    before  { client.delete "baz" => "qux" }
    subject { a_request(:delete, "http://localhost") }

    it { is_expected.to have_been_made_with_body(/"baz":"qux"/) }
  end

  context "in FOO (arbitrary) request" do
    before  { client.request :foo, "baz" => "qux" }
    subject { a_request(:foo, "http://localhost") }

    it { is_expected.to have_been_made_with_body(/"baz":"qux"/) }
  end

  context "in FOO (arbitrary) request without params" do
    before  { client.request :foo }
    subject { a_request(:foo, "http://localhost") }

    it { is_expected.to have_been_made_with_body("") }
  end
end
