class SurveysController < ApplicationController
  # Affichage de la liste des sondages
  def index
    @surveys = Survey.all
    @page_title = t("titles.surveys")
    
    # Pour chaque sondage on recherche parmis les réponses si un vote existe
    @surveys.each do |s|
      @answers = Answer.find(:all, :conditions => ["survey_id = ?", s.survey_id])
      has_vote = false
      @answers.each do |a|
        # Recherche de toutes les votes pour la réponse
        votes = Vote.find(:all, :conditions => ["answer_id = ?", a.answer_id])
        if votes.size > 0
          has_vote = true
          break
        end
      end
      s.is_editable = !has_vote
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @surveys }
    end
  end

  # Affichage d'un sondage, de ses réponses et de ses votes
  def show
    @survey = Survey.find(params[:id])
    @nbr_of_answers = 0
    if not @survey.nil?
      @page_title = @survey.title
      @has_answered = false
      @answers = Answer.find(:all, :conditions => ["survey_id = ?", @survey.survey_id])
      total_votes = 0
      @answers.each do |a|
        # Recherche de toutes les réponses enregistrées
        votes = Vote.find(:all, :conditions => ["answer_id = ?", a.answer_id])
        # Conpteur de réponses à une question
        a.response_count = 0
        a.response_ratio = 0
        votes.each do |v|
          # Si l'utilisateur a déjà répondu, on change la valeur de notre flag
          if not current_user.nil? and v.user_id == current_user.user_id
            @has_answered = true
          end
          # On incrémente le compteur
          a.response_count = a.response_count + 1
          @nbr_of_answers += 1
        end
        # Nombre total de votes
        total_votes += a.response_count
      end
      # Calcul des différents ratios
      if total_votes > 0
        @answers.each do |a|
          a.response_ratio = ((a.response_count.to_f / total_votes)*100).to_i
        end
      end
      if current_user.nil?
        @has_answered = true
      end
      @has_expired = false
      if (@survey.created_at + 8.days - Time.now).to_i < 0
        @has_expired = true
      end
    end
  rescue
    respond_to do |format|
      format.html { redirect_to(surveys_url) }
      format.xml  { head :ok }
    end
  end

  # Validation du vote d'un utilisateur
  def vote
    @survey = Survey.find(params[:survey_id])
    vote = {"answer_id" => params[:vote].to_i,
            "user_id" => current_user.user_id}
    vote = Vote.new(vote)
    if vote.save
      respond_to do |format|
        format.html { redirect_to(@survey, :notice => t("notices.survey_thank")) }
      end
    else
      respond_to do |format|
        format.html { redirect_to(@survey, :notice => t("notices.vote_failed")) }
      end
    end
  end

  # Création d'un sondage : affichage du formulaire
  def new
    @page_title = t("titles.new")
    if not params[:survey].nil?
      @survey = params[:survey]
    else
      @survey = Survey.new
    end
    @nbr_of_answers = 0
  end

  # Edition d'un sondage
  def edit
    @survey = Survey.find(params[:id])
    @page_title = t("titles.edit")
    @nbr_of_answers = 0
    if not @survey.nil?
      load_answers(@survey.survey_id)
    end
    @has_error = false
  end

  # Méthode de validation et de sauvegarde d'un sondage 
  # si ce dernier respecte toutes les contraintes
  def create
    @page_title = t('titles.new')
    @survey = Survey.new(params[:survey])
    @survey.user_id = current_user.user_id
    # La sauvegarde du sondage a réussi, création des réponses
    respond_to do |format|
      # Si le formulaire est valide et contient des réponses
      if @survey.valid? and not params[:answers].nil?
        # Création d'un tableau qui va contenir toutes les réponses saisies
        @answers = Array.new
        # Flag sur la présence d'une erreur dans les réponses
        @has_error = false
        # Parcours des réponses saisies et création d'un objet du model
        params[:answers].each do |key, value|
          ans = Answer.new
          ans.answer = value
          # Validation du model
          if not ans.valid?
            @has_error = true
          end
          # Ajout de la réponse à notre tableau
          @answers << ans
        end
        # Est-ce que les réponses comportent des erreurs ?
        if @has_error
          # Il y a une erreur dans les réponses, il faut tout réafficher
          format.html { render :action => "new" }
          format.xml  { render :xml => @survey.errors, :status => :unprocessable_entity }
        else
          # Il n'y a pas d'erreur, la sauvegarde du sondage peut avoir lieu
          # Démarrage d'une transaction au niveau du sondage
          Survey.transaction do
            # Démarrage d'une transaction au niveau des réponses
            Answer.transaction do
              # Sauvegarde du sondage
              @survey.save
              # Sauvegarde de chaque réponse
              @answers.each do |a|
                # Le sondage sauvegardé, on peut ajouter la fk
                a.survey_id = @survey.survey_id
                a.save
              end
            end
          end
          format.html { redirect_to(@survey, :notice => t("notices.survey_created")) }
          format.xml  { render :xml => @survey, :status => :created, :location => @survey }
        end
      else
        # Le sondage n'est pas valide, est-ce que les questions le sont ou pas ?
        if not params[:answers].nil?
          # Création d'un tableau qui va contenir toutes les réponses saisies
          @answers = Array.new
          # Parcours des réponses saisies et création d'un objet du model
          params[:answers].each do |key, value|
            ans = Answer.new
            ans.survey_id = @survey.survey_id
            ans.answer = value
            # Validation du model
            ans.valid?
            # Ajout de la réponse à notre tableau
            @answers << ans
          end
          @nbr_of_answers = params[:answers].size
        end
        # Ajout d'une contrainte sur le nombre minimum de réponse
        if params[:answers].nil? or params[:answers].size < 2
          @survey.errors.add(:answer, t("surveys.two_ans_at_least"))
        end
        format.html { render :action => "new" }
        format.xml  { render :xml => @survey.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @survey = Survey.find(params[:id])
    @page_title = t("titles.edit")
    respond_to do |format|
      @nbr_of_answers = 0
      s = params[:survey]['title'].to_s
      if s.empty?
        @survey.title.clear
      else
        @survey.title = s
      end
      s = params[:survey]['description'].to_s
      if s.empty?
        @survey.description.clear
      else
        @survey.description = s
      end
      # Est-ce que le sondage est valide ?
      if @survey.valid?
        @has_error = false
        # Le sondage est valide, est-ce que les questions le sont également
        @answers = Array.new
        params[:answer].each do |key, value|
          ans = Answer.find(key.to_i)
          ans.answer = value
          if not ans.valid?
            @has_error = true
          end
          @answers << ans
        end
        # Si de nouvelles questions ont été ajoutées
        if not params[:answers].nil?
          params[:answers].each do |key, value|
            ans = Answer.new
            ans.survey_id = -1
            ans.answer = value
            if not ans.valid?
              @has_error = true
            end
            @answers << ans
          end  
        end
        if @has_error
          format.html { render :action => "edit" }
          format.xml  { render :xml => @survey.errors, :status => :unprocessable_entity }
        else
          Survey.transaction do
            Answer.transaction do
              @survey.save
              @answers.each do |a|
                if a.survey_id == -1
                  a.survey_id = @survey.survey_id
                end
                a.save
              end
            end
          end
          format.html { redirect_to(@survey, :notice => t("notices.survey_updated")) }
          format.xml  { head :ok }
        end
      else
        load_answers(@survey.survey_id, params[:answers])
        format.html { render :action => "edit" }
        format.xml  { render :xml => @survey.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @survey = Survey.find(params[:id])
    # Vérification que le sondage appartient bien au bon utilisateur
    if @survey.user_id == current_user.user_id
      answers = Answer.find(:all, :conditions => ["survey_id = ?", @survey.survey_id])
      answers.each do |a|
        votes = Vote.find(:all, :conditions => ["answer_id = ?", a.answer_id])
        votes.each do |v|
          v.destroy
        end
        a.destroy
      end
      @survey.destroy
    end

    redirect_to_home
  rescue
    redirect_to_home
  end
  
  private
  
  def redirect_to_home
    respond_to do |format|
      format.html { redirect_to(surveys_url) }
      format.xml  { head :ok }
    end
  end
  
  def load_answers(survey_id, new_ans=nil)
    @answers = Answer.find(:all, :conditions => ["survey_id = ?", survey_id])
    @answers.each do |a|
      @nbr_of_answers += Vote.count(:conditions => ["answer_id = ?", a.answer_id])
    end
    if not new_ans.nil?
      new_ans.each do |key, value|
        ans = Answer.new
        ans.survey_id = -1
        ans.answer = value
        if not ans.valid?
          @has_error = true
        end
        @answers << ans
      end
    end
  end
end
