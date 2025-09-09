class ApplicationsController < ApplicationController

  def new
    @application = Application.new
  end

  def index
    @applications = current_user.applications
    @dashboard = DashboardPresenter.new(current_user, @applications, view_context)
  end

  def show
    @application = Application.find(params[:id])
    @final = @application.finals.last
    @trait = @application.traits.last
    @application_presenter = ApplicationPresenter.new(@application, view_context)

    @final_cl = @final.cl
    @final_pitch = @final.pitch
  end

  def create
    @application = Application.new(application_params)
    @application.user = current_user

    if @application.save

      redirect_to trait_application_path(@application), notice: "Application created!", status: :see_other
      @application.finals.create()
      @application.videos.create()
      @application.traits.create

      ()
    else
      render :new, status: :unprocessable_entity
    end
  end


  def destroy
    @application = Application.find(params[:id])
    if @application.destroy
    redirect_to applications_path, notice: "Application deleted.", status: :see_other
  else
    redirect_to applications_path, alert: "Could not delete.", status: :unprocessable_entity
  end
end


  def trait
    @application = Application.find(params[:id])
    @trait = @application.traits.last
    return unless request.patch?

    @trait.update_columns(first: params[:trait_choice1])
    @trait.update_columns(second: (params[:trait_choice2] == "Other" ? params[:trait_choice2_other] : params[:trait_choice2]))
    @trait.update_columns(third: params[:trait_choice3])
    @trait.update_columns(fourth: (params[:trait_choice4] == "Other" ? params[:trait_choice4_other] : params[:trait_choice4]))

    # @traits = [session[:trait_choice1], session[:trait_choice2], session[:trait_choice3], session[:trait_choice4]]



     @llm_prompt_cl = <<~PROMPT
    ROLE
  You are an experienced HR/TA professional. Generate a print-ready cover letter.

  HARD RULES
  - Output plain text only (no Markdown).
  - Do not output square brackets or placeholder text of any kind.
  - If a value is not provided, omit that line entirely (do not invent data).
  - Keep to 2–3 short paragraphs for the body; total 250–300 words.
  - Match the selected tone and the language of the job posting if specified.
  - Use only the information provided below; do not fabricate facts.


    Applicant profile
    Cover Letter Tone: #{@trait.first}
    Main Professional Strength: #{@trait.second}
    Experience Level: #{@trait.third}
    Career Motivation: #{@trait.fourth}

    STRUCTURE TO FOLLOW
  1) Greeting line: "Dear <recipient or Hiring Team>,"
  2) Body: 2–3 concise paragraphs (250–300 words) explicitly mapping my highlights to the role’s requirements.
     - Be concrete; use metrics from highlights if present.
     - Frame my experience level appropriately and highlight my main strength.
     - Match the requested tone/language.
     - Include exactly one sentence that references a short video pitch; do NOT insert any placeholder link.
       Use wording like: "Here you can find a short video pitch to further elaborate on my skills."
  3) Closing: "Sincerely," on its own line; on the next line print my name if provided, otherwise omit the name line.

       VIDEO PITCH
  - Include exactly one sentence noting that a short video pitch link is included in the application (do NOT print a placeholder URL).

  EXEMPLAR — STYLE ONLY (do not copy nouns, dates, numbers, or phrases)
  ---
  Dear HR Team,
   in response to your five reasons on why to join the your team, here five ways I can contribute.  1 & 2 are covered in my short video pitch. There I elaborate more on how the term “smooth” has accompanied me in my life, being solution-focussed, and my relationship with coffee. Link: Link 3. A role such as yours necessitates the ability to multi-task and juggle changing priorities in a fast-paced environment. From my former position as an executive assistant at Caritas I have experience with supporting management while heading projects and taking on various tasks in day-to-day operations. For instance, during the refugee wave I was tasked with setting up the infrastructure for a refugee camp on top of my usual responsibilities. That included setting up the offices as well as developing budgets, applying for grants and organising short-term support. Key skills here were understanding the big picture, being decisive and a good communicator. 4. Willingness to dive in and figure it out. In another case one of the departments was not doing as well as expected. That became especially evident when comparing the revenue per full-time position and staff utilization. It was my responsibility to determine how best to proceed and which changes to make. After comparing the key figures and procedures to those of other departments, I re-evaluated the cost structure, set up new sources of income and revised staff deployment. That led to an increase of the department’s revenue of 12%. At this point, I don’t know what the day-to-day challenges will be. But I look forward to diving in and figuring them out. 5. Humour. I really like to laugh and find the humour in situations. Usually with a cup of tea in hand. Please let me know if you have any further questions. I look forward to hearing from you,
   Name of sender
  ---
  STYLE NOTES TO EMULATE FROM THE EXEMPLAR
  - Direct, concise opening anchored to the specific company/role.
  - Evidence-driven middle (map my highlights to JD requirements; use metrics only if provided in variables).
  - Friendly-professional voice; clear close with a forward-looking line.
  - If the exemplar uses bullets, you may use a brief list ONLY if my CV/JD lines are already bullet-like; otherwise stick to paragraphs.
  - Never mention entities in the exemplar (e.g., company names, cities) unless they equal the current Company/Location variables.


  IMPORTANT FORMATTING NOTES
  - No bullets unless they already exist in "Key CV highlights" and naturally fit into a single short list.
  - No headers/titles beyond the conventional letter format.
  - Remove any empty lines that would arise from missing values; avoid more than one consecutive blank line.

  Produce only the final letter text, ready to print.
  PROMPT




