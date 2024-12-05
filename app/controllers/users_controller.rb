# frozen_string_literal: true

class UsersController < ApplicationController
  skip_before_action :set_selected_contest, only: :destroy

  def destroy
    current_user.destroy!
    reset_session
    redirect_to root_path, notice: '退会しました'
  end
end
