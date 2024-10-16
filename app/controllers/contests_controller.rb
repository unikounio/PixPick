# frozen_string_literal: true

class ContestsController < ApplicationController
  def index
    @contests = current_user.contests
    render :index
  end

  def new
    @contest = Contest.new
    @contests = current_user.contests
  end

  def create
    @contest = current_user.contests.new(contest_params)
    ActiveRecord::Base.transaction do
      @contest.save!
      @contest.participants.create!(user: current_user)
      redirect_to new_contest_entry_path(@contest), notice: 'コンテストを作成しました。'
    end
  rescue ActiveRecord::RecordInvalid
    @contests = current_user.contests
    render turbo_stream: turbo_stream.replace('new_contest_form', partial: 'form', locals: { contest: @contest })
  end

  private

  def contest_params
    params.require(:contest).permit(:name, :deadline)
  end
end
