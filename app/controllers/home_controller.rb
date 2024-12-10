# frozen_string_literal: true

class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[top terms privacy]

  def top; end

  def terms; end

  def privacy; end
end
