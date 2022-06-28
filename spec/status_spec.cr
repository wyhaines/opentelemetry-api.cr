describe OpenTelemetry::API::Status do
  it "defines #a constructor that takes a status code and message" do
    status = OpenTelemetry::API::Status.new(OpenTelemetry::API::Status::StatusCode::Ok, "OK")
    status.code.should eq OpenTelemetry::API::Status::StatusCode::Ok
    status.message.should eq "OK"
  end

  it "defines #ok!" do
    status = OpenTelemetry::API::Status.new(OpenTelemetry::API::Status::StatusCode::Ok, "OK")
    status.ok!.should be_nil
  end

  it "defines #error!" do
    status = OpenTelemetry::API::Status.new(OpenTelemetry::API::Status::StatusCode::Ok, "OK")
    status.error!.should be_nil
  end

  it "defines #unset!" do
    status = OpenTelemetry::API::Status.new(OpenTelemetry::API::Status::StatusCode::Ok, "OK")
    status.unset!.should be_nil
  end

  it "defines #pb_status_code" do
    status = OpenTelemetry::API::Status.new(OpenTelemetry::API::Status::StatusCode::Ok, "OK")
    status.pb_status_code.should be_nil
  end

  it "defines #to_protobuf" do
    status = OpenTelemetry::API::Status.new(OpenTelemetry::API::Status::StatusCode::Ok, "OK")
    status.to_protobuf.should be_nil
  end

  it "defines #to_json" do
    status = OpenTelemetry::API::Status.new(OpenTelemetry::API::Status::StatusCode::Ok, "OK")
    status.to_json.should be_nil
    status.to_json(JSON::Builder.new(IO::Memory.new)).should be_nil
  end
end
