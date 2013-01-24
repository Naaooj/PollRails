class Survey < ActiveRecord::Base
  set_primary_key :survey_id
  has_many :answer
  
  # Permet d'avoir les sondage par ordre décroissant lors d'un select all
  default_scope order('survey_id DESC')
  
  # Données à valider
  validates :title, :description, :presence => true
  
  #validates :end_at,
  #          :presence => true,
  #          :format => { :with => /\d{2}\d{2}\d{4}/ }
  #/^[0-9]{4}[-][0-9]{2}[-][0-9]{2}$/
  
  @is_editable = true
  
  def is_editable
    return @is_editable
  end
  
  def is_editable=(editable)
    @is_editable = editable
  end
  
  protected
  
  # Surcharge de la méthode de validation du model
  #def validate
  #  if ((DateTime.parse(happened_at) rescue ArgumentError) == ArgumentError)
  #    errors.add(:end_at, "Date must be formatted DD/MM/YYYY")
  #  end
  #end
end
