# frozen_string_literal: true

class VotesController < ApplicationController
  def create
    @vote = current_user.votes.find_or_initialize_by(entry_id: params[:entry_id])
    @vote.score = params[:score]

    if @vote.save
      broadcast_vote_feedback
    else
      render turbo_stream: append_turbo_toast(:error, @vote.errors.full_messages.to_sentence)
    end
  end

  private

  def broadcast_vote_feedback
    entry_id = params[:entry_id]
    render turbo_stream: [
      turbo_stream.replace("score_#{entry_id}",
                           partial: 'entries/score',
                           locals: { entry_id:, score: @vote.score }),
      append_turbo_toast(:success, t('activerecord.notices.messages.save', model: t('activerecord.models.vote')))
    ]
  end
end
