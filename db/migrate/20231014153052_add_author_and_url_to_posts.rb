class AddAuthorAndUrlToPosts < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :author, :string
    add_column :posts, :url, :string
  end
end
