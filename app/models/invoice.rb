class Invoice < ApplicationRecord
  enum status: ["shipped"]
  
  belongs_to :customer
  belongs_to :merchant
  has_many :transactions
  has_many :invoice_items

  validates_presence_of :status,
                        :created_at,
                        :updated_at
end
