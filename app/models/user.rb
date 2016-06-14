class User < ActiveRecord::Base

  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User

  has_many :batches
  has_and_belongs_to_many :roles, class_name: 'Role'
  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id'
  belongs_to :invited_by, class_name: 'User'
  has_many :users, foreign_key: 'creator_id'
  has_and_belongs_to_many :repositories
  has_and_belongs_to_many :collections

  scope :pending_invitation_response, -> { where('invitation_sent_at IS NOT NULL AND invitation_accepted_at IS NULL') }
  scope :admin_created,               -> { where('invitation_sent_at IS NOT NULL') }
  scope :invited,                     -> { where('invitation_accepted_at IS NOT NULL') }
  scope :active,                      -> { where('(invitation_sent_at IS NOT NULL and invitation_accepted_at IS NOT NULL) OR invitation_sent_at IS NULL') }

  after_initialize :set_default_role

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :lockable,
         :recoverable, :rememberable, :trackable, :validatable

  def self.get_version_author(version)
    find(version.terminator) if version.terminator
  end

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

  def uploader?
    roles.where(name: 'uploader').exists?
  end

  def basic?
    roles.where(name: 'basic').exists?
  end

  def manages?(user)
    users.include? user
  end

  private

  def set_default_role
    self.roles << Role.where(name: 'basic')
  end

end

