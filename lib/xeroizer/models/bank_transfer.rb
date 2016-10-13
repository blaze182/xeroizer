require 'xeroizer/models/attachment'

module Xeroizer
  module Record
    class BankTransferModel < BaseModel
      set_permissions :read

      include AttachmentModel::Extensions

    protected

      def parse_records(response, elements, paged_results)
        elements.each do | element |
          new_record = model_class.build_from_node(element, self)
          # BankTransfer endpoint fails to add ERROR status to nodes on batch save
          # From Xero side (it's beta atm).
          # if element.attribute('status').try(:value) == 'ERROR'
            element.xpath('.//ValidationError').each do |err|
              new_record.errors = [] if new_record.errors.nil?
              new_record.errors << err.text.gsub(/^\s+/, '').gsub(/\s+$/, '')
            end
          # end
          new_record.paged_record_downloaded = paged_results
          response.response_items << new_record
        end
      end
    end

    class BankTransfer < Base
      include Attachment::Extensions

      set_primary_key :bank_transfer_id

      decimal :amount

      datetime_utc_rw :date
      string :bank_transfer_id, :api_name => "BankTransferID"
      decimal :currency_rate
      string :from_bank_transaction_id, :api_name => "FromBankTransactionID"
      string :to_bank_transaction_id, :api_name => "ToBankTransactionID"

      validates_presence_of :from_bank_account, :to_bank_account, :amount

      belongs_to :from_bank_account, :model_name => 'FromBankAccount'
      belongs_to :to_bank_account, :model_name => 'ToBankAccount'
    end
  end
end