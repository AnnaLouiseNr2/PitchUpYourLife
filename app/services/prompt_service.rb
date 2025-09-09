# Service class for managing AI prompts and prompt templates
# Centralizes prompt generation logic separate from controllers
class PromptService
  def initialize(prompt_selection)
    @prompt_selection = prompt_selection
  end

  # Generate cover letter prompt based on user's prompt selections
  def generate_coverletter_prompt
    <<~PROMPT
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
      Cover Letter Tone: #{@prompt_selection.tone_preference}
      Main Professional Strength: #{@prompt_selection.main_strength}
      Experience Level: #{@prompt_selection.experience_level}
      Career Motivation: #{@prompt_selection.career_motivation}

      STRUCTURE TO FOLLOW
      1) Greeting line: "Dear <recipient or Hiring Team>,"
      2) Body: 2–3 concise paragraphs (250–300 words) explicitly mapping my highlights to the role's requirements.
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
      In response to your five reasons on why to join your team, here are five ways I can contribute. Points 1 & 2 are covered in my short video pitch. There I elaborate more on how the term "smooth" has accompanied me in my life, being solution-focused, and my relationship with coffee. 

      3. A role such as yours necessitates the ability to multi-task and juggle changing priorities in a fast-paced environment. From my former position as an executive assistant at Caritas I have experience with supporting management while heading projects and taking on various tasks in day-to-day operations. For instance, during the refugee wave I was tasked with setting up the infrastructure for a refugee camp on top of my usual responsibilities. That included setting up the offices as well as developing budgets, applying for grants and organizing short-term support. Key skills here were understanding the big picture, being decisive and a good communicator. 

      4. Willingness to dive in and figure it out. In another case one of the departments was not doing as well as expected. That became especially evident when comparing the revenue per full-time position and staff utilization. It was my responsibility to determine how best to proceed and which changes to make. After comparing the key figures and procedures to those of other departments, I re-evaluated the cost structure, set up new sources of income and revised staff deployment. That led to an increase of the department's revenue of 12%. At this point, I don't know what the day-to-day challenges will be. But I look forward to diving in and figuring them out. 

      5. Humor. I really like to laugh and find the humor in situations. Usually with a cup of tea in hand. Please let me know if you have any further questions. I look forward to hearing from you,
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
  end

  # Generate video pitch prompt based on user's prompt selections
  def generate_video_pitch_prompt
    <<~PROMPT
      You are an AI career coach. Based on my applicant profile below, generate a first-person
      video pitch script I can record. The pitch must run 60–90 seconds total.

      Applicant profile:
      - Video Tone: #{@prompt_selection.tone_preference}
      - Main Professional Strength (PRIMARY FOCUS): #{@prompt_selection.main_strength}
      - Experience Level: #{@prompt_selection.experience_level}
      - Career Motivation (PRIMARY FOCUS): #{@prompt_selection.career_motivation}

      Priority & content rules:
      - Allocate ~65% of the script to the two PRIMARY FOCUS items (strength + motivation).
      - For Strength: include ONE concrete, recent example with an observable outcome (metric, speed-up, risk reduced, user impact, etc.). Do Not invent
      - For Motivation: 1–2 lines on why this motivates me AND how it maps to team/role impact (no generic "I'm passionate").
      - Avoid resume lists; pick 1–2 crisp moments only. No jargon, no filler, no placeholders.

      Non-fabrication rules (strict):
      - Use only the facts in the variables above and in EVIDENCE.
      - Never create company names, teams, titles, locations, dates, or metrics that aren't provided.
      - If EXAMPLE_AVAILABLE is "no", do NOT invent an example. Replace the "Strength + proof" part with
        "Strength in action": 2–3 lines that describe how I typically demonstrate this strength (behaviors,
        decisions, collaboration style), with no specific names, dates, or numbers.

      Constraints:
      - 135–200 words (aim ~165) to fit 60–90 seconds at natural speaking pace.
      - Conversational, confident, and #{@prompt_selection.tone_preference} in tone. Write in first person ("I…").
      - Short, speakable sentences. Light stage directions in [brackets] only where helpful.

      Structure (with loose timestamps):
      - 0:00 Hook (1–2 lines): Introduction by name, quick human opener that hints at my #{@prompt_selection.career_motivation}.
      - 0:10 Strength + proof (2–4 lines): spotlight #{@prompt_selection.main_strength} with ONE concrete example and outcome.
      - 0:35 Motivation & fit (2–3 lines): connect #{@prompt_selection.career_motivation} to the value I'd create in the role/team.
      - 0:55 Experience frame (1–2 lines): position my #{@prompt_selection.experience_level} level succinctly (no list).
      - 1:10 Call-to-action (1–2 lines): invite next step; warm, concise close.

      Output format:
      1) Total word count at the top (e.g., "~170 words").
      2) Script with timestamps:
         [0:00] ...
         [0:10] ...
         [0:35] ...
         [0:55] ...
         [1:10] ...
    PROMPT
  end

  # Get prompt selection summary for display
  def prompt_summary
    {
      tone: @prompt_selection.tone_preference,
      strength: @prompt_selection.main_strength,
      experience: @prompt_selection.experience_level,
      motivation: @prompt_selection.career_motivation,
      profile_name: @prompt_selection.profile_name || "Current Profile",
      last_used: @prompt_selection.last_used_at&.strftime("%B %d, %Y")
    }
  end

  # Create or update user's default prompt selection profile
  def self.create_or_update_default_profile(user, selections)
    default_profile = user.prompt_selections.find_by(is_default_profile: true) ||
                     user.prompt_selections.build(is_default_profile: true)
    
    default_profile.assign_attributes(
      tone_preference: selections[:tone_preference],
      main_strength: selections[:main_strength],
      experience_level: selections[:experience_level],
      career_motivation: selections[:career_motivation],
      profile_name: selections[:profile_name] || "Default Profile",
      last_used_at: Time.current
    )
    
    default_profile.save!
    default_profile
  end

  # Get user's prompt selection profiles
  def self.user_profiles(user, limit = 5)
    user.prompt_selections
        .order(last_used_at: :desc, created_at: :desc)
        .limit(limit)
        .map do |profile|
          {
            id: profile.id,
            name: profile.profile_name || "Unnamed Profile",
            tone: profile.tone_preference,
            strength: profile.main_strength,
            is_default: profile.is_default_profile,
            last_used: profile.last_used_at&.strftime("%m/%d/%Y"),
            created: profile.created_at.strftime("%m/%d/%Y")
          }
        end
  end

  # Apply prompt selection to application and update usage
  def self.apply_to_application(application, prompt_selection_id)
    prompt_selection = PromptSelection.find(prompt_selection_id)
    
    # Create application-specific copy
    application_prompt = application.prompt_selections.create!(
      tone_preference: prompt_selection.tone_preference,
      main_strength: prompt_selection.main_strength,
      experience_level: prompt_selection.experience_level,
      career_motivation: prompt_selection.career_motivation,
      profile_name: "Applied from: #{prompt_selection.profile_name}",
      user_id: application.user_id,
      last_used_at: Time.current
    )
    
    # Update original profile usage
    prompt_selection.update!(last_used_at: Time.current)
    
    application_prompt
  end

  private

  # Validate that prompt selection has required fields
  def validate_prompt_selection
    required_fields = [:tone_preference, :main_strength, :experience_level, :career_motivation]
    
    required_fields.each do |field|
      if @prompt_selection.send(field).blank?
        raise ArgumentError, "Missing required field: #{field}"
      end
    end
  end
end