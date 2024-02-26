# == Schema Information
#
# Table name: workshops
#
#  id         :bigint           not null, primary key
#  instructor :string
#  last_name  :string
#  first_name :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Workshop < ApplicationRecord
  validates :instructor, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  def self.order_by_lastname
    order('last_name asc')
  end

  def display_name
    self.instructor # or whatever column you want
  end
end
