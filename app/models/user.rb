class User < ActiveRecord::Base

  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User

  has_many :batches
  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id'
  belongs_to :invited_by, class_name: 'User'
  has_many :users, foreign_key: 'creator_id'
  has_many :fulltext_ingests, dependent: :nullify
  has_and_belongs_to_many :repositories
  has_and_belongs_to_many :collections

  scope :pending_invitation_response, -> { where('invitation_sent_at IS NOT NULL AND invitation_accepted_at IS NULL') }
  scope :admin_created,               -> { where('invitation_sent_at IS NOT NULL') }
  scope :invited,                     -> { where('invitation_accepted_at IS NOT NULL') }
  scope :active,                      -> { where('(invitation_sent_at IS NOT NULL and invitation_accepted_at IS NOT NULL) OR invitation_sent_at IS NULL') }

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

  # TODO: decorator method
  # return array of role names
  def roles
    roles = []
    roles << 'super' if is_super
    roles << 'coordinator' if is_coordinator
    roles << 'committer' if is_committer
    roles << 'uploader' if is_uploader
    roles << 'viewer' if is_viewer
    roles << 'pm' if is_pm
    roles
  end

  # TODO: decorator method
  def super?
    is_super
  end

  # TODO: decorator method
  def coordinator?
    is_coordinator
  end

  # TODO: decorator method
  def committer?
    is_committer
  end

  def uploader?
    is_uploader
  end

  def viewer?
    is_viewer
  end

  def pm?
    is_pm
  end

  def basic?
    # user is 'basic' if they are not a coordinator or super user
    is_super || is_coordinator ? false : true
  end

  def manages?(user)
    users.include? user
  end

end

