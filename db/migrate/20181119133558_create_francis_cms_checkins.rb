class CreateFrancisCmsCheckins < ActiveRecord::Migration
  def change
    create_table :francis_cms_checkins do |t|
      t.text     :slug, null: false
      t.text     :title, null: false
      t.text     :body, null: false
      t.decimal  :latitude, null: false, :precision=>10, :scale=>6
      t.decimal  :longitude, null: false, :precision=>10, :scale=>6
      t.datetime :published_at

      t.timestamps null: false
    end
  end
end
