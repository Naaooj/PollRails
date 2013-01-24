class Answer < ActiveRecord::Base
  set_primary_key :answer_id
  belongs_to :survey
  
  validates :answer, :presence => true
  
  @response_count = 0
  @response_ratio = 0
  
  def response_count
    return @response_count
  end
  
  def response_count=(count)
    @response_count = count
  end
  
  def response_ratio
    return @response_ratio
  end
  
  def response_ratio=(ratio)
    @response_ratio = ratio
  end
end
