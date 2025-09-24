# Clear existing data in development
if Rails.env.development?
  puts "🧹 Cleaning up existing data..."
  Video.destroy_all if ActiveRecord::Base.connection.table_exists?('videos')
  Final.destroy_all if ActiveRecord::Base.connection.table_exists?('finals')
  PromptSelection.destroy_all if ActiveRecord::Base.connection.table_exists?('prompt_selections')
  Pitch.destroy_all if ActiveRecord::Base.connection.table_exists?('pitches')
  Cl.destroy_all if ActiveRecord::Base.connection.table_exists?('cls')
  Application.destroy_all if ActiveRecord::Base.connection.table_exists?('applications')
  User.destroy_all if ActiveRecord::Base.connection.table_exists?('users')
end

puts "🌱 Creating seed data..."

# Create demo user
demo_user = User.create!(
  email: "demo@example.com",
  password: "123456",
  password_confirmation: "123456"
)
puts "👤 Created demo user: #{demo_user.email}"

# Create your user
your_user = User.create!(
  email: "anna.ullmann@gmail.com",
  password: "123456",
  password_confirmation: "123456"
)
puts "👤 Created your user: #{your_user.email}"

# Sample job descriptions - Software Engineering and Product Management focused
job_descriptions = [
  "We are seeking a Senior Software Engineer to join our platform team. The ideal candidate will have 4-6 years of experience building scalable web applications, expertise in React, Node.js, and cloud technologies. You'll design and implement critical features, mentor junior developers, and contribute to our technical architecture. Experience with microservices, Docker, and AWS is highly valued.",

  "Frontend Engineer position available at a fast-growing fintech startup. We need someone with strong React/TypeScript skills, experience with modern state management (Redux/Zustand), and a passion for building exceptional user experiences. You'll work closely with our design team to implement pixel-perfect interfaces and contribute to our component library. 3-5 years of frontend experience required.",

  "Product Manager role open for our mobile applications team. We're looking for someone with 3-5 years of product management experience, strong analytical skills, and experience with mobile product metrics. You'll define product roadmaps, conduct user research, work with engineering teams, and drive feature development from concept to launch. Experience with A/B testing and user analytics essential.",

  "Backend Engineer position at an established SaaS company. We need someone with expertise in Python/Django, database optimization, and API design. You'll build robust backend services, optimize database performance, and ensure system scalability. 4-7 years of backend development experience required, with knowledge of PostgreSQL, Redis, and distributed systems.",

  "Senior Product Manager role at a B2B technology company. Looking for someone with 5-8 years of product management experience, strategic thinking, and enterprise software expertise. You'll own the product vision, conduct market research, manage stakeholder relationships, and lead cross-functional teams. Experience with SaaS metrics and enterprise sales cycles is essential.",

  "Full Stack Developer position at a healthcare technology startup. We're seeking someone with experience in both frontend (React/Vue) and backend (Node.js/Python) development. You'll build end-to-end features, integrate with healthcare APIs, and ensure HIPAA compliance. 3-6 years of full stack experience required, healthcare domain knowledge is a plus.",

  "Staff Software Engineer role at a growing e-commerce platform. We need a technical leader with 7+ years of experience, system design expertise, and mentorship skills. You'll architect scalable solutions, lead technical initiatives, and guide engineering best practices. Experience with high-traffic systems, microservices, and cloud infrastructure required.",

  "Product Owner position for our data analytics platform. Looking for someone with 4-6 years of product experience, strong technical background, and experience with data products. You'll work with data scientists and engineers to build analytics tools, define data requirements, and ensure product-market fit. SQL knowledge and analytics experience essential.",

  "DevOps Engineer role at a fast-scaling startup. We need someone with expertise in CI/CD pipelines, container orchestration (Kubernetes), and cloud infrastructure (AWS/GCP). You'll automate deployment processes, monitor system performance, and ensure high availability. 3-5 years of DevOps experience with infrastructure-as-code knowledge required.",

  "Senior Product Manager role for our enterprise platform. We're seeking someone with 6+ years of product management experience, B2B software expertise, and customer-facing skills. You'll define enterprise features, conduct customer interviews, manage product roadmaps, and work with sales teams. Experience with enterprise software and customer success is crucial."
]

