class Admin::QuestionsController < ApplicationController

  before_action :authenticate_user!
  helper_method :sort_column, :sort_direction

  load_and_authorize_resource

  # Save previous page url
  before_filter "save_previous_url", only: [:new, :edit, :destroy, :import]

  def new
    @question = Question.new
    @question.build_answer
    @topics = []
    @concepts = []
    @back_url = session[:my_previous_url]

    render 'edit'
  end

  def index
    @test = Test.find_by_id(params[:test_id])

    @types        = Question.pluck(:question_type).compact.uniq.sort
    @subjects     = Question.pluck(:subject).compact.uniq.sort
    @topics       = Question.pluck(:topic).compact.uniq.sort
    @difficulties = Question.pluck(:difficulty).compact.uniq.sort

    @questions = Question.search(params).order("id ASC").paginate(:page => params[:page])
  end

  def create
    @question = Question.create question_params

    @back_url = session[:my_previous_url]

    if @question.save
      redirect_to @back_url, :notice => "Question was created successfully."
    else
      question_topic @question
      question_concepts @question

      render 'edit', :alert => @question.errors.full_messages
    end
  end

  def edit
    @question = Question.find(params[:id])
    @back_url = session[:my_previous_url]

    question_topic @question
    question_concepts @question
  end

  def update
    @question = Question.find(params[:id])
    @back_url = session[:my_previous_url]

    @question.update_attributes(question_params)
    if @question.valid?
      redirect_to @back_url, :notice => "Question was updated successfully."
    else
      question_topic @question
      question_concepts @question

      render 'edit', :alert => @question.errors.full_messages
    end
  end

  def destroy
    @question = Question.find(params[:id])
    @back_url = session[:my_previous_url]

    unless @question.test_responses.present?
      @question.destroy
      redirect_to @back_url, :notice => "Question was deleted successfully."
    else
      redirect_to @back_url, :alert => "Couldn't delete a question because students had took this question already."
    end
  end

  def import
    @back_url = session[:my_previous_url]
    
    success_rows, failed_rows = Question.import(params[:file])
    if failed_rows.present?
      error_message = "#{failed_rows.to_s} rows was failed due to question type."
      redirect_to @back_url, notice: error_message
    else
      redirect_to @back_url, notice: "#{success_rows} questions imported."
    end
  end

  def sort
    params[:order].each do |key,value|
      Question.find(value[:id]).update_attribute(:position, value[:position])
    end

    render :nothing => true
  end

  def to_test
    @test = Test.find(params[:test_id])
    @test_question_ids = @test.questions.pluck(:id)

    @imported = 0
    params[:q][:selected].each do |q_id|
      unless @test_question_ids.include?(q_id.to_i)
        tq = TestQuestion.create(:test_id => @test.id, :question_id => q_id.to_i)
        @imported += 1 if tq.valid?
      end
    end

    test_questions = TestQuestion.where(:test_id => @test.id).order(id: :asc)
    test_questions.each_with_index do |tq, tq_index|
      tq.update_attributes(:si_no => "Q#{(tq_index + 1).to_s.rjust(2, "0")}")
    end

    @test.reload
    @questions = @test.questions

    render 'admin/tests/questions', :notice => "#{@imported} questions were added."
  end

  def get_topics
    available_topics = Syllabus.where("syllabus in (?)", params[:syllabus])
                              .where(:subject => params[:subject], :grade => params[:grade])
    render json: {:topics => available_topics.to_json}, status: :created and return
  end

  def get_concepts
    available_concepts = Syllabus.where("syllabus in (?)", params[:syllabus])
                              .where(:subject => params[:subject], :grade => params[:grade], :topic => params[:topic])
    render json: {:concepts => available_concepts.to_json}, status: :created and return

  end

  # Save previous page url into session
  def save_previous_url
    session[:my_previous_url] = request.env['HTTP_REFERER'] || ''
  end

  private

  def question_topic(question)
    syllabuses = question.syllabus.present? ? question.syllabus.split(", ") : []
    @topics = Syllabus.where("syllabus in (?)", syllabuses)
                      .where(:subject => question.subject, :grade => question.grade) 
  end

  def question_concepts(question)
    syllabuses = question.syllabus.present? ? question.syllabus.split(", ") : []
    @concepts = Syllabus.where("syllabus in (?)", syllabuses)
                      .where(:subject => question.subject, :grade => question.grade, :topic => question.topic) 
  end

  def question_params
    params.require(:question).permit(:subject, :topic, :grade, :difficulty, :answer_type, :concepts, :question, :image_temp_name, :timeout,
      :description_title, :description, :option1, :option2, :option3, :option4, :solution_description, :image,
      answer_attributes: [options: []], :question_type => [], :syllabus => [])
  end

  def sort_column
    Test.column_names.include?(params[:sort]) ? params[:sort] : 'id'
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end
end