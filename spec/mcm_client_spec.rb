# frozen_string_literal: true

require "spec_helper"

require_relative "../lib/sof/mcm"
require_relative "../lib/sof/mcm/test_helper"

module SOF
  RSpec.describe MCM do
    describe ".client" do
      it "returns a client" do
        expect(described_class.client({"MCM_URL" => "http://example.com/api/swpubs"})).to be_a(MCM::Client)
      end
    end

    describe ".assign" do
      include MCM::TestHelper
      it "PUTS the user to the MCM assignment API" do
        uri = "https://example.com/api/swpubs"
        stub_mcm_list_applications(
          uri:,
          results: [{"id" => "some-app", "uid" => "0987654321"}]
        )
        stub_mcm_put(
          "1234567890",
          status: 200,
          uri:,
          comment: "Assigning user",
          application_uid: "0987654321",
          action: "assign_user_to_application",
          response_body: {"status" => "success"}
        )

        result = described_class.assign("1234567890", application: "some-app", env: {
          "MCM_URL" => uri,
          "MCM_USERNAME" => "mcmapp",
          "MCM_PASSWORD" => "mcmapp"
        })
        data = JSON.parse(result.body)
        expect(data["status"]).to eq("success")
      end
    end
  end

  RSpec.describe MCM::Client do
    include MCM::TestHelper

    describe "applications" do
      it "makes a request to the list_applications endpoint" do
        uri = "https://example.com/api/swpubs"
        http_getter = spy("http_getter")
        client = described_class.new(
          {
            "MCM_URL" => uri,
            "MCM_USERNAME" => "mcmapp",
            "MCM_PASSWORD" => "mcmapp"
          },
          http_getter: http_getter
        )

        client.applications

        expect(http_getter).to have_received(:call).with(
          URI("#{uri}/@list_applications"),
          nil,
          {
            "Accept" => "application/json",
            "Content-Type" => "application/json",
            "Authorization" => "Basic #{Base64.strict_encode64("mcmapp:mcmapp")}"
          }
        )
      end
    end

    def expect_put(
      edipi,
      action,
      username: "mcmapp",
      password: "mcmapp",
      comment: "Assigning user",
      uri: "https://example.com/api/swpubs",
      status: 200,
      body: {status: "success"}
    )
      http_putter = MCM::Put.with_verify(false)
      client = described_class.new(
        {
          "MCM_URL" => uri,
          "MCM_USERNAME" => username,
          "MCM_PASSWORD" => password
        },
        http_putter:
      )

      stub_mcm_put(
        edipi,
        status: status,
        uri:,
        comment:,
        action:,
        response_body: body
      )

      expect(http_putter).to receive(:call).with(
        "#{uri}/@#{action}",
        {
          user_id: edipi,
          application_uid: "mcmapp",
          comment:,
          role: "Pub Member"
        }.to_json,
        {
          "Accept" => "application/json",
          "Content-Type" => "application/json",
          "Authorization" => "Basic #{Base64.strict_encode64("#{username}:#{password}")}"
        }
      ).and_call_original

      yield client
    end

    describe "assign" do
      it "makes a request to the assign endpoint" do
        expect_put("1234567890", "assign_user_to_application") do |client|
          client.assign("1234567890", application_uid: "mcmapp")
        end
      end

      it "raises an error if the response is a failure" do
        expect_put(
          "1234567890",
          "assign_user_to_application",
          status: 500,
          body: {"status" => "failure", "reason" => "something"}
        ) do |client|
          expect {
            client.assign("1234567890", application_uid: "mcmapp")
          }.to raise_error(MCM::Error, %(MCM returned status 500: something))
        end
      end

      it "raises an error if the request times out" do
        http_putter = MCM::Put.with_verify(false)
        uri = "https://example.com/api/swpubs"
        client = described_class.new(
          {
            "MCM_URL" => uri,
            "MCM_USERNAME" => "mcmapp",
            "MCM_PASSWORD" => "mcmapp"
          },
          http_putter:
        )

        stub_mcm_put(
          "1234567890",
          status: 500,
          uri:,
          comment: "Assigning user",
          action: "assign_user_to_application",
          response_body: {}
        )

        expect(http_putter).to receive(:call).with(
          "#{uri}/@assign_user_to_application",
          {
            user_id: "1234567890",
            application_uid: "mcmapp",
            comment: "Assigning user",
            role: "Pub Member"
          }.to_json,
          {
            "Accept" => "application/json",
            "Content-Type" => "application/json",
            "Authorization" => "Basic #{Base64.strict_encode64("mcmapp:mcmapp")}"
          }
        ).and_raise(Net::ReadTimeout)

        expect {
          client.assign("1234567890", application_uid: "mcmapp")
        }.to raise_error(MCM::Error, /MCM request failed with a timeout/)
      end
    end

    describe "unassign" do
      it "makes a request to the unassign endpoint" do
        expect_put(
          "1234567890",
          "unassign_user_from_application",
          comment: "Unassigning user"
        ) do |client|
          client.unassign("1234567890", application_uid: "mcmapp")
        end
      end

      it "raises an error if the response is a failure" do
        expect_put(
          "1234567890",
          "unassign_user_from_application",
          comment: "Unassigning user",
          status: 500,
          body: {"status" => "failure", "reason" => "something"}
        ) do |client|
          expect {
            client.unassign("1234567890", application_uid: "mcmapp")
          }.to raise_error(MCM::Error, %(MCM returned status 500: something))
        end
      end
    end
  end
end
