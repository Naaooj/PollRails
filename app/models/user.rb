class User < ActiveRecord::Base
  

  validates :lastname, :firstname, :password, :password_check, 
            :presence => true,
            :if => Proc.new { |user| user.provider.nil? }
  
  validates :email,   
            :presence => true,   
            :uniqueness => true,   
            :format => { :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i }
   
  # ActiveRecord est tellement intelligent qu'il est même 
  # pas foutu de trouver la clé primaire de la table
  # et c'est pour ça qu'il faut la lui spécifier...
  # J'ai pourtant lu dans de la doc qu'il était capable
  # de trouver une clé si elle s'appelait id ou nom_de_la_table_au_singulier_id
  set_primary_key :user_id
  
  @lastname = nil
  @firstname = nil
  @password_check = nil
  
  # A noter qu'il est possible de donner le nom de la table si il diffère
  # du nom de cette classe, par exemple :
  # set_table_name :the_sexy_table_name
  
  # Création d'un nouvel utilisateur authentifié via OpenId
  def self.create_with_omniauth(auth)
    create! do |user|
      user.username = auth["username"]
      user.password = auth["password"]
      user.email = auth["email"]
      user.provider = auth["provider"]
      user.uid = auth["uid"]
    end
  end
  
  # Retourne un utilisateur à partir de son provider et de son uid
  def self.find_for_openid(provider, uid)
    # find est une méthode d'ActiveRecord, le symbole :first indique qu'elle s'arrête au premier trouvé
    # le symbole :conditions décrit une partie de la clause where
    # enfin des [] sont utilisés dans la condition pour substituer les ?
    # par les valeurs données. Veiller a bien utiliser des doubles quotes,
    # car aucun traitement de substitution n'est fait sur les quotes simples
    find(:first, 
         :conditions => ["provider = ? and uid = ?", provider, uid])
  end
  
  def lastname
    return @lastname || nil
  end
  
  def lastname=(last)
    @lastname = last
  end
  
  def firstname
    return @firstname || nil
  end
  
  def firstname=(first)
    @firstname = first
  end
  
  def password_check
    return @password_check || nil
  end
  
  def password_check=(check)
    @password_check = check
  end
  
  protected
  
  # Surcharge de la méthode de validation du model
  def validate
    if provider.nil? and password != password_check
      errors.add(:password_check, I18n.t("activerecord.errors.models.user.attributes.password_check.different"))
    end 
  end
end
