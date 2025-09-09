class ApplicationsController < ApplicationController
  before_action :set_application, only: [:show, :destroy, :trait, :overview, :status, :generating, 
                                        :generate_coverletter, :generate_video, :final_coverletter, 
                                        :final_pitch, :video_page, :create_video, :linkedin_analysis, 
                                        :ml_predictions]

  def new
    @application = Application.new
  end

  def index
    @applications = current_user.applications.includes(:prompt_selections, :finals)
    @dashboard = DashboardPresenter.new(current_user, @applications, view_context)
  end

  def show
    @final = @application.current_final
    @prompt_selection = @application.current_prompt_selection
    @application_presenter = ApplicationPresenter.new(@application, view_context)

    @final_coverletter = @final&.coverletter_content
    @final_pitch = @final&.pitch
  end

  def create
    @application = Application.new(application_params)
    @application.user = current_user

    if @application.save
      # Initialize required associations
      @application.finals.create!
      @application.videos.create!
      @application.prompt_selections.create! # Will be populated in trait action
      
      redirect_to trait_application_path(@application), notice: "Application created!", status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    if @application.destroy
      redirect_to applications_path, notice: "Application deleted.", status: :see_other
    else
      redirect_to applications_path, alert: "Could not delete.", status: :unprocessable_entity
    end
  end

  # Improved trait/prompt selection handling
  def trait
    @prompt_selection = @application.current_prompt_selection || @application.prompt_selections.build
    @user_profiles = PromptService.user_profiles(current_user)
    
    return unless request.patch?

    # Handle applying existing profile
    if params[:apply_profile_id].present?
      existing_profile = current_user.prompt_selections.find(params[:apply_profile_id])
      @prompt_selection = existing_profile.copy_for_application(@application)
    else
      # Handle new selections
      prompt_params = {
        tone_preference: params[:trait_choice1],
        main_strength: params[:trait_choice2] == "Other" ? params[:trait_choice2_other] : params[:trait_choice2],
        experience_level: params[:trait_choice3],
        career_motivation: params[:trait_choice4] == "Other" ? params[:trait_choice4_other] : params[:trait_choice4]
      }
      
      @prompt_selection.update!(prompt_params.merge(user: current_user, last_used_at: Time.current))
      
      # Save as default profile if requested
      if params[:save_as_default].present?
        PromptService.create_or_update_default_profile(current_user, prompt_params.merge(profile_name: params[:profile_name]))
      end
    end

    # Generate AI content using the improved service
    prompt_service = PromptService.new(@prompt_selection)
    coverletter_prompt = prompt_service.generate_coverletter_prompt
    video_prompt = prompt_service.generate_video_pitch_prompt

    # Update application status
    @application.update!(
      coverletter_status: "processing", 
      video_status: "processing",
      name: generate_name(@application),
      title: generate_title(@application)
    )

    # Enqueue background jobs
    CreateClJob.perform_later(@application.id, coverletter_prompt)
    CreatePitchJob.perform_later(@application.id, video_prompt)

    redirect_to generating_application_path(@application)
  end

  def overview
    @prompt_selection = @application.current_prompt_selection
    @application_presenter = ApplicationPresenter.new(@application, view_context)
    
    if @prompt_selection
      @prompt_service = PromptService.new(@prompt_selection)
      @prompt_summary = @prompt_service.prompt_summary
    end
  end

  def status
    render json: {
      coverletter_status: @application.coverletter_status,
      video_status: @application.video_status
    }
  end

  def generating
    # This action just renders the generating view
  end

  def generate_coverletter
    prompt_service = get_prompt_service
    return redirect_with_error("No prompt selection found") unless prompt_service
    
    prompt = params[:prompt_coverletter] || prompt_service.generate_coverletter_prompt
    ai_service = AiContentService.new(@application)
    
    result = ai_service.generate_cover_letter(prompt)
    
    if result[:success]
      @application.update!(coverletter_message: result[:content])
      
      # Clear finalized content since we have new content
      @application.current_final&.update(coverletter_content: nil)
      
      redirect_to overview_application_path(@application), notice: "Cover letter regenerated."
    else
      redirect_to overview_application_path(@application), alert: "Failed to generate cover letter: #{result[:error]}"
    end
  end

  def generate_video
    prompt_service = get_prompt_service
    return redirect_with_error("No prompt selection found") unless prompt_service
    
    prompt = params[:prompt_video] || prompt_service.generate_video_pitch_prompt
    ai_service = AiContentService.new(@application)
    
    result = ai_service.generate_pitch_script(prompt)
    
    if result[:success]
      @application.update!(video_message: result[:content])
      
      # Clear finalized content since we have new content  
      @application.current_final&.update(pitch: nil)
      
      respond_to do |format|
        format.html { redirect_to overview_application_path(@application), notice: "Video pitch regenerated." }
        format.turbo_stream
      end
    else
      error_msg = "Failed to generate video pitch: #{result[:error]}"
      respond_to do |format|
        format.html { redirect_to overview_application_path(@application), alert: error_msg }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("error", partial: "error", locals: { message: error_msg }) }
      end
    end
  end

  def final_coverletter
    final = @application.current_final
    final_content = params[:final_coverletter].to_s
    
    final.update!(coverletter_content: final_content)
    final.finalize!(current_user) if final.content_ready?
    
    head :ok
  end

  def final_pitch
    final = @application.current_final
    final_content = params[:final_pitch].to_s
    
    final.update!(pitch: final_content)
    final.finalize!(current_user) if final.content_ready?
    
    head :ok
  end

  def video_page
    @video = @application.videos.last
    @cloudinary_url = @video&.file&.url if @video&.file&.attached?
  end

  def create_video
    @video = @application.videos.build(file: params[:video])

    if @video.save
      respond_to do |format|
        format.html do
          redirect_to video_page_application_path(@application), notice: "Video was successfully created."
        end
        format.json do
          render json: {
            url: @video.file.url,
            content_type: @video.file.content_type,
            cloudinary_url: @video.file.url
          }
        end
      end
    else
      respond_to do |format|
        format.html { render :new_video, status: :unprocessable_entity }
        format.json { render json: { errors: @video.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # Phase 3: LinkedIn PDF Profile Analysis
  def linkedin_analysis
    return redirect_to @application, alert: "Feature not available" unless ApplicationConfig.ml_predictions_enabled?

    if request.post? && params[:linkedin_profile].present?
      linkedin_service = LinkedinProfileAnalysisService.new(current_user)
      
      # Analyze uploaded LinkedIn profile PDF
      analysis_result = linkedin_service.analyze_profile_pdf(params[:linkedin_profile])
      
      if analysis_result[:success]
        # Store analysis in session for display
        session[:linkedin_analysis] = analysis_result[:analysis]
        
        # Get recommendations
        recommendations_result = linkedin_service.get_profile_recommendations(analysis_result[:analysis])
        session[:linkedin_recommendations] = recommendations_result[:recommendations] if recommendations_result[:success]
        
        # Calculate profile score
        @profile_score = linkedin_service.calculate_profile_score(analysis_result[:analysis])
        
        flash[:notice] = "LinkedIn profile analyzed successfully!"
        redirect_to linkedin_analysis_application_path(@application)
      else
        flash[:alert] = "Failed to analyze LinkedIn profile: #{analysis_result[:error]}"
      end
    end

    @linkedin_analysis = session[:linkedin_analysis]
    @linkedin_recommendations = session[:linkedin_recommendations]
    @profile_score = LinkedinProfileAnalysisService.new(current_user).calculate_profile_score(@linkedin_analysis) if @linkedin_analysis
  end

  # Phase 3: ML Predictions
  def ml_predictions
    return redirect_to @application, alert: "Feature not available" unless ApplicationConfig.ml_predictions_enabled?

    @ml_service = MlPredictionService.new(current_user, @application)
    @prediction_summary = @application.prediction_summary

    if request.post? && params[:generate_predictions].present?
      # Generate comprehensive predictions in background
      GenerateMlPredictionsJob.perform_later(@application.id, current_user.id)
      
      flash[:notice] = "Generating ML predictions... Refresh in a few moments to see results."
      redirect_to ml_predictions_application_path(@application)
    end
  end

  private

  def set_application
    @application = current_user.applications.find(params[:id])
  end

  def application_params
    params.require(:application).permit(:job_d, :cv)
  end

  def get_prompt_service
    prompt_selection = @application.current_prompt_selection
    return nil unless prompt_selection
    
    PromptService.new(prompt_selection)
  end

  def redirect_with_error(message)
    redirect_to overview_application_path(@application), alert: message
  end

  def generate_name(application)
    ai_service = AiContentService.new(application)
    result = ai_service.extract_company_name
    
    result[:success] ? result[:content] : "Unknown Company"
  end

  def generate_title(application)
    ai_service = AiContentService.new(application)
    result = ai_service.extract_job_title
    
    result[:success] ? result[:content] : "Unknown Position"
  end
end