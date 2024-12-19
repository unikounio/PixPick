# frozen_string_literal: true

class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[top terms privacy]

  def top
    if user_signed_in?
      redirect_to user_contests_path(current_user)
    else
      render :top
    end
  end

  def terms; end

  def privacy; end
end