company_names = ["TechFlow Solutions", "FinanceApp Inc", "MobileFirst Labs", "DataSphere Systems", "CloudScale Technologies", "HealthTech Innovations", "EcommercePro Platform", "Analytics360", "DevOps Masters", "Enterprise Solutions Ltd"]

job_titles = ["Senior Software Engineer", "Frontend Engineer", "Product Manager", "Backend Engineer", "Senior Product Manager", "Full Stack Developer", "Staff Software Engineer", "Product Owner", "DevOps Engineer", "Senior Product Manager"]

# Sample traits for software engineering and product management roles
sample_traits = [
  {
    first: "Professional and formal",
    second: "Technical expertise and problem-solving",
    third: "Senior level (6–10 years)",
    fourth: "Building innovative solutions"
  },
  {
    first: "Enthusiastic and energetic",
    second: "Creativity and innovation",
    third: "Mid-level (3–5 years)",
    fourth: "Working with great teams"
  },
  {
    first: "Friendly and approachable",
    second: "Communication and collaboration",
    third: "Mid-level (3–5 years)",
    fourth: "Making a meaningful impact"
  },
  {
    first: "Confident and assertive",
    second: "Technical expertise and problem-solving",
    third: "Senior level (6–10 years)",
    fourth: "Solving complex challenges"
  },
  {
    first: "Professional and formal",
    second: "Leadership and team management",
    third: "Senior level (6–10 years)",
    fourth: "Professional growth and learning"
  },
  {
    first: "Enthusiastic and energetic",
    second: "Technical expertise and problem-solving",
    third: "Mid-level (3–5 years)",
    fourth: "Building innovative solutions"
  },
  {
    first: "Confident and assertive",
    second: "Leadership and team management",
    third: "Expert level (10+ years)",
    fourth: "Making a meaningful impact"
  },
  {
    first: "Friendly and approachable",
    second: "Analytical and data-driven approach",
    third: "Senior level (6–10 years)",
    fourth: "Working with great teams"
  },
  {
    first: "Professional and formal",
    second: "Technical expertise and problem-solving",
    third: "Mid-level (3–5 years)",
    fourth: "Solving complex challenges"
  },
  {
    first: "Confident and assertive",
    second: "Communication and collaboration",
    third: "Senior level (6–10 years)",
    fourth: "Professional growth and learning"
  }
]

