require_dependency 'francis_cms/francis_cms_controller'

module FrancisCms
  class NotesController < FrancisCmsController
    before_action :require_login, except: [:index, :show]

    def index
      notes
    end

    def show
      require_login unless note.published_at?
    end

    def new
      @note = Note.new
    end

    def create
      @note = Note.new(PostInput.new(params).to_h)

      @note.slug = nil if Note.where(slug: @note.slug).first

      if @note.save
        redirect_to @note, notice: t('flashes.notes.create_notice')
      else
        render 'new'
      end
    end

    def edit
      note
    end

    def update
      if note.update_attributes(PostInput.new(params).to_h)
        redirect_to @note, notice: t('flashes.notes.update_notice')
      else
        render 'edit'
      end
    end

    def destroy
      note.destroy

      redirect_to notes_path, notice: t('flashes.notes.destroy_notice')
    end

    private

    def notes
      @notes ||= Note.entries_for_page(include_drafts: __logged_in__, page: params['page'])
    end

    def note
      @note ||= Note.find(params[:id])
    end
  end
end