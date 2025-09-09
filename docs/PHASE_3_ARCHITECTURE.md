# Phase 3 Architecture Plan - ML Predictions & LinkedIn Integration

## 🎯 Phase 3 Objectives

### Core Features to Implement:
1. **LinkedIn Integration**: Profile import, connection analysis, job matching
2. **Advanced ML Predictions**: Success scoring, salary prediction, career path recommendations
3. **Enterprise Capabilities**: Multi-user management, advanced analytics, API access

## 🏗️ Modular Service Architecture

### 1. LinkedIn Integration Services

#### LinkedinAuthService
**Purpose**: Handle LinkedIn OAuth flow and token management
```ruby
class LinkedinAuthService
  def initialize(user)
    @user = user
  end

  def generate_auth_url(state)
    # OAuth URL generation with SSOT configuration
  end

  def exchange_code_for_token(code)
    # Token exchange with error handling
  end

  def refresh_token(linkedin_profile)
    # Token refresh logic
  end

  private

  def linkedin_client
    # Centralized LinkedIn API client
  end
end
```

#### LinkedinProfileService  
**Purpose**: Fetch and sync LinkedIn profile data
```ruby
class LinkedinProfileService
  def sync_profile(linkedin_profile)
    # Fetch profile data and sync to local database
  end

  def analyze_connections(linkedin_profile)
    # Analyze network for job opportunities
  end

  def extract_skills(profile_data)
    # Extract and standardize skills data
  end
end
```

#### LinkedinJobMatchingService
**Purpose**: Match LinkedIn jobs with user profile
```ruby
class LinkedinJobMatchingService
  def find_matching_jobs(user, filters = {})
    # AI-powered job matching based on LinkedIn profile
  end

  def score_job_compatibility(user, job_data)
    # Compatibility scoring algorithm
  end
end
```

### 2. ML Prediction Services

#### CareerPredictionService
**Purpose**: Advanced career trajectory predictions
```ruby
class CareerPredictionService
  def predict_success_probability(application)
    # ML model for application success prediction
  end

  def predict_salary_range(user, job_title, location)
    # Salary prediction based on skills and market data
  end

  def recommend_career_paths(user)
    # Career progression recommendations
  end

  private

  def ml_client
    # Centralized ML service client
  end
end
```

#### SkillTrendAnalysisService
**Purpose**: Market skill trend analysis
```ruby
class SkillTrendAnalysisService  
  def analyze_skill_demand(skills_array)
    # Market demand analysis for skills
  end

  def predict_skill_growth(skill, timeframe)
    # Skill growth prediction
  end

  def recommend_emerging_skills(user_skills)
    # Emerging skill recommendations
  end
end
```

### 3. Enterprise Services

#### TeamManagementService
**Purpose**: Enterprise team and user management
```ruby
class TeamManagementService
  def create_team(organization, team_data)
    # Team creation with role assignments
  end

  def manage_user_permissions(user, permissions)
    # Fine-grained permission management
  end

  def generate_team_analytics(team)
    # Team performance analytics
  end
end
```

#### ApiAccessService
**Purpose**: Enterprise API access management
```ruby
class ApiAccessService
  def generate_api_key(organization)
    # API key generation with rate limiting
  end

  def track_api_usage(api_key, endpoint)
    # Usage tracking and billing
  end

  def enforce_rate_limits(api_key)
    # Rate limiting enforcement
  end
end
```

## 📊 Enhanced Data Models

### 1. LinkedIn Integration Models

#### LinkedinProfile
```ruby
class LinkedinProfile < ApplicationRecord
  belongs_to :user
  
  # LinkedIn API data
  has_encrypted :access_token
  has_encrypted :refresh_token
  
  validates :linkedin_id, presence: true, uniqueness: true
  
  def token_expired?
    expires_at < Time.current
  end
  
  def needs_refresh?
    expires_at < 1.hour.from_now
  end
end
```

#### LinkedinConnection
```ruby
class LinkedinConnection < ApplicationRecord
  belongs_to :linkedin_profile
  
  # Connection analysis data
  jsonb :connection_data
  
  scope :mutual_connections, -> { where(mutual: true) }
  scope :in_target_companies, -> { where("connection_data->>'company' IN (?)", target_companies) }
end
```

