class UserSerializer
    include JSONAPI::Serializer
    attributes :username, :user_id, :role

    attribute :token do |object|
        "#{object.get_token}"
    end
end
