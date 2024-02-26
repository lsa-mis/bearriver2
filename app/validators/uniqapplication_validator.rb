class UniqapplicationValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    all_apps = Application.active_conference_applications.where.not(id: [record])

    all_apps.each do |app|
      if app.read_attribute("#{attribute}") == value
        record.errors.add(attribute, "You already have completed an application for this year")
      end
    end
  end
end