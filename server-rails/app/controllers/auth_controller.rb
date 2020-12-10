class AuthController < ApplicationController

  def signup
    if params[:name].blank? || params[:display_name].blank? || params[:password].blank?
      render json: {
        "type": "auth:missing-credentials",
        "title": "Bad Request",
        "detail": "The request failed - missing credentials"
      }, status: 400
      return
    end
    local_user = User.find_by(name: params[:name])
    # puts local_user.inspect
    # puts local_user.password.inspect
    VonageConversation.new().users
    local_user = User.find_by(name: params[:name])
    # puts local_user.inspect
    if local_user != nil && local_user.password_digest != nil
      render json: {
        "type": "auth:unauthorized",
        "title": "Bad Request",
        "detail": "The request failed - user already registered"
        }, status: 403 
      return
    end

    local_user = VonageConversation.new().create_user(params[:name], params[:display_name])
    local_user.reload
    local_user.update(password: params[:password])

    other_users = User.all.filter { |u| u != local_user }

    render json: {
      user: {
        id: local_user.vonage_id,
        name: local_user.name,
        display_name: local_user.display_name
      },
      token: local_user.token,
      users: other_users.map { |u| { id: u.vonage_id, name: u.name, display_name: u.display_name } },
      conversations: []
    }
  end

  def login
    if params[:name].blank? || params[:password].blank?
      render json: {
        "type": "auth:missing-credentials",
        "title": "Bad Request",
        "detail": "The request failed - missing credentials"
      }, status: 400
      return
    end
    local_user = User.find_by(name: params[:name])
    if local_user == nil 
      render json: {
        "type": "auth:not-found",
        "title": "Not found",
        "detail": "The request failed - no such user"
        }, status: 404
      return
    end
    if !local_user.authenticate(params[:password])
      render json: {
        "type": "auth:unauthorized",
        "title": "Bad Request",
        "detail": "The request failed due to invalid credentials"
        }, status: 403 
      return
    end

    other_users = User.all.filter { |u| u != local_user }
    
    render json: {
      user: {
        id: local_user.vonage_id,
        name: local_user.name,
        display_name: local_user.display_name
      },
      token: local_user.token,
      users: other_users.map { |u| 
        { id: u.vonage_id, name: u.name, display_name: u.display_name } },
      conversations: []
    }

  end

end



