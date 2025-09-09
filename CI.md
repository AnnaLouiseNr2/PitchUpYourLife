# Continuous Integration & Deployment

This project uses GitHub Actions for automated testing, security scanning, and deployment.

## Workflows

### 🔄 Pull Request Checks (`pr.yml`)
Runs on every pull request to ensure code quality:

- **Tests**: Full test suite with coverage reporting
- **Linting**: RuboCop style checks
- **Security**: Brakeman and bundle audit scans
- **Coverage**: Enforces 30% minimum coverage threshold

### 🧪 Continuous Integration (`ci.yml`)
Runs on pushes to main branches with comprehensive checks:

- **Multi-job pipeline**: Tests, security, and code quality in parallel
- **Database setup**: PostgreSQL service for integration tests
- **Asset compilation**: Precompiles assets for production-like environment
- **Artifact uploads**: Saves security and code quality reports
- **Coverage reporting**: Integrates with Codecov (optional)

### 🚀 Deployment (`deploy.yml`)
Runs on main branch merges and manual triggers:

- **Pre-deployment validation**: Full test suite must pass
- **Coverage gate**: Blocks deployment if coverage drops below threshold
- **Deployment steps**: Placeholder for production deployment
- **Notifications**: Template for deployment notifications

## Setup Requirements

### GitHub Secrets
Configure these secrets in your repository settings:

```
RAILS_MASTER_KEY          # For decrypting credentials
CODECOV_TOKEN            # For coverage reporting (optional)
```

### Branch Protection
Recommended branch protection rules for main/master:

- ✅ Require status checks to pass before merging
- ✅ Require branches to be up to date before merging
- ✅ Require pull request reviews before merging
- ✅ Restrict pushes that create matching branches

### Status Checks
Enable these required status checks:

- `test` (from pr.yml)
- `lint` (from pr.yml) 
- `security` (from pr.yml)

## Local Development

Test your changes locally before pushing:

```bash
# Run the same checks as CI
bin/rails test                    # Tests
bundle exec rubocop              # Linting
bundle exec brakeman --quiet     # Security
bundle exec bundle audit         # Dependency security

# Generate coverage report
rake test:coverage
```

## Monitoring & Notifications

### Coverage Tracking
- SimpleCov generates detailed coverage reports
- Coverage threshold is enforced at 30%
- Reports are saved as CI artifacts

### Security Scanning
- **Brakeman**: Static security analysis for Rails
- **Bundle Audit**: Checks for vulnerable gems
- Reports saved as artifacts for review

### Code Quality
- **RuboCop**: Enforces Ruby/Rails style guide
- Parallel execution for faster feedback
- Configurable via `.rubocop.yml`

## Deployment Strategy

The deployment workflow is configured for:

1. **Automated testing** before any deployment
2. **Coverage gates** to maintain quality
3. **Manual deployment** option via GitHub UI
4. **Placeholder steps** for actual deployment integration

### Common Deployment Targets

- **Heroku**: `heroku/deploy-via-git@v4`
- **Railway**: Custom deployment scripts
- **AWS**: EC2/ECS deployment actions
- **Docker**: Container registry pushes

## Troubleshooting

### Common CI Issues

1. **Test failures**: Check test output in Actions logs
2. **Coverage drops**: Add tests for new code
3. **Security issues**: Review Brakeman/audit reports
4. **Style violations**: Run `rubocop -a` to auto-fix

### Performance Optimization

- **Caching**: Bundler and npm caches enabled
- **Parallel execution**: RuboCop runs in parallel
- **Service health checks**: Database readiness checks
- **Artifact retention**: 30-day retention for reports

### Local CI Testing

Use [act](https://github.com/nektos/act) to test GitHub Actions locally:

```bash
# Install act (macOS)
brew install act

# Run PR workflow locally
act pull_request -W .github/workflows/pr.yml
```