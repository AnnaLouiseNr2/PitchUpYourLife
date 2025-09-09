# Career Companion 🚀

**AI-Powered Job Application Assistant**

Career Companion is a comprehensive Rails application that helps job seekers create personalized cover letters, company insights, and video pitch scripts using artificial intelligence. Upload your CV and job description to get tailored application materials that help you land your dream job.

![Rails](https://img.shields.io/badge/Rails-7.1.5-red.svg)
![Ruby](https://img.shields.io/badge/Ruby-3.3.5-red.svg)
![Coverage](https://img.shields.io/badge/Coverage-36.67%25-brightgreen.svg)
![Build](https://img.shields.io/badge/Build-Passing-brightgreen.svg)

## ✨ Key Features

### 🤖 AI-Powered Content Generation
- **Smart Cover Letters**: AI analyzes your CV and job description to create personalized cover letters
- **Video Pitch Scripts**: Generate compelling ~150-word video pitch scripts with timing cues
- **Company Insights**: Extract company names and job titles from job descriptions
- **Trait-Based Customization**: Select tone, professional strengths, experience level, and career motivation

### 📄 Document Management
- **CV Upload & Analysis**: Upload PDF, DOC, or DOCX files for AI analysis
- **Text Extraction**: Intelligent parsing of CV content for context-aware generation
- **Job Description Processing**: Paste job descriptions for tailored content creation

### 🎯 Application Workflow
- **Multi-Step Process**: Guided workflow from CV upload to final content
- **Real-Time Generation**: Background job processing with live status updates
- **Content Review**: Preview and regenerate content until satisfied
- **Final Export**: Download or copy finalized cover letters and pitch scripts

### 👤 User Management
- **Secure Authentication**: Devise-powered user registration and login
- **Dashboard**: Centralized view of all job applications and their status
- **Application History**: Track all your job applications in one place

## 🏗 Tech Stack

### Backend
- **Framework**: Ruby on Rails 7.1.5
- **Language**: Ruby 3.3.5
- **Database**: PostgreSQL
- **Authentication**: Devise
- **Background Jobs**: Solid Queue
- **File Storage**: Cloudinary + Active Storage
- **AI Integration**: ruby_llm (OpenAI/LLM APIs)

### Frontend
- **Styling**: Bootstrap 5.3
- **JavaScript**: Hotwire (Turbo + Stimulus)
- **Forms**: Simple Form
- **Icons**: Font Awesome 6.1
- **UI Components**: Custom responsive design

### Development & Production
- **Testing**: Minitest + SimpleCov (36.67% coverage)
- **Code Quality**: RuboCop, Brakeman, Bundle Audit
- **CI/CD**: GitHub Actions (3 workflows)
- **Monitoring**: Structured logging, health checks
- **PDF Processing**: PDF Reader gem

## 🗺 Sitemap & Navigation

### Public Pages
```
/ (root)                    # Landing page with hero section
/users/sign_up              # User registration
/users/sign_in              # User login
```

### Authenticated User Areas
```
/applications               # Dashboard - All applications
/applications/new           # Create new application
/applications/:id/trait     # Select personality traits
/applications/:id/overview  # Review generated content
/applications/:id/generating # Live generation status
/applications/:id/video_page # Video pitch creation
```

### Navigation Structure
1. **Landing Page** → Sign up/Login
2. **Dashboard** → View all applications + Create new
3. **New Application** → Upload CV + Job description
4. **Trait Selection** → Choose personality/tone preferences  
5. **AI Generation** → Processing with live updates
6. **Content Review** → Preview cover letter + video script
7. **Finalization** → Export final materials

### Health & Monitoring
```
/health                     # Basic health check
/health/detailed           # Comprehensive system status
/ready                     # Kubernetes readiness probe
/live                      # Kubernetes liveness probe
```

## 🚦 Getting Started

### Prerequisites
- Ruby 3.3.5
- Rails 7.1.5+
- PostgreSQL
- Node.js (for asset compilation)

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
   # Edit .env with your API keys (OpenAI, Cloudinary, etc.)
   ```

5. **Start the server**
   ```bash
   bin/rails server
   ```

6. **Visit the application**
   ```
   http://localhost:3000
   ```

### Required Environment Variables
```env
# AI Service
OPENAI_API_KEY=your_openai_key

# File Storage
CLOUDINARY_URL=your_cloudinary_url

# Database (production)
DATABASE_URL=your_postgres_url
```

## 🧪 Testing & Quality

### Running Tests
```bash
# Run all tests
bin/rails test

# Run with coverage
rake test:coverage

# Run quality checks
bin/quality_check

# Check upgrade readiness
bin/upgrade_check
```

### Code Quality Tools
- **RuboCop**: Style guide enforcement
- **Brakeman**: Security vulnerability scanning
- **Bundle Audit**: Dependency security checks
- **SimpleCov**: Test coverage reporting (36.67% current)

### CI/CD Pipeline
- **Pull Request Checks**: Tests, linting, security scans
- **Continuous Integration**: Full test suite with coverage
- **Deployment Pipeline**: Production-ready with health checks

## 📊 Project Architecture

### Service Layer
- **AiContentService**: Centralized AI content generation
- **CvTextExtractor**: PDF/document text extraction
- **HealthController**: System monitoring and health checks

### Presenter Layer
- **ApplicationPresenter**: Application display logic
- **DashboardPresenter**: User dashboard statistics
- **TraitPresenter**: Trait selection and validation

### Background Jobs
- **CreateClJob**: Asynchronous cover letter generation
- **CreatePitchJob**: Asynchronous video pitch generation

### Data Models
```
User
├── Applications (1:many)
    ├── CV (Active Storage)
    ├── Traits (personality settings)
    ├── Finals (finalized content)
    └── Pitches/CLs (generated content)
```

## 🚀 Deployment

### Production Ready Features
- **Health Checks**: Kubernetes/Docker compatible endpoints
- **Structured Logging**: JSON logs for centralized analysis
- **Error Tracking**: Contextual error reporting
- **Performance Monitoring**: AI service call tracking
- **Security**: Static analysis and dependency scanning

### Recommended Infrastructure
- **Hosting**: Heroku, Railway, AWS, or similar
- **Database**: Managed PostgreSQL
- **File Storage**: Cloudinary (configured)
- **Background Jobs**: Solid Queue (Redis-compatible)
- **Monitoring**: New Relic, Sentry, or Datadog

## 📚 Documentation

- **[Testing Guide](TESTING.md)**: Comprehensive testing documentation
- **[CI/CD Guide](CI.md)**: Deployment and automation setup  
- **[Rails Upgrade Plan](RAILS_UPGRADE_PLAN.md)**: Future-proofing strategy
- **[Observability Guide](OBSERVABILITY.md)**: Monitoring and logging
- **[Implementation Report](IMPLEMENTATION_REPORT.md)**: Engineering phase summary

## 🔧 Development

### Key Commands
```bash
# Quality assurance
bin/quality_check

# Test coverage
rake test:coverage

# Rails upgrade readiness
bin/upgrade_check

# Health check
curl http://localhost:3000/health
```

### Project Status
- ✅ **Production Ready**: Comprehensive testing and monitoring
- ✅ **Enterprise Grade**: CI/CD, security scanning, documentation
- ✅ **Scalable Architecture**: Service layer, background jobs, health checks
- ⚠️ **Rails EOL**: Upgrade plan in place for October 2025 deadline

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Run quality checks (`bin/quality_check`)
4. Commit your changes (`git commit -m 'Add amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

## 📄 License

This project was created by the [Le Wagon coding bootcamp](https://www.lewagon.com) team using [lewagon/rails-templates](https://github.com/lewagon/rails-templates).

## 🆘 Support

- **Documentation**: Check the guides in the repository
- **Issues**: Create a GitHub issue for bugs or feature requests
- **Health Monitoring**: Use `/health/detailed` endpoint for system status

---

**Career Companion** - Empowering job seekers with AI-driven application assistance. Transform your job search with personalized, professional application materials. 🎯