# Sample generated content for software engineering and product management roles
sample_cover_letters = [
  "Dear Engineering Team,\n\nI am excited to apply for the Senior Software Engineer position at TechFlow Solutions. Your company's focus on building scalable web applications and technical excellence strongly aligns with my software engineering expertise and passion for creating robust solutions.\n\nIn my current role, I architected a microservices platform that improved system performance by 40% and reduced deployment time by 60%. My experience includes building React applications, designing RESTful APIs, and implementing cloud infrastructure on AWS. I have successfully mentored 3 junior developers and led technical initiatives that resulted in more efficient development processes.\n\nI am particularly drawn to TechFlow Solutions because of your commitment to modern technologies and engineering best practices. I would welcome the opportunity to discuss how my technical expertise can contribute to your platform team's success.\n\nHere you can find a short video pitch to further elaborate on my skills.\n\nSincerely,\nCandidate",

  "Dear Frontend Team,\n\nI am writing to express my strong interest in the Frontend Engineer position at FinanceApp Inc. Your company's reputation for exceptional user experiences and cutting-edge fintech solutions makes this an ideal opportunity to apply my frontend development expertise.\n\nDuring my 4 years in frontend development, I have built responsive web applications using React and TypeScript that increased user engagement by 35% and improved conversion rates by 25%. My experience includes state management with Redux, component library development, and close collaboration with design teams. I have successfully delivered pixel-perfect interfaces and optimized application performance across multiple projects.\n\nWhat excites me most about FinanceApp Inc is your focus on user-centered design and innovative financial technology. I am confident that my frontend skills and attention to detail would be valuable additions to your development team.\n\nHere you can find a short video pitch to further elaborate on my skills.\n\nSincerely,\nCandidate",

  "Dear Product Team,\n\nI am thrilled to apply for the Product Manager position at MobileFirst Labs. Your company's innovative approach to mobile applications and commitment to data-driven product development strongly resonates with my product management philosophy and career goals.\n\nIn my current product management role, I led the launch of two mobile features that increased user retention by 45% and drove $1.5M in additional revenue. My approach involves extensive user research, A/B testing, and close collaboration with engineering and design teams. I have experience managing product roadmaps, analyzing user metrics, and using agile methodologies to deliver products that truly meet customer needs.\n\nI am particularly excited about MobileFirst Labs' focus on mobile innovation and user analytics. I would love to contribute my strategic thinking and product expertise to help drive your mobile initiatives forward.\n\nHere you can find a short video pitch to further elaborate on my skills.\n\nSincerely,\nCandidate",

  "Dear Backend Team,\n\nI am excited to apply for the Backend Engineer position at DataSphere Systems. Your company's expertise in building scalable SaaS solutions and focus on system optimization perfectly matches my backend development experience and technical interests.\n\nIn my current role, I designed and implemented APIs that handle 10M+ requests daily and optimized database queries that reduced response times by 50%. My experience includes Python/Django development, PostgreSQL optimization, and distributed system architecture. I have successfully built robust backend services and implemented caching strategies that improved overall system performance.\n\nI am particularly drawn to DataSphere Systems because of your commitment to scalable architecture and data-driven solutions. I would welcome the opportunity to discuss how my backend expertise can contribute to your engineering team's success.\n\nHere you can find a short video pitch to further elaborate on my skills.\n\nSincerely,\nCandidate",

  "Dear Product Leadership,\n\nI am writing to express my strong interest in the Senior Product Manager position at CloudScale Technologies. Your company's focus on enterprise software and product innovation makes this an ideal opportunity to apply my extensive product management expertise.\n\nDuring my 6 years in product management, I have successfully launched enterprise features that increased customer satisfaction by 40% and reduced churn by 30%. My experience includes conducting market research, managing complex stakeholder relationships, and leading cross-functional teams. I have worked closely with sales teams to understand customer needs and translated them into successful product strategies.\n\nWhat excites me most about CloudScale Technologies is your commitment to solving complex enterprise challenges through innovative technology. I am confident that my strategic thinking and enterprise software experience would be valuable additions to your product team.\n\nHere you can find a short video pitch to further elaborate on my skills.\n\nSincerely,\nCandidate"
]

