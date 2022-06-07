require "./spec_helper"

describe OpenTelemetry::Resource, tags: ["Resource"] do
  resource = OpenTelemetry::Resource.new

  around_each do |example|
    resource = OpenTelemetry::Resource.new
    verb = "GET"
    url = "http://example.com/foo"
    resource.set_attribute("verb", verb)
    resource["url"] = url
    resource["bools"] = true
    resource["headers"] = Array(String).new
    resource.get_attribute("headers") << "Content-Type: text/plain"
    resource.get_attribute("headers") << "Content-Length: 23"

    example.run
  end

  it "can create a resource and set/get attributes" do
    resource["bools"] = false
    resource["bools"].should be_false
    resource.get_attribute("bools") << true
    resource["bools"].should eq [false, true]
    resource["headers"].should eq ["Content-Type: text/plain", "Content-Length: 23"]
  end

  it "can createa protobuf representation of a resource" do
    # TODO; Check that this structure is correct.
  end

  it "can create a json representation of a resource" do
    resource.to_json.should eq <<-EJSON
    {
      "verb": "GET",
      "url": "http://example.com/foo",
      "bools": true,
      "headers": [
        "Content-Type: text/plain",
        "Content-Length: 23"
      ]
    }
    EJSON
  end
end
