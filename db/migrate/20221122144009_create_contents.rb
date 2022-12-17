class CreateContents < ActiveRecord::Migration[6.1]
  def change
    create_table :contents do |t|
      t.string :title
      t.string :content
      t.string :scope
      t.bigint :makeid
      t.bigint :updateid
      t.timestamps
    end
  end
end
