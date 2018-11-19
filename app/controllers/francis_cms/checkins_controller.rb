require_dependency 'francis_cms/francis_cms_controller'

module FrancisCms
  class CheckinsController < FrancisCmsController
    before_action :require_login, except: [:index, :show]

    def index
      checkins
    end

    def show
      require_login unless checkin.published_at?
    end

    def new
      @checkin = Checkin.new
    end

    def create
      @checkin = Checkin.new(PostInput.new(params).to_h)

      @checkin.slug = nil if Checkin.where(slug: @checkin.slug).first

      if @checkin.save
        redirect_to @checkin, notice: t('flashes.checkins.create_notice')
      else
        render 'new'
      end
    end

    def edit
      checkin
    end

    def update
      if checkin.update_attributes(PostInput.new(params).to_h)
        redirect_to @checkin, notice: t('flashes.checkins.update_notice')
      else
        render 'edit'
      end
    end

    def destroy
      checkin.destroy

      redirect_to checkins_path, notice: t('flashes.checkins.destroy_notice')
    end

    private

    def checkins
      @checkins ||= Checkin.entries_for_page(include_drafts: __logged_in__, page: params['page'])
    end

    def checkin
      @checkin ||= Checkin.find(params[:id])
    end
  end
end