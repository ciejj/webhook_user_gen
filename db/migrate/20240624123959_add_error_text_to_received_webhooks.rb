class AddErrorTextToReceivedWebhooks < ActiveRecord::Migration[7.1]
  def change
    add_column :received_webhooks, :error, :text
  end
end
