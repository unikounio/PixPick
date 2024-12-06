# frozen_string_literal: true

class ParticipantsController < ApplicationController
  before_action :set_contest, only: [:destroy]

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
