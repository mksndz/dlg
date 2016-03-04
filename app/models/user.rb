class User < ActiveRecord::Base

  has_many :batches
  has_and_belongs_to_many :roles
  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id'
  has_many :users

  if Blacklight::Utils.needs_attr_accessible?
    attr_accessible :email, :password, :password_confirmation
  end

  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    email
  end

  def admin?
    roles.where(name: 'admin').exists?
  end

  def coordinator?
    roles.where(name: 'coordinator').exists?
  end

  def committer?
    roles.where(name: 'committer').exists?
  end

  def basic?
    roles.where(name: 'basic').exists?
  end

end
