# Career Companion 🚀

**AI-Powered Career Enhancement Platform**

Career Companion is a comprehensive Rails application that leverages artificial intelligence to enhance job seekers' career prospects through CV analysis, personalized content generation, course recommendations, and affiliate-powered learning opportunities.

![Rails](https://img.shields.io/badge/Rails-7.1.5-red.svg)
![Ruby](https://img.shields.io/badge/Ruby-3.3.5-red.svg)
![Coverage](https://img.shields.io/badge/Coverage-36.67%25-brightgreen.svg)
![Build](https://img.shields.io/badge/Build-Passing-brightgreen.svg)

## ✨ Core Features

### 🤖 AI-Powered Content Generation
- **Smart Cover Letters**: AI analyzes your CV and job description to create personalized cover letters
- **Video Pitch Scripts**: Generate compelling ~150-word video pitch scripts with timing cues
- **Company Insights**: Extract company names and job titles from job descriptions
- **Profile-Based Customization**: Save and reuse tone, strengths, experience level, and career motivations

### 🔍 CV Analysis & Optimization *(Phase 2)*
- **ATS Keyword Optimization**: Identify missing keywords to improve ATS compatibility
- **Content Quality Assessment**: Get scoring and feedback on CV structure and presentation
- **Skills Gap Analysis**: Compare your skills against job requirements
- **Matching Score**: Receive compatibility percentage for each application
- **Actionable Suggestions**: Get specific recommendations to improve your CV

### 🧠 AI-Powered ML Predictions *(Phase 3)*
- **Success Probability**: Rule-based algorithms predict application success likelihood
- **Salary Range Estimation**: Market-informed salary predictions with confidence scoring
- **Career Path Recommendations**: AI-generated progression paths and growth opportunities
- **Confidence Scoring**: Transparent confidence levels for all ML predictions
- **Background Processing**: Asynchronous prediction generation with priority queues

### 📄 LinkedIn Profile Enhancement *(Phase 3)*
- **PDF Profile Analysis**: Upload and analyze LinkedIn profile exports without API dependencies
- **Profile Scoring**: Comprehensive scoring system with industry-specific benchmarks
- **Improvement Recommendations**: AI-powered suggestions for profile optimization
- **Timeline Planning**: Structured improvement plans with effort and impact ratings
- **Caching System**: Efficient analysis storage for repeated insights

### 🎓 Personalized Course Recommendations *(Phase 2)*
- **Skills-Based Matching**: Courses recommended based on your skills gaps
- **Learning Path Prioritization**: AI-powered sequencing for optimal skill development
- **Career Impact Analysis**: Understand how courses affect your job prospects
- **Multiple Providers**: Integration with Udemy, Coursera, A Cloud Guru, and more
- **Difficulty Matching**: Courses tailored to your experience level

### 💰 Affiliate Monetization & Tracking *(Phase 2)*
- **Click Tracking**: Comprehensive analytics on course recommendations
- **Conversion Monitoring**: Track when users actually enroll in recommended courses
- **Revenue Analytics**: Monitor affiliate earnings and performance metrics
- **UTM Parameter Support**: Advanced tracking with campaign attribution
- **User Journey Analysis**: Understand how recommendations lead to purchases

### 👤 User Profile Management *(Improved)*
- **Prompt Profiles**: Save and manage multiple personality/tone combinations
- **Default Profiles**: Set preferred settings for quick application creation
- **Usage Tracking**: Monitor which profiles work best for you
- **Profile Sharing**: Apply successful profiles to new applications

## 🏗 Enhanced Architecture

### Backend Services
- **Framework**: Ruby on Rails 7.1.5
- **Language**: Ruby 3.3.5
- **Database**: PostgreSQL with JSONB for analytics
- **Authentication**: Devise
- **Background Jobs**: Solid Queue with AI analysis priority queues
- **File Storage**: Cloudinary + Active Storage
- **AI Integration**: ruby_llm (OpenAI/LLM APIs)

### AI Services *(Phase 2 & 3)*
- **ProfileAnalysisService**: CV analysis and ATS optimization
- **CourseRecommendationService**: Personalized learning recommendations
- **AffiliateTrackingService**: Click and conversion analytics
- **PromptService**: Centralized prompt template management
- **MlPredictionService** *(Phase 3)*: Comprehensive ML prediction engine
- **LinkedinProfileAnalysisService** *(Phase 3)*: PDF-based LinkedIn profile analysis

### Enhanced Data Models
```
User
├── Applications (1:many)
│   ├── CV Analysis (JSONB)
│   ├── Skills Gap Analysis (JSONB)
│   ├── Prompt Selections (1:many)
│   ├── Finals (finalized content with versioning)
│   ├── Clicks (affiliate tracking)
│   └── ML Predictions (1:many) *(Phase 3)*
├── Courses (recommendations)
├── Analytics (performance metrics)
└── ML Predictions *(Phase 3)*
    ├── Success Probability (with confidence scoring)
    ├── Salary Range (min/max/estimated with market data)
    ├── Career Paths (progression recommendations)
    └── Model Metadata (versioning and feature tracking)
```

## 🎯 Complete User Journey

### Phase 1: Application Creation
1. **Upload CV + Job Description** → Text extraction and processing
2. **Select Profile Traits** → Tone, strength, experience, motivation
3. **AI Content Generation** → Personalized cover letter and video pitch
4. **Content Review & Finalization** → Edit and export final materials

### Phase 2: Career Enhancement *(New)*
5. **CV Analysis** → ATS optimization and quality scoring
6. **Skills Gap Identification** → Compare skills vs. job requirements
7. **Course Recommendations** → Personalized learning path suggestions
8. **Affiliate Tracking** → Monitor learning progress and conversions

### Phase 3: ML Predictions & LinkedIn Enhancement *(Latest)*
9. **ML Predictions Generation** → Success probability, salary estimates, career paths
10. **LinkedIn Profile Analysis** → PDF upload and comprehensive profile scoring
11. **Profile Optimization** → AI-powered improvement recommendations
12. **Career Planning** → Strategic guidance based on ML insights

## 📊 Advanced Analytics Dashboard

### User Metrics
- **Application Success Tracking**: Monitor application outcomes
- **Skill Development Progress**: Track course completions
- **Profile Performance**: Compare different prompt profiles
- **Career Growth Indicators**: Analyze job level progression

### Platform Analytics
- **Course Performance**: Track which recommendations convert best
- **Affiliate Revenue**: Monitor earnings by provider and category
- **User Engagement**: Analyze platform usage patterns
- **Content Effectiveness**: Measure AI-generated content success rates

## 🛠 Technical Improvements

### Database Schema Enhancements
- **Renamed `traits` → `prompt_selections`** with descriptive columns
- **Renamed `cl` → `coverletter`** for clarity throughout the application
- **Added courses table** with PostgreSQL array skills matching
- **Added clicks table** for comprehensive affiliate tracking
- **Enhanced finals table** with versioning and finalization workflows

### Service Architecture
```
app/services/
├── ai_content_service.rb          # Core AI content generation
├── profile_analysis_service.rb    # CV analysis and optimization
├── course_recommendation_service.rb # Learning path recommendations
├── affiliate_tracking_service.rb  # Click and conversion tracking
├── prompt_service.rb              # Template and profile management
├── ml_prediction_service.rb       # ML predictions engine (Phase 3)
└── linkedin_profile_analysis_service.rb # LinkedIn PDF analysis (Phase 3)
```

### Background Job System
```
app/jobs/
├── create_cl_job.rb              # Cover letter generation
├── create_pitch_job.rb           # Video pitch generation
├── analyze_cv_job.rb             # CV analysis processing
├── recommend_courses_job.rb      # Course recommendation generation
└── generate_ml_predictions_job.rb # ML predictions processing (Phase 3)
```

## 🚦 Getting Started

### Prerequisites
- Ruby 3.3.5
- Rails 7.1.5+
- PostgreSQL 12+
- Node.js (for asset compilation)
- Redis (for Solid Queue background jobs)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/career-companion.git
   cd career-companion
   ```

2. **Install dependencies**
   ```bash
   bundle install
   npm install
   ```

3. **Database setup**
   ```bash
   bin/rails db:create
   bin/rails db:migrate
   bin/rails db:seed
   ```

4. **Configure environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your API keys
   ```

5. **Start the server and background jobs**
   ```bash
   # Start Rails server
   bin/rails server
   
   # Start background job worker (separate terminal)
   bin/rails solid_queue:start
   ```

### Required Environment Variables
```env
# AI Service
OPENAI_API_KEY=your_openai_key

# File Storage
CLOUDINARY_URL=your_cloudinary_url

# Database (production)
DATABASE_URL=your_postgres_url

# Affiliate Tracking (optional)
AFFILIATE_SECRET_KEY=your_secret_key

# ML Predictions (Phase 3)
ML_SERVICE_ENDPOINT=your_ml_service_url (optional)
ML_SERVICE_API_KEY=your_ml_api_key (optional)
ENABLE_ML_PREDICTIONS=true

# LinkedIn Integration (Phase 3)
LINKEDIN_CLIENT_ID=your_linkedin_client_id (future use)
LINKEDIN_CLIENT_SECRET=your_linkedin_client_secret (future use)
ENABLE_LINKEDIN_INTEGRATION=true
```

## 🔍 Feature Usage Examples

### CV Analysis
```ruby
# Analyze CV for ATS optimization
analysis_service = ProfileAnalysisService.new(application)
result = analysis_service.analyze_cv

# Get missing keywords
missing_keywords = result[:analysis]['ats_keywords']['missing']
# => ["React", "TypeScript", "AWS"]

# Get content quality score
quality_score = result[:analysis]['content_quality']['score']
# => 75
```

### Course Recommendations
```ruby
# Get personalized course recommendations
rec_service = CourseRecommendationService.new(application)
recommendations = rec_service.get_personalized_recommendations

# Access recommended courses
courses = recommendations[:courses]
# => [{title: "Complete React Course", relevance_score: 95, ...}]
```

### Affiliate Tracking
```ruby
# Track course clicks
tracking_service = AffiliateTrackingService.new(user, course_id)
result = tracking_service.track_click(affiliate_url, context)

# Get analytics
analytics = tracking_service.generate_analytics
# => {total_clicks: 150, conversion_rate: 3.2%, revenue: $1,247}
```

### ML Predictions *(Phase 3)*
```ruby
# Generate comprehensive ML predictions
ml_service = MlPredictionService.new(user, application)
result = ml_service.generate_comprehensive_predictions

# Access individual predictions
success_probability = result[:predictions][:success_probability][:success_probability]
# => 0.78 (78% chance of success)

salary_range = result[:predictions][:salary_range][:salary_range]
# => {min: 75000, max: 95000, currency: "USD"}

career_paths = result[:predictions][:career_paths][:career_paths]
# => [{title: "Senior Developer", probability: 0.8, timeline: "2-3 years"}]
```

### LinkedIn Profile Analysis *(Phase 3)*
```ruby
# Analyze uploaded LinkedIn PDF
linkedin_service = LinkedinProfileAnalysisService.new(user)
result = linkedin_service.analyze_profile_pdf(pdf_file)

# Get profile score and recommendations  
profile_score = result[:profile_score]
# => 75

recommendations = result[:recommendations]
# => [{category: "headline", priority: "high", recommendation: "Include keywords"}]

summary = result[:summary]
# => {overall_rating: "Good", strengths_count: 3, improvement_areas_count: 2}
```

## 📈 Performance & Scaling

### Database Optimization
- **PostgreSQL Arrays**: Efficient skills matching with GIN indexes
- **JSONB Columns**: Flexible analytics data storage with indexed queries
- **Foreign Key Constraints**: Data integrity with cascading deletes
- **Selective Indexing**: Optimized queries for high-traffic endpoints

### Background Processing
- **Priority Queues**: AI analysis jobs processed with higher priority
- **Job Retry Logic**: Exponential backoff for failed AI API calls
- **Error Tracking**: Comprehensive logging and monitoring
- **Rate Limiting**: Prevents API quota exhaustion

## 🧪 Testing & Quality

### Testing Coverage
- **Integration Tests**: Core user workflows and AI service integration
- **System Tests**: End-to-end application functionality
- **Service Tests**: AI service mocking and error handling
- **Model Tests**: Data validation and business logic
- **Job Tests**: Background processing and error scenarios

### Quality Tools
```bash
# Run all tests with coverage
rake test:coverage

# Quality assurance checks
bin/quality_check

# Security scanning
bin/brakeman

# Performance monitoring
bin/performance_check
```

## 🚀 Deployment & Production

### Production Features
- **Health Checks**: Kubernetes/Docker compatible endpoints
- **Structured Logging**: JSON logs with correlation IDs
- **Performance Monitoring**: AI service call tracking and timing
- **Error Tracking**: Contextual error reporting with user context
- **Security**: Static analysis, dependency scanning, and data encryption

### Recommended Infrastructure
- **Hosting**: Heroku, Railway, AWS ECS, or similar
- **Database**: Managed PostgreSQL with read replicas
- **Cache**: Redis for sessions and job queues
- **File Storage**: Cloudinary (configured) or AWS S3
- **Monitoring**: New Relic, Sentry, or Datadog integration

## 📚 Documentation

- **[API Documentation](docs/API.md)**: Service interfaces and data models
- **[Testing Guide](docs/TESTING.md)**: Comprehensive testing documentation
- **[CI/CD Guide](docs/CI.md)**: Deployment and automation setup
- **[Phase 2 Features](docs/PHASE_2_FEATURES.md)**: New AI enhancement features
- **[Affiliate Integration](docs/AFFILIATE_GUIDE.md)**: Monetization setup guide
- **[Performance Guide](docs/PERFORMANCE.md)**: Scaling and optimization

## 🔄 Recent Updates (Phase 2)

### Database Schema Restructuring
- ✅ Improved naming conventions (`traits` → `prompt_selections`)
- ✅ Enhanced data relationships with proper foreign keys
- ✅ Added analytics tables for course tracking and affiliate management
- ✅ Implemented versioning system for content management

### AI Feature Expansion
- ✅ CV analysis with ATS keyword optimization
- ✅ Skills gap analysis for targeted learning recommendations
- ✅ Personalized course recommendation engine
- ✅ Affiliate click tracking and conversion analytics

### Architecture Improvements
- ✅ Service-oriented architecture with separated concerns
- ✅ Background job system with priority queues
- ✅ Centralized prompt management service
- ✅ Enhanced error handling and monitoring

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Run quality checks (`bin/quality_check`)
4. Add tests for new functionality
5. Commit your changes with descriptive messages
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request with detailed description

## 📄 License

This project was created by the [Le Wagon coding bootcamp](https://www.lewagon.com) team using [lewagon/rails-templates](https://github.com/lewagon/rails-templates).

## 🆘 Support & Monitoring

### Health Endpoints
- **Basic**: `/health` - Simple application status
- **Detailed**: `/health/detailed` - Comprehensive system status
- **Readiness**: `/ready` - Kubernetes readiness probe
- **Liveness**: `/live` - Kubernetes liveness probe

### Support Channels
- **Documentation**: Comprehensive guides in the `/docs` directory
- **Issues**: Create GitHub issues for bugs or feature requests
- **Performance**: Monitor via `/health/detailed` endpoint
- **Analytics**: Built-in dashboard for usage metrics

---

**Career Companion** - Transforming job seekers into successful candidates through AI-powered career enhancement, personalized learning, and data-driven optimization. 🎯✨

*Phase 3 Complete: Advanced ML predictions and LinkedIn PDF analysis now available. Ready for enterprise deployment and ML model integration.*