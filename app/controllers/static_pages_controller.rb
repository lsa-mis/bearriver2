class StaticPagesController < ApplicationController

  def index
    redirect_to conference_closed_url unless current_application_open?
  end

  def about
  end

  def contact
  end

  def privacy
  end

  def terms_of_use
  end

  def conference_closed
  end

  def conference_full
  end

  def accept_offer
    if current_application_open? 
      redirect_to root_url
    end
  end

  def special_scholarship
  end 

end
