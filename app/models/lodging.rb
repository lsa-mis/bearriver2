# == Schema Information
#
# Table name: lodgings
#
#  id          :bigint           not null, primary key
#  plan        :string
#  description :string
#  cost        :decimal(, )
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Lodging < ApplicationRecord
  def display_name
    "#{self.plan} - #{self.description} - ( $#{self.cost.to_i} )"
  end
end
