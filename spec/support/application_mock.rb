RSpec.configure do |config|
  config.before(:each, type: :request) do
    # Create a mock for Application.active_conference_applications
    mock_active_applications = double("ActiveApplications")

    # Allow the scope to be chainable with where, find_by, etc.
    allow(mock_active_applications).to receive(:where).and_return(mock_active_applications)
    allow(mock_active_applications).to receive(:not).and_return(mock_active_applications)
    allow(mock_active_applications).to receive(:find_by).and_return(nil)
    allow(mock_active_applications).to receive(:last).and_return(nil)
    allow(mock_active_applications).to receive(:pluck).and_return([])
    allow(mock_active_applications).to receive(:each).and_return([])

    # Mock the Application.active_conference_applications class method
    allow(Application).to receive(:active_conference_applications).and_return(mock_active_applications)
  end
end
