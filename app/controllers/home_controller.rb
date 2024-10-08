# frozen_string_literal: true

class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]
  def index
    if user_signed_in?
      redirect_to new_contest_path
    else
      render :welcome
    end
  end
end