### 2. ML Prediction Models

#### PredictionResult
```ruby
class PredictionResult < ApplicationRecord
  belongs_to :user
  belongs_to :predictable, polymorphic: true # Application, User, etc.
  
  # Prediction metadata
  jsonb :prediction_data
  jsonb :model_metadata
  
  validates :prediction_type, inclusion: { in: %w[success_probability salary_range career_path] }
  validates :confidence_score, numericality: { in: 0..1 }
  
  scope :recent, -> { where(created_at: 7.days.ago..Time.current) }
  scope :high_confidence, -> { where('confidence_score > ?', 0.8) }
end
```

### 3. Enterprise Models

#### Organization
```ruby
class Organization < ApplicationRecord
  has_many :teams, dependent: :destroy
  has_many :users, through: :teams
  has_many :api_keys, dependent: :destroy
  
  validates :name, presence: true
  validates :subscription_tier, inclusion: { in: %w[basic premium enterprise] }
  
  def user_limit
    case subscription_tier
    when 'basic' then 10
    when 'premium' then 100
    when 'enterprise' then ApplicationConfig.enterprise_user_limit
    end
  end
end
```

#### Team
```ruby
class Team < ApplicationRecord
  belongs_to :organization
  has_many :team_memberships, dependent: :destroy
  has_many :users, through: :team_memberships
  
  validates :name, presence: true
  
  def admin_users
    users.joins(:team_memberships).where(team_memberships: { role: 'admin' })
  end
end
```

## 🔧 Background Job Architecture

### 1. LinkedIn Data Processing Jobs

#### SyncLinkedinProfileJob
```ruby
class SyncLinkedinProfileJob < ApplicationJob
  queue_as :critical  # High priority for user experience
  
  def perform(linkedin_profile_id)
    linkedin_profile = LinkedinProfile.find(linkedin_profile_id)
    LinkedinProfileService.new.sync_profile(linkedin_profile)
  end
end
```

#### AnalyzeLinkedinNetworkJob  
```ruby
class AnalyzeLinkedinNetworkJob < ApplicationJob
  queue_as :high
  
  def perform(linkedin_profile_id)
    linkedin_profile = LinkedinProfile.find(linkedin_profile_id)
    LinkedinProfileService.new.analyze_connections(linkedin_profile)
  end
end
```

### 2. ML Prediction Jobs

#### GenerateCareerPredictionsJob
```ruby
class GenerateCareerPredictionsJob < ApplicationJob
  queue_as :high
  retry_on StandardError, wait: :exponentially_longer, attempts: 3
  
  def perform(user_id, prediction_types = [])
    user = User.find(user_id)
    service = CareerPredictionService.new(user)
    
    prediction_types.each do |type|
      case type
      when 'success_probability'
        service.generate_success_predictions
      when 'salary_range'
        service.generate_salary_predictions
      when 'career_path'
        service.generate_career_path_predictions
      end
    end
  end
end
```

## 📈 Performance & Scaling Considerations

### 1. Caching Strategy

#### LinkedIn Data Caching
```ruby
# Profile data cache - medium expiry
Rails.cache.fetch("linkedin_profile_#{user_id}", expires_in: ApplicationConfig.cache_expiry_medium) do
  LinkedinProfileService.new.fetch_profile(user)
end

# Job recommendations cache - short expiry (data changes frequently)
Rails.cache.fetch("linkedin_jobs_#{user_id}", expires_in: ApplicationConfig.cache_expiry_short) do
  LinkedinJobMatchingService.new.find_matching_jobs(user)
end
```

#### ML Predictions Caching
```ruby
# Prediction results cache - long expiry (computationally expensive)
Rails.cache.fetch("career_predictions_#{user_id}", expires_in: ApplicationConfig.cache_expiry_long) do
  CareerPredictionService.new.generate_all_predictions(user)
end
```

### 2. Database Optimization

