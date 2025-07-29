# PaymentsController RSpec Test Suite

## Overview
This test suite provides comprehensive coverage for the `PaymentsController` in the Bear River Writers' Conference application. The tests cover all public actions, private methods, authentication, authorization, and edge cases.

## Test Coverage

### 1. GET #index
- **Authentication**: Tests both authenticated and unauthenticated user scenarios
- **Behavior**: Verifies redirect to root_url for authenticated users
- **Security**: Ensures unauthenticated users are redirected to sign-in page

### 2. POST #payment_receipt
- **Payment Processing**: Tests successful payment creation with valid callback parameters
- **Duplicate Prevention**: Verifies that duplicate transaction IDs are handled correctly
- **Parameter Validation**: Tests missing required parameters (hash, timestamp, transactionId)
- **Application Status Update**: Confirms application offer_status is updated to "registration_accepted"
- **Authentication**: Ensures only authenticated users can process payments
- **Data Integrity**: Validates all payment attributes are correctly assigned

### 3. POST #make_payment
- **URL Generation**: Tests payment URL generation with correct parameters
- **Amount Handling**: Tests various amount formats (integers, decimals, zero)
- **User Account Format**: Verifies correct user account format in payment URL
- **Environment Configuration**: Tests development vs production credential usage
- **Authentication**: Ensures only authenticated users can initiate payments

### 4. GET #payment_show
- **Payment Display**: Tests assignment of user's current conference payments
- **Cost Calculations**:
  - Total paid amount calculation
  - Total cost calculation (lodging + partner + subscription)
  - Balance due calculation
- **Subscription Handling**: Tests with and without subscription costs
- **Payment Status**: Tests settled vs unsettled payment scenarios
- **Access Control**: Verifies users without payments are redirected
- **Authentication**: Ensures only authenticated users can view payments

### 5. DELETE #delete_manual_payment
- **Admin Authorization**: Tests admin-only access to delete payments
- **Payment Deletion**: Verifies successful payment deletion
- **Response Formats**: Tests both HTML and JSON response formats
- **Error Handling**: Tests non-existent payment scenarios
- **Security**: Ensures regular users cannot delete payments

### 6. Private Methods Testing
- **#verify_payment_callback**: Tests parameter validation for payment callbacks
- **#generate_hash**: Tests payment URL generation logic
- **#current_application**: Tests user application retrieval

### 7. Authentication & Authorization
- **CSRF Protection**: Tests that payment_receipt skips CSRF verification
- **User Authentication**: Verifies authentication requirements for all actions
- **Admin Authorization**: Tests admin-only access for sensitive operations

## Test Data Setup

### Factories Used
- `user`: Standard user with email and authentication
- `admin_user`: Admin user with elevated privileges
- `application`: User's conference application with all required fields
- `application_setting`: Current conference settings
- `lodging`: Accommodation options with costs
- `partner_registration`: Partner registration options with costs
- `payment`: Payment records with various transaction types

### Test Scenarios
- **Happy Path**: Successful payment processing and display
- **Edge Cases**: Zero amounts, decimal amounts, missing parameters
- **Error Conditions**: Duplicate transactions, missing records, unauthorized access
- **Environment Variations**: Development vs production configurations

## Key Testing Patterns

### 1. Authentication Testing
```ruby
context 'when user is authenticated' do
  before { sign_in user }
  # Test authenticated behavior
end

context 'when user is not authenticated' do
  # Test redirect to sign-in
end
```

### 2. Authorization Testing
```ruby
context 'when admin user is authenticated' do
  before { sign_in admin_user }
  # Test admin-only actions
end

context 'when regular user is authenticated' do
  before { sign_in user }
  # Test access denied
end
```

### 3. Data Validation Testing
```ruby
it 'creates payment with correct attributes' do
  # Test all payment attributes are set correctly
end
```

### 4. Business Logic Testing
```ruby
it 'calculates total cost correctly' do
  # Test complex business calculations
end
```

## Coverage Statistics
- **Total Examples**: 45
- **Test Categories**: 7 major areas
- **Actions Covered**: All 5 controller actions
- **Private Methods**: All 3 private methods tested
- **Authentication**: Complete coverage of auth flows
- **Authorization**: Admin vs user access patterns

## Dependencies
- `rails-controller-testing`: For controller-specific testing helpers
- `factory_bot_rails`: For test data generation
- `devise`: For authentication testing
- `rspec-rails`: For Rails-specific RSpec configuration

## Running the Tests
```bash
# Run all PaymentsController tests
bundle exec rspec spec/controllers/payments_controller_spec.rb

# Run with documentation format
bundle exec rspec spec/controllers/payments_controller_spec.rb --format documentation

# Run with coverage
bundle exec rspec spec/controllers/payments_controller_spec.rb --format progress
```

## Maintenance Notes
- Tests use realistic test data that matches production scenarios
- All monetary calculations account for the application's cent-based storage
- Environment-specific behavior is properly mocked and tested
- Authentication flows are tested for both success and failure cases
- Business logic calculations are tested with multiple scenarios
