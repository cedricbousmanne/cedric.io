class CreateFrancisCmsNotes < ActiveRecord::Migration
  def up
    create_table :francis_cms_notes do |t|
      t.text     :slug, null: false
      t.text     :body, null: false
      t.text     :excerpt
      t.datetime :published_at

      t.timestamps null: false
    end
  end

  def down
    drop_table :francis_cms_notes
  end
end