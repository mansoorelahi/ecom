class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable
  #devise :omniauthable, :omniauth_providers => [:facebook]


  ##callbacks

  before_save do |user|
    if user.first_name? and user.last_name.blank?
      user.first_name = user.email.split("@")[0]
    end
  end

  def self.from_omniauth(auth, current_user)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
      if user.blank?
        user = User.new
        user.password = Devise.friendly_token[0,10]
        user.first_name = auth.info.first_name
        user.last_name = auth.info.last_name
        user.email = auth.info.email
        auth.provider == "twitter" ?  user.save(:validate => false) :  user.save
      end
    user
  end

  ##Methods
  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    unless user
      user = User.new(:first_name => auth.extra.raw_info.name,
                      :provider => auth.provider,
                      :uid => auth.uid,
                      :email => auth.info.email,
                      :password => Devise.friendly_token[0,20]
      )
      user.save
    end
    user
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end

  def self.find_for_omniauth_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    if user
      return user
    else
      registered_user =
          if auth.provider.to_s == "twitter"
            User.where(:email => auth.uid + "@twitter.com").first
          else
            User.where(:email => auth.info.email).first
          end

      if registered_user
        registered_user.update_attributes(:first_name => auth.extra.raw_info.name, :provider => auth.provider, :uid => auth.uid)
        return registered_user
      else
        user = User.new(:first_name => auth.extra.raw_info.name,
                        :provider => auth.provider,
                        :uid => auth.uid,
                        :email => (auth.provider.to_s == "twitter" ? auth.uid + "@twitter.com" : auth.info.email),
                        :password => Devise.friendly_token[0,20],
        )
        user.save
        return user
      end
    end
  end


  def full_name
    "#{self.first_name unless self.first_name.blank?} #{self.last_name unless self.last_name.blank?}"
  end

end