sample_video_pitches = [
  "~175 words\n\n[0:00] Hi, I'm excited to apply for your Senior Software Engineer position. What drives me most is building innovative solutions that solve complex technical challenges and scale effectively.\n\n[0:10] My strongest asset is technical expertise and problem-solving. Recently, I architected a microservices platform that improved system performance by 40% and reduced deployment time by 60%. This involved designing scalable APIs, implementing containerization with Docker, and setting up CI/CD pipelines on AWS.\n\n[0:35] What motivates me most is building innovative solutions because software engineering allows you to create systems that can impact millions of users. When you build something robust and scalable, it enables entire teams and businesses to operate more efficiently.\n\n[0:55] I bring 6 years of senior-level experience in full-stack development, having worked with React, Node.js, and cloud technologies across multiple high-traffic applications.\n\n[1:10] I'd love to discuss how I can contribute to your platform team's technical initiatives. Thank you for considering my application!",

  "~170 words\n\n[0:00] Hello! I'm passionate about applying for your Frontend Engineer role. What energizes me most is working with great teams to create exceptional user experiences.\n\n[0:10] My core strength is creativity and innovation. Last year, I built a component library that increased development speed by 50% and improved design consistency across our entire product. This involved creating reusable React components, implementing TypeScript for better developer experience, and collaborating closely with our design team.\n\n[0:35] Working with great teams motivates me because frontend development is inherently collaborative. The best user interfaces come from combining technical expertise with design thinking and user feedback. I thrive in environments where developers, designers, and product managers work together.\n\n[0:55] As a mid-level professional with 4 years of frontend experience, I've successfully delivered responsive applications using modern React and state management.\n\n[1:10] I'm excited to discuss how I can help build amazing user experiences. Looking forward to our conversation!",

  "~165 words\n\n[0:00] Hi there! I'm thrilled to apply for your Product Manager position. What excites me most is making a meaningful impact by building products that truly serve user needs.\n\n[0:10] My strongest skill is communication and collaboration. Recently, I led a cross-functional team that launched two mobile features, increasing user retention by 45% and driving $1.5M in revenue. This required coordinating between engineering, design, and data teams while conducting extensive user research and A/B testing.\n\n[0:35] Making a meaningful impact drives everything I do because product management is about understanding user problems and translating them into solutions that create real value. When products genuinely improve people's lives or work, it creates lasting positive outcomes.\n\n[0:55] I bring 4 years of mid-level product management experience across mobile applications and user analytics.\n\n[1:10] I'd love to contribute to your mobile product strategy and roadmap. Thank you for your consideration!",

  "~180 words\n\n[0:00] Hi, I'm excited to apply for your Backend Engineer position. What drives me most is solving complex challenges through scalable system architecture and efficient data processing.\n\n[0:10] My strongest asset is technical expertise and problem-solving. Recently, I designed APIs that handle 10M+ requests daily and optimized database queries that reduced response times by 50%. This involved implementing caching strategies with Redis, optimizing PostgreSQL queries, and building distributed systems that maintain high availability.\n\n[0:35] What motivates me most is solving complex challenges because backend engineering is about creating the foundation that everything else builds on. When you design robust, scalable systems, you enable entire products and teams to perform at their best.\n\n[0:55] I bring 5 years of senior-level experience in backend development, having worked with Python/Django, database optimization, and distributed system architecture.\n\n[1:10] I'd love to discuss how I can contribute to your backend infrastructure and system optimization. Thank you for considering my application!",

  "~175 words\n\n[0:00] Hello! I'm passionate about applying for your Senior Product Manager role. What energizes me most is professional growth through building products that drive business success.\n\n[0:10] My core strength is leadership and team management. Last year, I launched enterprise features that increased customer satisfaction by 40% and reduced churn by 30%. This involved conducting market research, managing complex stakeholder relationships, and leading cross-functional teams through the entire product lifecycle.\n\n[0:35] Professional growth and learning motivate me because product management in enterprise software requires constantly evolving skills. I stay current with market trends, customer needs, and technology capabilities while mentoring team members to help them develop their product and analytical skills.\n\n[0:55] As a senior-level professional with 6 years of product management experience, I've successfully delivered enterprise software solutions and worked closely with sales teams.\n\n[1:10] I'm excited to discuss how I can help drive your enterprise product strategy. Looking forward to our conversation!"
]

# Create 10 sample applications for demo user only
puts "📝 Creating 10 applications for demo user..."

10.times do |i|
  # Create a dummy PDF file for CV attachment
  dummy_cv_content = "%PDF-1.4\n1 0 obj\n<<\n/Type /Catalog\n/Pages 2 0 R\n>>\nendobj\n2 0 obj\n<<\n/Type /Pages\n/Kids [3 0 R]\n/Count 1\n>>\nendobj\n3 0 obj\n<<\n/Type /Page\n/Parent 2 0 R\n/MediaBox [0 0 612 792]\n>>\nendobj\nxref\n0 4\n0000000000 65535 f \n0000000010 00000 n \n0000000079 00000 n \n0000000173 00000 n \ntrailer\n<<\n/Size 4\n/Root 1 0 R\n>>\nstartxref\n253\n%%EOF"

  application = Application.new(
    user: demo_user,
    job_d: job_descriptions[i],
    name: company_names[i],
    title: job_titles[i],
    coverletter_status: "done",
    video_status: "done",
    coverletter_message: sample_cover_letters[i % sample_cover_letters.length],
    video_message: sample_video_pitches[i % sample_video_pitches.length],
    created_at: rand(30.days).seconds.ago
  )

  # Attach dummy CV
  application.cv.attach(
    io: StringIO.new(dummy_cv_content),
    filename: "#{company_names[i].downcase.gsub(' ', '_')}_cv.pdf",
    content_type: "application/pdf"
  )

  application.save!

  # Create associated records
  traits = sample_traits[i % sample_traits.length]
  prompt_selection = PromptSelection.create!(
    application: application,
    tone_preference: traits[:first],
    main_strength: traits[:second],
    experience_level: traits[:third],
    career_motivation: traits[:fourth]
  )

  final = Final.create!(
    application: application,
    coverletter_content: sample_cover_letters[i % sample_cover_letters.length],
    pitch: sample_video_pitches[i % sample_video_pitches.length]
  )

  video = Video.create!(
    application: application
  )

  puts "✅ Created application: #{application.title} at #{application.name}"
end