@llm_prompt_video = <<~PROMPT
You are an AI career coach. Based on my applicant profile below, generate a first-person
video pitch script I can record. The pitch must run 60–90 seconds total.

Applicant profile:
- Video Tone: #{@trait.first}
- Main Professional Strength (PRIMARY FOCUS): #{@trait.second}
- Experience Level: #{@trait.third}
- Career Motivation (PRIMARY FOCUS): #{@trait.fourth}

Priority & content rules:
- Allocate ~65% of the script to the two PRIMARY FOCUS items (strength + motivation).
- For Strength: include ONE concrete, recent example with an observable outcome (metric, speed-up, risk reduced, user impact, etc.). Do Not invent
- For Motivation: 1–2 lines on why this motivates me AND how it maps to team/role impact (no generic “I’m passionate”).
- Avoid resume lists; pick 1–2 crisp moments only. No jargon, no filler, no placeholders.

Non-fabrication rules (strict):
- Use only the facts in the variables above and in EVIDENCE.
- Never create company names, teams, titles, locations, dates, or metrics that aren’t provided.
- If EXAMPLE_AVAILABLE is "no", do NOT invent an example. Replace the “Strength + proof” part with
  “Strength in action”: 2–3 lines that describe how I typically demonstrate this strength (behaviors,
  decisions, collaboration style), with no specific names, dates, or numbers.

Constraints:
- 135–200 words (aim ~165) to fit 60–90 seconds at natural speaking pace.
- Conversational, confident, and #{ @trait.first} in tone. Write in first person (“I…”).
- Short, speakable sentences. Light stage directions in [brackets] only where helpful.

Structure (with loose timestamps):
- 0:00 Hook (1–2 lines): Introduction by name, quick human opener that hints at my #{@trait.fourth}.
- 0:10 Strength + proof (2–4 lines): spotlight #{@trait.second} with ONE concrete example and outcome.
- 0:35 Motivation & fit (2–3 lines): connect #{@trait.fourth} to the value I’d create in the role/team.
- 0:55 Experience frame (1–2 lines): position my #{@trait.third} level succinctly (no list).
- 1:10 Call-to-action (1–2 lines): invite next step; warm, concise close.

Output format:
1) Total word count at the top (e.g., “~170 words”).
2) Script with timestamps:
   [0:00] ...
   [0:10] ...
   [0:35] ...
   [0:55] ...
   [1:10] ...
PROMPT

 @application.update!(cl_status: "processing", video_status: "processing")

  # enqueue
  CreateClJob.perform_later(@application.id, @llm_prompt_cl)
  CreatePitchJob.perform_later(@application.id, @llm_prompt_video)
  @application.update_columns(name: generate_name(@application))
  @application.update_columns(title: generate_title(@application))

  # go to loading page
  redirect_to generating_application_path(@application)

