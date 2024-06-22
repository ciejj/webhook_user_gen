class CreateReceivedWebhooks < ActiveRecord::Migration[7.1]
  def change
    create_table :received_webhooks do |t|
      t.string :status, default: :pending
      t.text :payload

      t.timestamps
    end
  end
end
