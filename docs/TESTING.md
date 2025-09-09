# Testing Guide

This project uses Rails' built-in test framework (Minitest) with SimpleCov for coverage reporting.

## Running Tests

### Basic test commands:
```bash
# Run all tests
bin/rails test

# Run specific test files
bin/rails test test/models/
bin/rails test test/presenters/
bin/rails test test/integration/

# Run with verbose output
bin/rails test -v
```

### Coverage Reporting

This project uses SimpleCov to track test coverage with a minimum threshold of 30%.

```bash
# Run tests with coverage report
rake test:coverage

# Open coverage report in browser
rake test:coverage_open

# Alternative way to run with coverage
bin/rails test  # SimpleCov runs automatically in test environment
```

The coverage report will be generated in `coverage/index.html` and shows:
- Overall line coverage percentage
- Coverage by file and directory
- Custom groups: Services, Presenters, Jobs
- Untested lines highlighted in red

### Test Structure

- **Integration Tests**: End-to-end user flows in `test/integration/`
- **System Tests**: Browser-based feature tests in `test/system/`
- **Presenter Tests**: View logic tests in `test/presenters/`
- **Unit Tests**: Model and service tests in `test/models/` and `test/services/`

### Coverage Targets

- **Minimum**: 30% line coverage (enforced)
- **Current**: ~37% line coverage
- **Goal**: 60%+ line coverage for production readiness

### Key Testing Features

1. **Fixtures**: Test data in `test/fixtures/`
2. **Mocking**: Using Mocha for stubbing external services
3. **Authentication**: Devise test helpers for user sessions
4. **Coverage Groups**: Services, Presenters, Jobs tracked separately
5. **CI Integration**: Ready for automated testing pipelines

### Writing Good Tests

1. Test the happy path and edge cases
2. Use descriptive test names
3. Keep tests isolated and independent
4. Mock external dependencies (APIs, file I/O)
5. Test both success and failure scenarios
6. Aim for testing behavior, not implementation details