#### Indexes for Phase 3 Features
```sql
-- LinkedIn profile queries
CREATE INDEX idx_linkedin_profiles_user_id ON linkedin_profiles(user_id);
CREATE INDEX idx_linkedin_profiles_token_expiry ON linkedin_profiles(expires_at);

-- ML predictions queries  
CREATE INDEX idx_prediction_results_user_type ON prediction_results(user_id, prediction_type);
CREATE INDEX idx_prediction_results_confidence ON prediction_results(confidence_score DESC);
CREATE INDEX idx_prediction_results_recent ON prediction_results(created_at DESC);

-- Enterprise queries
CREATE INDEX idx_organizations_subscription ON organizations(subscription_tier);
CREATE INDEX idx_team_memberships_role ON team_memberships(team_id, role);
```

### 3. API Rate Limiting

#### LinkedIn API Management
```ruby
class LinkedinApiRateLimiter
  RATE_LIMITS = {
    profile_fetch: { limit: 500, period: 1.hour },
    job_search: { limit: 100, period: 1.hour },
    network_analysis: { limit: 50, period: 1.hour }
  }.freeze
  
  def can_make_request?(user, operation)
    # Redis-based rate limiting logic
  end
  
  def record_request(user, operation)
    # Request tracking
  end
end
```

## 🧪 Testing Strategy

### 1. Service Testing
```ruby
class LinkedinAuthServiceTest < ActiveSupport::TestCase
  def setup
    @user = users(:john)
    @service = LinkedinAuthService.new(@user)
  end
  
  def test_generates_valid_auth_url
    url = @service.generate_auth_url('test-state')
    
    assert_includes url, ApplicationConfig.linkedin_client_id
    assert_includes url, 'test-state'
    assert_includes url, CGI.escape(ApplicationConfig.linkedin_redirect_uri)
  end
  
  def test_handles_token_exchange_success
    # Mock LinkedIn API response
    stub_linkedin_token_response(success: true)
    
    result = @service.exchange_code_for_token('test-code')
    
    assert result[:success]
    assert result[:access_token].present?
  end
end
```

### 2. Integration Testing
```ruby
class LinkedinIntegrationTest < ActionDispatch::IntegrationTest
  def test_complete_linkedin_auth_flow
    user = users(:john)
    sign_in user
    
    # Initiate OAuth
    get '/auth/linkedin'
    assert_redirected_to %r{https://www.linkedin.com/oauth/v2/authorization}
    
    # Mock callback
    get '/auth/linkedin/callback', params: { 
      code: 'test-code',
      state: session[:linkedin_state]
    }
    
    assert_redirected_to dashboard_path
    assert user.reload.linkedin_profile.present?
  end
end
```

## 🚀 Implementation Timeline

### Week 1-2: Foundation
- [ ] ApplicationConfig implementation and testing
- [ ] LinkedIn OAuth flow and basic profile sync
- [ ] Database migrations for new models
- [ ] Basic service structure setup

### Week 3-4: LinkedIn Integration  
- [ ] Complete LinkedIn profile synchronization
- [ ] LinkedIn job matching service
- [ ] Network analysis features
- [ ] LinkedIn data caching and optimization

### Week 5-6: ML Predictions
- [ ] Career prediction service implementation
- [ ] Skill trend analysis service
- [ ] ML model integration and testing
- [ ] Prediction result caching and display

### Week 7-8: Enterprise Features
- [ ] Team management system
- [ ] API access management
- [ ] Advanced analytics dashboard
- [ ] Enterprise user permission system

### Week 9-10: Polish & Launch
- [ ] Performance optimization
- [ ] Comprehensive testing
- [ ] Documentation updates
- [ ] Production deployment

## 🔒 Security Considerations

### 1. LinkedIn Token Security
- Encrypt all OAuth tokens using Rails built-in encryption
- Implement automatic token refresh before expiry
- Secure token storage with proper key management

### 2. ML Data Privacy
- Anonymize user data for ML training
- Implement data retention policies
- Secure API communication with ML services

### 3. Enterprise Data Protection
- Role-based access control
- Audit logging for all enterprise actions
- Data isolation between organizations

---

**Phase 3 Architecture**: Modular, scalable, and maintainable design that builds upon existing Career Companion foundations while adding powerful ML predictions, LinkedIn integration, and enterprise capabilities.