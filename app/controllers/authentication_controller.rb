class AuthenticationController < ApplicationController
    # Cette méthode est appelée lorsque l'authentification auprès du provider a réussi
    def create
      # On récupère les variables fournies par notre provider
      # Elle sont retournées en tant que tableau associatif à deux niveaux
      #
      # provider: google
      # uid: https://www.google.com/accounts/o8/id?id=un_grand_truc_de_barbare
      # user_info: 
      #   email: john.doe@gmail.com
      #   first_name: John
      #   last_name: Doe
      #   name: John Doe
      auth = request.env["omniauth.auth"]
      provider = auth["provider"]
      uid = auth["uid"]
      
      # Il faut vérifier si l'utilisateur a déjà un compte pour l'application ou non
      user = User.find_for_openid(provider, uid)
      # Si il est retrouvé, on peut enregistrer ces informations dans la session
      if user
        session[:user_id] = user.user_id
        redirect_to(root_url, :notice => 'Connecte!')
        return
      end
      # L'utilisateur n'est pas retrouvé, peut-être que l'uid a changé
      user = User.find(:first, :conditions => ["provider = ? and email = ?", provider, auth['user_info']['email'].to_s])
      if user
        # C'est bien ça, il faut mettre à jour les données de l'utilisateur
        user.uid = auth["uid"]
        user.save
        session[:user_id] = user.user_id
        redirect_to(root_url, :notice => 'Connecte!')
        return
      elsif
        # Sinon tout ce qu'on peut faire c'est lui proposer de valider la création d'un compte
        # on affiche donc un petit formulaire pour cela
        @page_title = t('titles.create_account')
        # On assigne à nos paramètres les informations retournées par OpenID
        params[:auth] = auth
      end
    end

    # Méthode utilisée pour enregistrer les informations de l'utilisateur dans la db
    def validate
      auth = {"username" => params["username"],
              "password" => '', 
              "email" => params["email"], 
              "provider" => params["provider"], 
              "uid" => params["uid"]}
      #render :text => auth.to_yaml
      user = User.create_with_omniauth(auth)
      session[:user_id] = user.user_id
      redirect_to(root_url, :notice => '')
    end
    
    def new
      # Définition du titre de la page
      @page_title = t("titles.create_account")
      
      # Création d'un nouveau utilisateur
      @user = User.new
      
      # Si il s'agit d'un get, construction du formulaire
      if request.get?
        # Création d'un utilisateur et bind avec le formulaire
      else
        # Récupération des données que l'utilisateur a entré
        suser = User.new(params[:user])
        # Validation des données saisies
        if suser.valid?
          # La validation a réussi, il est possible de persister l'utilisateur
          suser.username = suser.firstname + " " + suser.lastname
          suser.save
          # Définition du message à afficher à l'accueil
          flash[:notice] = t("account.created")
          # Redirection vers l'accueil
          redirect_to root_url
        elsif # Sinon réaffichage du formulaire 
          @user = suser
        end
      end
    end
    
    def login
      user = User.find(:first,
                       :conditions => ["email = ? and password = ?", params["user"]["login_email"], params["user"]["login_password"]])
      if user and user.provider.nil?
        session[:user_id] = user.user_id
        flash[:notice] = t("account.connected")
      elsif
        flash[:notice] = t("account.wrong_data")
      end
      redirect_to root_url
    end
    
    def destroy
      session[:user_id] = nil
      redirect_to(root_url, :notice => '')
    end
end
