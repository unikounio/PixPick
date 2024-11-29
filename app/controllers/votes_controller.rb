# frozen_string_literal: true

class VotesController < ApplicationController
  def create
    @vote = current_user.votes.find_or_initialize_by(entry_id: params[:entry_id])
    @vote.score = params[:score]

    if @vote.save
      render turbo_stream: turbo_stream.append('toast', partial: 'layouts/toast',
                                                        locals: { toasts: [{ type: :success,
                                                                             message: '投票が保存されました！' }] })
    else
      render turbo_stream: turbo_stream.append('toast', partial: 'layouts/toast',
                                                        locals: { toasts: [{ type: :error,
                                                                             message: '投票の保存に失敗しました。' }] })
    end
  end
end
