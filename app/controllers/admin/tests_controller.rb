class Admin::TestsController < ApplicationController

  before_action :authenticate_user!
  helper_method :sort_column, :sort_direction

  load_and_authorize_resource

  # Save previous page url
  before_filter "save_previous_url", only: [:new, :edit, :show]

  def new
    @test = Test.new
    @schools = School.active
    @sections = []
    @available_grades = []
    @test_sections = []
    @topics = []

    @back_url = session[:my_previous_url]

    render 'edit'
  end

  def create
    @back_url = session[:my_previous_url]
    Time.zone = ActiveSupport::TimeZone.new("New Delhi")

    @test = Test.new test_params
    if params[:test_section].present?
      params[:test_section].each do |section_id|
        @test.section_tests.build({
          :section_id => section_id,
          :start_at => Time.zone.parse(params[:start_at]),
          :end_at => Time.zone.parse(params[:end_at])
        })
      end
    end

    if @test.save
      redirect_to @back_url, :notice => "Test was created successfully."
    else
      test_topic @test
      flash[:error] = @test.errors.full_messages

      render 'edit', :alert => @test.errors.full_messages
    end
  end

  def index
    @syllabuses = Test.pluck(:syllabus).compact.uniq.sort
    @grades = Test.pluck(:grade).compact.uniq.sort
    @subjects = Test.pluck(:subject).compact.uniq.sort
    @chapters = Test.pluck(:topic).compact.uniq.sort

    if params[:sort].present?
      @tests = Test.search(params)
                  .order(sort_column + ' ' + sort_direction)
                  .paginate(:page => params[:page])
    else
      @tests = Test.search(params).order('id ASC').paginate(:page => params[:page])
    end
  end

  def show
    @test  = Test.find(params[:id])
    @back_url = session[:my_previous_url]
  end

  def edit
    @test = Test.find(params[:id])
    @back_url = session[:my_previous_url]
    @schools = School.active
    @sections = []
    @available_grades = []
    @test_sections = SectionTest.where(:test_id => @test.id)

    test_topic @test
  end

  def update
    @test = Test.find(params[:id])
    @back_url = session[:my_previous_url]

    if @test.update_attributes(test_params)
      redirect_to edit_admin_test_path(@test), :notice => "Test was updated."
    else
      test_topic @test
      flash[:error] = @test.errors.full_messages

      render 'edit', :alert => @test.errors.full_messages
    end
  end

  def destroy
    @test = Test.find(params[:id])
    @back_url = session[:my_previous_url]
    @test.destroy
    
    redirect_to @back_url, :notice => "Test was deleted successfully."
  end

  def destroy_test_section
    section_test = SectionTest.find(params[:test_section_id])
    @back_url = session[:my_previous_url]
    @test = section_test.test
    section_test.destroy

    redirect_to edit_admin_test_path(@test), :notice => "Test-Section was deleted."
  end

  def update_section
    Time.zone = ActiveSupport::TimeZone.new("New Delhi")

    @test = Test.find(params[:test_id])
    @back_url = session[:my_previous_url]

    if params[:school].present?
      school_sections = Section.where(:school_id => params[:school])

      # populate new test-sections
      if params[:test_section].present?
        params[:test_section].each do |section_id|
          st = SectionTest.where(:test_id => @test.id, :section_id => section_id).try(:first)
          if st.present?
            st.update_attributes({
              :start_at => Time.zone.parse(params[:start_at]),
              :end_at => Time.zone.parse(params[:end_at])
            })
          else
            st = @test.section_tests.build({
              :section_id => section_id,
              :start_at => Time.zone.parse(params[:start_at]),
              :end_at => Time.zone.parse(params[:end_at])
            })
          end

          @test.save
        end
      end
    end
    @test_sections = SectionTest.where(:test_id => @test.id)

    redirect_to edit_admin_test_path(@test), :notice => "Test-Section mapping was updated."
  end

  # retrieve test questions
  def questions
    @test = Test.find(params[:test_id])
    @questions = @test.questions
    @back_url = session[:my_previous_url]
  end

  # remove question from test
  def remove_question
    @test = Test.find(params[:test_id])
    @back_url = session[:my_previous_url]
    question = Question.find(params[:question_id])
    TestQuestion.where(test_id: @test.try(:id), question_id: question.try(:id)).destroy_all

    test_questions = TestQuestion.where(:test_id => @test.id).order(id: :asc)
    test_questions.each_with_index do |tq, tq_index|
      tq.update_attributes(:si_no => "Q#{(tq_index + 1).to_s.rjust(2, "0")}")
    end

    @test.reload
    @questions = @test.questions

    redirect_to admin_test_questions_path(@test)
  end

  def view_question
    @test = Test.find(params[:test_id])
    @question = Question.find(params[:question_id])
  end

  # Save previous page url into session
  def save_previous_url
    url = request.env['HTTP_REFERER'] || ''
    session[:my_previous_url] = url unless url.include?("/admin/tests/")
  end

  def get_topics
    available_topics = Syllabus.where("syllabus in (?)", params[:syllabus])
                              .where(:subject => params[:subject], :grade => params[:grade])
    render json: {:topics => available_topics.to_json}, status: :created and return
  end

  private

  def test_topic(test)
    syllabuses = test.syllabus.present? ? test.syllabus.split(", ") : []
    @topics = Syllabus.where("syllabus in (?)", syllabuses)
                      .where(:subject => test.subject, :grade => test.grade) 
  end


  def test_params
    params.require(:test).permit(:name, :subject, :syllabus, :grade, :topic, :timeout, :description, :allow_retry, :report_by)
  end

  def test_section_params
    params.permit(:section_id, :start_at, :end_at)
  end

  def sort_column
    Test.column_names.include?(params[:sort]) ? params[:sort] : 'id'
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

end