end






  def overview
    # @traits = [session[:trait_choice1], session[:trait_choice2], session[:trait_choice3], session[:trait_choice4]]
    @application = Application.find(params[:id])
    @trait = @application.traits.last
    @application_presenter = ApplicationPresenter.new(@application, view_context)
    @trait_presenter = TraitPresenter.new([@trait&.first, @trait&.second, @trait&.third, @trait&.fourth])

    @llm_prompt_cl = <<~PROMPT
    ROLE
  You are an experienced HR/TA professional. Generate a print-ready cover letter.

  HARD RULES
  - Output plain text only (no Markdown).
  - Do not output square brackets or placeholder text of any kind.
  - If a value is not provided, omit that line entirely (do not invent data).
  - Keep to 2–3 short paragraphs for the body; total 250–300 words.
  - Match the selected tone and the language of the job posting if specified.
  - Use only the information provided below; do not fabricate facts.


    Applicant profile
    Cover Letter Tone: #{@trait.first}
    Main Professional Strength: #{@trait.second}
    Experience Level: #{@trait.third}
    Career Motivation: #{@trait.fourth}

    STRUCTURE TO FOLLOW
  1) Greeting line: "Dear <recipient or Hiring Team>,"
  2) Body: 2–3 concise paragraphs (250–300 words) explicitly mapping my highlights to the role’s requirements.
     - Be concrete; use metrics from highlights if present.
     - Frame my experience level appropriately and highlight my main strength.
     - Match the requested tone/language.
     - Include exactly one sentence that references a short video pitch; do NOT insert any placeholder link.
       Use wording like: "Here you can find a short video pitch to further elaborate on my skills."
  3) Closing: "Sincerely," on its own line; on the next line print my name if provided, otherwise omit the name line.

       VIDEO PITCH
  - Include exactly one sentence noting that a short video pitch link is included in the application (do NOT print a placeholder URL).

  EXEMPLAR — STYLE ONLY (do not copy nouns, dates, numbers, or phrases)
  ---
  Dear HR Team,
   in response to your five reasons on why to join the your team, here five ways I can contribute.  1 & 2 are covered in my short video pitch. There I elaborate more on how the term “smooth” has accompanied me in my life, being solution-focussed, and my relationship with coffee. Link: Link 3. A role such as yours necessitates the ability to multi-task and juggle changing priorities in a fast-paced environment. From my former position as an executive assistant at Caritas I have experience with supporting management while heading projects and taking on various tasks in day-to-day operations. For instance, during the refugee wave I was tasked with setting up the infrastructure for a refugee camp on top of my usual responsibilities. That included setting up the offices as well as developing budgets, applying for grants and organising short-term support. Key skills here were understanding the big picture, being decisive and a good communicator. 4. Willingness to dive in and figure it out. In another case one of the departments was not doing as well as expected. That became especially evident when comparing the revenue per full-time position and staff utilization. It was my responsibility to determine how best to proceed and which changes to make. After comparing the key figures and procedures to those of other departments, I re-evaluated the cost structure, set up new sources of income and revised staff deployment. That led to an increase of the department’s revenue of 12%. At this point, I don’t know what the day-to-day challenges will be. But I look forward to diving in and figuring them out. 5. Humour. I really like to laugh and find the humour in situations. Usually with a cup of tea in hand. Please let me know if you have any further questions. I look forward to hearing from you,
   Name of sender
  ---
  STYLE NOTES TO EMULATE FROM THE EXEMPLAR
  - Direct, concise opening anchored to the specific company/role.
  - Evidence-driven middle (map my highlights to JD requirements; use metrics only if provided in variables).
  - Friendly-professional voice; clear close with a forward-looking line.
  - If the exemplar uses bullets, you may use a brief list ONLY if my CV/JD lines are already bullet-like; otherwise stick to paragraphs.
  - Never mention entities in the exemplar (e.g., company names, cities) unless they equal the current Company/Location variables.


  IMPORTANT FORMATTING NOTES
  - No bullets unless they already exist in "Key CV highlights" and naturally fit into a single short list.
  - No headers/titles beyond the conventional letter format.
  - Remove any empty lines that would arise from missing values; avoid more than one consecutive blank line.

  Produce only the final letter text, ready to print.
  PROMPT




@llm_prompt_video = <<~PROMPT
You are an AI career coach. Based on my applicant profile below, generate a first-person
video pitch script I can record. The pitch must run 60–90 seconds total.

Applicant profile:
- Video Tone: #{@trait.first}
- Main Professional Strength (PRIMARY FOCUS): #{@trait.second}
- Experience Level: #{@trait.third}
- Career Motivation (PRIMARY FOCUS): #{@trait.fourth}

Priority & content rules:
- Allocate ~65% of the script to the two PRIMARY FOCUS items (strength + motivation).
- For Strength: include ONE concrete, recent example with an observable outcome (metric, speed-up, risk reduced, user impact, etc.). Do Not invent
- For Motivation: 1–2 lines on why this motivates me AND how it maps to team/role impact (no generic “I’m passionate”).
- Avoid resume lists; pick 1–2 crisp moments only. No jargon, no filler, no placeholders.

Non-fabrication rules (strict):
- Use only the facts in the variables above and in EVIDENCE.
- Never create company names, teams, titles, locations, dates, or metrics that aren’t provided.
- If EXAMPLE_AVAILABLE is "no", do NOT invent an example. Replace the “Strength + proof” part with
  “Strength in action”: 2–3 lines that describe how I typically demonstrate this strength (behaviors,
  decisions, collaboration style), with no specific names, dates, or numbers.

Constraints:
- 135–200 words (aim ~165) to fit 60–90 seconds at natural speaking pace.
- Conversational, confident, and #{ @trait.first} in tone. Write in first person (“I…”).
- Short, speakable sentences. Light stage directions in [brackets] only where helpful.

