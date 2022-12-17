class CreateTags < ActiveRecord::Migration[6.1]
  def change
    create_table :tags do |t|
      t.references :content, index: true, foreign_key: true
      t.string :tag
      t.bigint :makeid
      t.bigint :updateid
      t.timestamps
    end
  end
end
