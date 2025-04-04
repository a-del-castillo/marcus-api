class SessionController < ApplicationController
    def login
        user = User.find_by(username: params[:username])
        if !!user && user.authenticate(params[:password])
            render json: UserSerializer.new(user)
        else
            render json: { status: "error", message: "Login error/user not found" }
        end
    end

    def auto_login
        token = request.headers["Authorization"].split(" ")[1]
        decoded_hash = (JWT.decode(token, secret_key, true, algorithm: "HS256"))
        if !decoded_hash.empty?
            user = User.find_by(id: decoded_hash[0]["user_id"])
            if user
                render json: UserSerializer.new(user)
            else
                render json: { status: "error", message: user.errors.full_messages[0] }
            end
        end
    end

    private
    def session_params
        params.require(:session).permit(:username, :password)
    end

    def secret_key
        Rails.application.credentials.secret_jwt_key
    end
end
