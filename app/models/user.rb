# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  devise                 :string
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  generate               :string
#  rails                  :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  user                   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  has_many  :plants, class_name: "Plant", foreign_key: "user_id", dependent: :destroy
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