Structure (with loose timestamps):
- 0:00 Hook (1–2 lines): Introduction by name, quick human opener that hints at my #{@trait.fourth}.
- 0:10 Strength + proof (2–4 lines): spotlight #{@trait.second} with ONE concrete example and outcome.
- 0:35 Motivation & fit (2–3 lines): connect #{@trait.fourth} to the value I’d create in the role/team.
- 0:55 Experience frame (1–2 lines): position my #{@trait.third} level succinctly (no list).
- 1:10 Call-to-action (1–2 lines): invite next step; warm, concise close.

Output format:
1) Total word count at the top (e.g., “~170 words”).
2) Script with timestamps:
   [0:00] ...
   [0:10] ...
   [0:35] ...
   [0:55] ...
   [1:10] ...
PROMPT

end

def status
  app = Application.find(params[:id])
  render json: {
    cl_status: app.cl_status,
    video_status: app.video_status
  }
end

def generating
  @application = Application.find(params[:id])
end


  def generate_cl
    @application = Application.find(params[:id])
    ai_service = AiContentService.new(@application)
    prompt = params[:prompt_cl]

    result = ai_service.generate_cover_letter(prompt)

    if result[:success]
      @message = result[:content]
      # Save the new generated content to database
      @application.update!(cl_message: @message)

      # Clear the finalized content since we have new content
      if @application.finals.last.present?
        @application.finals.last.update(cl: nil)
      end

      redirect_to overview_application_path(@application), notice: "Cover letter regenerated."
    else
      redirect_to overview_application_path(@application), alert: "Failed to generate cover letter: #{result[:error]}"
    end
  end



  def generate_video
    @application = Application.find(params[:id])
    ai_service = AiContentService.new(@application)
    prompt = params[:prompt_video]

    result = ai_service.generate_pitch_script(prompt)

    if result[:success]
      @message = result[:content]
      # Save the new generated content to database
      @application.update!(video_message: @message)

      # Clear the finalized content since we have new content
      if @application.finals.last.present?
        @application.finals.last.update(pitch: nil)
      end

      respond_to do |format|
        format.html { redirect_to overview_application_path(@application), notice: "Video pitch regenerated." }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { redirect_to overview_application_path(@application), alert: "Failed to generate video pitch: #{result[:error]}" }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("error", partial: "error", locals: { message: "Failed to generate video pitch: #{result[:error]}" }) }
      end
    end
  end

  def final_cl
    @application = Application.find(params[:id])
    @final_cl = params[:final_cl].to_s
    @final = @application.finals.last
    @final.cl = @final_cl
    @final.save
  end

  def final_pitch
    @application = Application.find(params[:id])
    @final_pitch = params[:final_pitch].to_s
    @final = @application.finals.last
    @final.pitch = @final_pitch
    @final.save
  end

  def video_page
    @application = Application.find(params[:id])
    @video = @application.videos.last
    @cloudinary_url = @video.file.url if @video&.file&.attached?
  end

  def new_video
    @video = @application.videos.build
  end

  def create_video
    puts 'UPLOAD VIDEO'

    @application = Application.find(params[:id])
    @video = @application.videos.build
    @video.file = params[:video]

    if @video.save
      respond_to do |format|
       format.html do
          redirect_to video_page_application_path(@application),
                      notice: "Video was successfully created."
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


  private

 def generate_name(application)
    ai_service = AiContentService.new(application)
    result = ai_service.extract_company_name

    if result[:success]
      return result[:content]
    else
      Rails.logger.error "Failed to extract company name: #{result[:error]}"
      return "Unknown Company"
    end
  end



   def generate_title(application)
    ai_service = AiContentService.new(application)
    result = ai_service.extract_job_title

    if result[:success]
      return result[:content]
    else
      Rails.logger.error "Failed to extract job title: #{result[:error]}"
      return "Unknown Position"
    end
  end



  def generate_cl_internal(prompt)
    ai_service = AiContentService.new(@application)
    result = ai_service.generate_cover_letter(prompt)

    if result[:success]
      @cl_message = result[:content]
    else
      Rails.logger.error "Failed to generate cover letter: #{result[:error]}"
      @cl_message = "Error generating content. Please try again."
    end
  end

  def generate_video_internal(prompt)
    ai_service = AiContentService.new(@application)
    result = ai_service.generate_pitch_script(prompt)

    if result[:success]
      @video_message = result[:content]
    else
      Rails.logger.error "Failed to generate video pitch: #{result[:error]}"
      @video_message = "Error generating content. Please try again."
    end
  end

  def application_params
    params.require(:application).permit(:job_d, :cv)
  end
end
