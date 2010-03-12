class House < ActiveRecord::Base
  belongs_to :project
  belongs_to :contact
  
  before_destroy :clear_associations
  
  validates_presence_of :house_number, :message => "is required"
  # Return a list of houses that belong to the
  # particular project given
  def houses_for(project)
    
  end
  
  def volunteers_assigned
    Volunteer.count_by_sql("select count(*) from volunteers where house_id = #{self.id}")
  end

  def address
    a = [:address_1, :address_2].inject("") do |addr, f| 
      if contact[f].blank? 
        addr
      elsif ! addr.blank?
        addr + ", " + contact[f]
      else
        contact[f]
      end
    end
    
    a = [:city, :state].inject(a) do |addr, f|
      if contact[f].blank?
        addr
      elsif ! addr.blank?
        addr + ", " + contact[f]
      else
        contact[f]
      end
    end

    if a.blank?
      contact[:zip]
    else
      a + " " + contact[:zip]
    end
  end
  
  def clear_associations
    Volunteer.update_all("house_id = null","house_id = #{self.id}")
    House.connection.execute("delete from house_skills where house_id = #{self.id}")
  end
end
