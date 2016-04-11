class User < ActiveRecord::Base

  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User

  has_many :batches
  has_and_belongs_to_many :roles, class_name: 'Role'
  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id'
  has_many :users, foreign_key: 'creator_id'
  has_and_belongs_to_many :repositories
  has_and_belongs_to_many :collections

  before_create :set_default_role

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :lockable,
         :recoverable, :rememberable, :trackable, :validatable

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    email
  end

  def super?
    roles.where(name: 'super').exists?
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

  private

  def set_default_role
    self.roles << Role.where(name: 'basic')
  end

end

