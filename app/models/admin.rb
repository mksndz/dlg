class Admin < ActiveRecord::Base

  has_many :batches
  has_and_belongs_to_many :roles, class_name: 'Role'
  belongs_to :creator, class_name: 'Admin', foreign_key: 'creator_id'
  has_many :admins, foreign_key: 'creator_id'
  has_and_belongs_to_many :repositories
  has_and_belongs_to_many :collections

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :lockable,
         :recoverable, :rememberable, :trackable, :validatable


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

end

