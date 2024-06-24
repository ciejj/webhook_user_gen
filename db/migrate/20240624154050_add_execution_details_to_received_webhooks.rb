class AddExecutionDetailsToReceivedWebhooks < ActiveRecord::Migration[7.1]
  def change
    add_column :received_webhooks, :execution_details, :text
  end
end
