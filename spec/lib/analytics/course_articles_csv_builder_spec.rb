# frozen_string_literal: true

require 'rails_helper'
require "#{Rails.root}/lib/analytics/course_articles_csv_builder"

describe CourseArticlesCsvBuilder do
  let(:course) { create(:course) }
  let(:user) { create(:user, registered_at: course.start + 1.minute) }
  let!(:courses_user) { create(:courses_user, course: course, user: user) }

  let(:article) { create(:article) }
  let(:article2) { create(:article, title: 'Second_Article') }
  let(:revision_count) { 5 }
  let(:subject) { described_class.new(course).generate_csv }

  before do
    # multiple revisions for first article
    revision_count.times do |i|
      create(:revision, mw_rev_id: i, user: user, date: course.start + 1.minute, article: article)
    end
    # one revision for second article
    create(:revision, mw_rev_id: 123, user: user, date: course.start + 1.minute, article: article2)
    # revisions with nil and characters, to make sure this does not cause problems
    create(:revision, mw_rev_id: 124, user: user, date: course.start + 1.minute, article: article2,
                      characters: nil)
    create(:revision, mw_rev_id: 125, user: user, date: course.start + 1.minute, article: article2,
                      characters: -500)
  end

  it 'creates a CSV with a header and a row of data for each article' do
    expect(subject.split("\n").count).to eq(3)
  end

  it 'creates an edited CSV article with a rating column' do
    article_headers = subject.split('\n').first
    expect(article_headers.include?('rating')).to be true
  end
end
