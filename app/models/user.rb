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

  def full_name
    "#{self.first_name unless self.first_name.blank?} #{self.last_name unless self.last_name.blank?}"
  end
end
