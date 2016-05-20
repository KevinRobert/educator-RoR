class DashboardController < ApplicationController

before_action :authenticate_user!

  def index
    authorize! :index, SectionTest
    
    @schools = current_user.website_admin? ? School.active : []
    school = current_user.school
    if params[:school].present?
      school = School.find(params[:school])
      @grades = school.available_grades
    else
      @grades = current_user.website_admin? ? @schools.first.available_grades : current_user.school.available_grades rescue []
    end

    # upcoming tests
    Time.zone = ActiveSupport::TimeZone.new("New Delhi")
    @upcoming_tests, @recent_tests = [], []
    
    if params[:grade].present?
      @upcoming_tests = SectionTest.includes(:section)
                                  .where(sections: {school_id: school.id, grade: params[:grade]})
                                  .where("start_at > ?", Time.zone.now)
                                  .order(start_at: :asc)

      @recent_tests = SectionTest.includes(:section)
                                .where(sections: {school_id: school.id, grade: params[:grade]})
                                .where("start_at < ?", Time.zone.now)
                                .order(start_at: :asc)
    end
  end

  def search
    authorize! :index, SectionTest

    school = current_user.school
    school = School.find(params[:school]) if params[:school].present?

    section_tests = []
    if params[:grade].present?
      section_tests = SectionTest.joins(:test, :section)
                                .where(sections: {school_id: school.id, grade: params[:grade]})

      section_tests = section_tests.where(tests: {subject: params[:subject]}) if params[:subject].present?
      section_tests = section_tests.where(tests: {topic: params[:topic]}) if params[:topic].present?
      section_tests = section_tests.where("date(start_at) = ?", params[:test_date]) if params[:test_date].present?
      section_tests = section_tests.select("section_id", "test_id").group(:section_id, :test_id)
    end

    @search_result = []
    section_tests.each do |st|
      row = SectionTest.where(section_id: st.section_id, test_id: st.test_id).order(start_at: :desc).first
      @search_result << row if row.completed_rate >= 50
    end

    respond_to do |format|
      format.html {}
      format.js {} 
      format.json { render json: @search_result, status: :created }
    end
  end

  # Show detail information of test
  def detail
    @section_test = SectionTest.find(params[:id])
    session[:section_test] = params[:id]
    grade = @section_test.section.grade

    # students took this test across all schools in current grade
    all_school_students = User.joins(:section).where(sections: {grade: grade})
    all_students_test = UserTest.where("user_id IN (?) and test_id = ? and status = ?", all_school_students.pluck(:id), @section_test.test_id, UserTest::FINISHED)
                                      .order(score: :desc, time: :asc)

    @all_students_test_taken = []
    all_students_test.each do |student_test|
      @all_students_test_taken << student_test unless @all_students_test_taken.map{|s| s.user_id}.include?(student_test.user_id)
    end

    top_25_score = @all_students_test_taken[(@all_students_test_taken.length.to_f / 4).to_i].score
    top_50_score = @all_students_test_taken[(@all_students_test_taken.length.to_f * 2 / 4).to_i].score
    top_75_score = @all_students_test_taken[(@all_students_test_taken.length.to_f * 3 / 4).to_i].score

    # students took this test in current school and grade
    school_students = User.joins(:section).where(sections: {grade: grade, school_id: @section_test.section.school_id})
    students_test = UserTest.where("user_id IN (?) and test_id = ? and status = ?", school_students.pluck(:id), @section_test.test_id, UserTest::FINISHED)
                                      .order(score: :desc, time: :asc)

    @students_test_taken = []
    students_test.each do |student_test|
      @students_test_taken << student_test unless @students_test_taken.map{|s| s.user_id}.include?(student_test.user_id)
    end

    @school_completion_rate = (@students_test_taken.length.to_f*100/school_students.length.to_f).to_i

    @top_25_students, @top_50_students, @top_75_students, @last_students = [], [], [], []
    @students_test_taken.each do |student_test|
      if student_test.score >= top_25_score
        @top_25_students << student_test unless @top_25_students.map{|s| s.user_id}.include?(student_test.user_id)
      elsif student_test.score >= top_50_score
        @top_50_students << student_test unless @top_50_students.map{|s| s.user_id}.include?(student_test.user_id)
      elsif student_test.score >= top_75_score
        @top_75_students << student_test unless @top_75_students.map{|s| s.user_id}.include?(student_test.user_id)
      else
        @last_students << student_test unless @last_students.map{|s| s.user_id}.include?(student_test.user_id)
      end
    end

    # students took this test in current school and grade and section
    section_students = User.joins(:section).where(sections: {grade: grade, school_id: @section_test.section.school_id,id: @section_test.section_id})
    section_students_test = UserTest.where("user_id IN (?) and test_id = ? and status = ?", section_students.pluck(:id), @section_test.test_id, UserTest::FINISHED)
                                      .order(score: :desc, time: :asc)

    @section_students_test_taken = []
    section_students_test.each do |student_test|
      @section_students_test_taken << student_test unless @section_students_test_taken.map{|s| s.user_id}.include?(student_test.user_id)
    end

    @section_completion_rate = (@section_students_test_taken.length.to_f*100/section_students.length.to_f).to_i

    @top_25_section_students, @top_50_section_students, @top_75_section_students, @last_section_students = [], [], [], []
    @section_students_test_taken.each do |student_test|
      if student_test.score >= top_25_score
        @top_25_section_students << student_test unless @top_25_section_students.map{|s| s.user_id}.include?(student_test.user_id)
      elsif student_test.score >= top_50_score
        @top_50_section_students << student_test unless @top_50_section_students.map{|s| s.user_id}.include?(student_test.user_id)
      elsif student_test.score >= top_75_score
        @top_75_section_students << student_test unless @top_75_section_students.map{|s| s.user_id}.include?(student_test.user_id)
      else
        @last_section_students << student_test unless @last_section_students.map{|s| s.user_id}.include?(student_test.user_id)
      end
    end

  end
end