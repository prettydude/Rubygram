class UserController < ApplicationController
  before_action :authenticate_user!

  def auth
    render json: {
      data: {
        message: "Welcome #{current_user.name}",
        user: current_user
      }
    }, status: 200
  end
end
