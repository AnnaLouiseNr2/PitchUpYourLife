# Rails Upgrade Plan

## Current Status
- **Current Rails Version**: 7.1.5.2
- **Current Ruby Version**: 3.3.5
- **End of Life Date**: October 2025
- **Urgency**: Medium (6-8 months until EOL)

## Recommended Upgrade Path

### Phase 1: Rails 7.2 (Q1 2025)
**Target**: Rails 7.2.x (Latest stable)
**Ruby**: Keep 3.3.5 (compatible)
**Timeline**: 2-3 weeks
**Risk**: Low-Medium

#### Pre-Upgrade Checklist
- [x] Comprehensive test suite (✅ 36.67% coverage)
- [x] CI/CD pipeline in place
- [x] Code quality tools (RuboCop, Brakeman)
- [ ] Staging environment setup
- [ ] Database backup strategy
- [ ] Rollback plan

#### Rails 7.2 Key Changes
1. **Deprecation Removals**: 
   - `Rails.application.secrets` → Use `Rails.application.credentials`
   - Status code `:unprocessable_entity` → Use `:unprocessable_content`

2. **New Features**:
   - Enhanced Solid Queue improvements
   - Better Active Storage integrations
   - Performance optimizations

#### Migration Steps
1. **Update Gemfile**:
   ```ruby
   gem "rails", "~> 7.2.0"
   ```

2. **Run Rails Update**:
   ```bash
   bundle update rails
   bin/rails app:update
   ```

3. **Fix Known Deprecations**:
   ```ruby
   # config/environment.rb - Remove secrets usage
   # Replace unprocessable_entity with unprocessable_content
   ```

4. **Test & Validate**:
   ```bash
   bin/rails test
   rake test:coverage
   bin/quality_check
   ```

### Phase 2: Ruby 3.4 (Q2 2025)
**Target**: Ruby 3.4.x
**Rails**: 7.2.x
**Timeline**: 1 week
**Risk**: Low

Ruby 3.4 offers:
- Performance improvements
- Better memory management
- Enhanced debugging tools

#### Migration Steps
1. Update `.ruby-version` and Gemfile
2. Update Docker/deployment configs
3. Run full test suite
4. Update CI/CD workflows

### Phase 3: Rails 8.0 Preparation (Q3-Q4 2025)
**Target**: Rails 8.0.x (when stable)
**Timeline**: 4-6 weeks
**Risk**: Medium-High

#### Expected Rails 8.0 Changes
1. **Propshaft as default asset pipeline**
2. **Solid Queue as default job queue**
3. **Authentication generators**
4. **Enhanced Hotwire integration**
5. **Breaking changes in Active Record**

## Dependencies Analysis

### Critical Gems to Monitor
```ruby
# Current versions that may need updates
gem "devise"                    # Authentication
gem "ruby_llm"                 # AI integration  
gem "cloudinary"               # File storage
gem "solid_queue"              # Background jobs
gem "pg"                       # Database
```

### Compatibility Matrix
| Gem | Rails 7.2 | Rails 8.0 | Notes |
|-----|-----------|-----------|-------|
| devise | ✅ | ⚠️ | May need update for Rails 8.0 |
| ruby_llm | ✅ | ❓ | Check compatibility |
| cloudinary | ✅ | ✅ | Well maintained |
| solid_queue | ✅ | ✅ | Rails core team |
| pg | ✅ | ✅ | Stable |

## Risk Assessment

### Low Risk Items
- ✅ Standard Rails upgrade path
- ✅ Good test coverage foundation
- ✅ Modern gem dependencies
- ✅ CI/CD pipeline for validation

### Medium Risk Items  
- ⚠️ Custom AI integration (ruby_llm)
- ⚠️ Complex view logic (presenters help mitigate)
- ⚠️ File upload handling (Cloudinary integration)

### High Risk Items
- 🚨 Rails.application.secrets deprecation (needs immediate fix)
- 🚨 Background job queue changes (Solid Queue)
- 🚨 Asset pipeline changes in Rails 8.0

## Preparation Tasks

### Immediate (Before Rails 7.2)
1. **Fix Current Deprecations**:
   ```ruby
   # Replace in config/environment.rb
   Rails.application.credentials.secret_key_base
   ```

2. **Add Rails 8.0 Feature Flags** (when available):
   ```ruby
   # config/application.rb
   config.load_defaults 8.0
   ```

3. **Strengthen Test Coverage**:
   - Target 50%+ coverage
   - Focus on critical paths (AI, authentication, file uploads)

### Pre-Upgrade Testing Strategy
1. **Create upgrade branch**
2. **Run on staging environment** 
3. **Performance benchmarks**
4. **Security validation**
5. **User acceptance testing**

## Timeline & Milestones

### Q1 2025: Rails 7.2 Migration
- Week 1: Environment setup, deprecation fixes
- Week 2: Rails upgrade, dependency updates  
- Week 3: Testing, bug fixes, deployment

### Q2 2025: Ruby 3.4 & Optimization
- Week 1: Ruby upgrade and testing
- Weeks 2-4: Performance optimization, monitoring

### Q3 2025: Rails 8.0 Preparation  
- Month 1: Research and compatibility testing
- Month 2: Migration implementation
- Month 3: Testing and deployment

### Q4 2025: Rails 8.0 Migration
- Before EOL deadline (October 2025)

## Success Metrics
- [ ] Zero security vulnerabilities
- [ ] 95%+ test pass rate
- [ ] Performance baseline maintained
- [ ] No feature regressions
- [ ] Deployment time < 30 minutes

## Rollback Plan
1. **Database snapshots** before migrations
2. **Git tags** for each version
3. **Docker image versioning**
4. **Blue-green deployment** capability
5. **Feature flags** for gradual rollout

## Team Responsibilities
- **Lead Developer**: Upgrade execution, technical decisions
- **QA**: Testing strategy, regression testing  
- **DevOps**: Infrastructure updates, deployment
- **Product**: Feature freeze coordination, UAT

## Resources & References
- [Rails Upgrade Guide](https://guides.rubyonrails.org/upgrading_ruby_on_rails.html)
- [Rails 7.2 Release Notes](https://guides.rubyonrails.org/7_2_release_notes.html)
- [Ruby 3.4 Release Notes](https://www.ruby-lang.org/en/news/2023/12/25/ruby-3-4-0-released/)
- [Dual Boot for Smooth Upgrades](https://github.com/Shopify/bootboot)

## Cost-Benefit Analysis
### Costs
- Development time: ~6-8 weeks total
- Testing effort: ~2-3 weeks  
- Risk of downtime: Low (with proper planning)

### Benefits
- Security patches and support
- Performance improvements
- Access to new Rails 8.0 features
- Developer experience improvements
- Compliance with latest standards