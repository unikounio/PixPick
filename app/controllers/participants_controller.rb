# frozen_string_literal: true

class ParticipantsController < ApplicationController
  before_action :set_contest, only: %i[new create destroy]
  skip_before_action :authenticate_user!, only: :new

  def new
    token = params[:token]
    @contest = Contest.find_by(invitation_token: token)

    if @contest.present?
      session[:contest_id] = @contest.id unless user_signed_in?
    else
      redirect_to root_path, alert: '無効な招待トークンです。'
    end
  end

  def create
    if Participant.exists?(user_id: current_user.id, contest_id: @contest.id)
      flash[:participation_alert] = 'このコンテストは既に参加済みです。'
      redirect_to root_path and return
    end

    if @contest.add_participant(current_user.id)
      flash[:participation_notice] = 'コンテストに参加しました。'
      redirect_to contest_path(@contest)
    else
      flash[:participation_alert] = 'コンテストへの参加に失敗しました。'
      redirect_to root_path
    end
  end

  def destroy
    participant = Participant.find(params[:id])
    participant.destroy!
    if participant.user_id == current_user.id
      redirect_to user_contests_path(current_user), notice: "#{@contest.name}への参加を取り消しました"
    else
      @users = @contest.users
      render turbo_stream: [
        turbo_stream.replace('participants_list', partial: 'contests/participants_list'),
        append_turbo_toast(:success, '参加を取り消しました')
      ]
    end
  end

  private

  def set_contest
    @contest = Contest.find(params[:contest_id])
  end
end
