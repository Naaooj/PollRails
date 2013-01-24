class HomeController < ApplicationController
  # Accueil de l'application
  def index
    # Définition du titre de la page
    @page_title = t("titles.home")
    
    @survey = Survey.find(:first)
    if not @survey.nil?
      @answers = Answer.find(:all, :conditions => ["survey_id = ?", @survey.survey_id])
      total_votes = 0
      @answers.each do |a|
        # Recherche de toutes les réponses enregistrées
        votes = Vote.find(:all, :conditions => ["answer_id = ?", a.answer_id])
        # Compteur de réponses à une question
        a.response_count = votes.size
        a.response_ratio = 0
        # Nombre total de votes
        total_votes += a.response_count
      end
      # Calcul des différents ratios
      if total_votes > 0
        @answers.each do |a|
          a.response_ratio = ((a.response_count.to_f / total_votes)*100).to_i
        end
      end
      @has_expired = false
      if (@survey.created_at + 8.days - Time.now).to_i < 0
        @has_expired = true
      end
    end
  end
  
  def random
    @survey = Survey.first(:order => "RANDOM()")
    respond_to do |format|
      format.html { redirect_to(@survey) }
      format.js
    end
  end
end

