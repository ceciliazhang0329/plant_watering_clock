# == Schema Information
#
# Table name: plants
#
#  id                   :integer          not null, primary key
#  last_watered_date    :date
#  other_tips           :string
#  plant_name           :string
#  soil_type            :string
#  sunlight_requirement :string
#  watering_frequency   :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  user_id              :integer
#
class Plant < ApplicationRecord
  belongs_to :user, required: true, class_name: "User", foreign_key: "user_id"
end
