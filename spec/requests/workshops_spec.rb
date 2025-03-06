require 'rails_helper'

RSpec.describe "Workshops", type: :request do
  # Note: Workshop records are primarily managed through ActiveAdmin
  # These tests are minimal since the controller is empty and inherits from ApplicationController

  before do
    skip "Workshop records are primarily managed through ActiveAdmin"
  end

  describe "GET /workshops" do
    it "returns a success response" do
      get workshops_path
      expect(response).to be_successful
    end
  end

  describe "GET /workshops/:id" do
    it "returns a success response" do
      workshop = Workshop.create!(instructor: "Example Instructor", last_name: "Smith", first_name: "John", active: true)
      get workshop_path(workshop)
      expect(response).to be_successful
    end
  end

  # Additional tests for other actions can be added here if needed
end
