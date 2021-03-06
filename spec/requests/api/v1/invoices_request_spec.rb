require 'rails_helper'

describe 'Invoice API' do
  context 'Record Endpoint' do
    it 'sends a list of invoices' do
      create_list(:invoice, 3)

      get '/api/v1/invoices.json'

      expect(response).to be_successful

      result = JSON.parse(response.body)

      expect(result["data"].count).to eq(3)
      expect(result["data"].first).to have_key("id")
      expect(result["data"].first["type"]).to eq("invoice")
    end

    it 'sends a single invoice' do
      i1 = create(:invoice)
      create_list(:invoice, 2)

      get "/api/v1/invoices/#{i1.id}.json"

      expect(response).to be_successful

      result = JSON.parse(response.body)

      expect(result["data"]["id"]).to eq(i1.id.to_s)
    end
  end

  context 'Single Finder' do
    it 'by ID' do
      create(:invoice)
      invoice_1 = create(:invoice)

      get "/api/v1/invoices/find?id=#{invoice_1.id}"

      result = JSON.parse(response.body)

      expect(result["data"]["id"]).to eq(invoice_1.id.to_s)
    end

    it 'by customer_id' do
      invoice_1 = create(:invoice)

      get "/api/v1/invoices/find?customer_id=#{invoice_1.customer_id}"

      result = JSON.parse(response.body)

      expect(result["data"]["attributes"]["customer_id"]).to eq(invoice_1.customer_id)
    end

    it 'by merchant_id' do
      invoice_1 = create(:invoice)

      get "/api/v1/invoices/find?merchant_id=#{invoice_1.merchant_id}"

      result = JSON.parse(response.body)

      expect(result["data"]["attributes"]["merchant_id"]).to eq(invoice_1.merchant_id)
    end

    it 'by status' do
      create(:item)
      invoice_1 = create(:invoice)

      get "/api/v1/invoices/find?status=#{invoice_1.status}"

      result = JSON.parse(response.body)

      expect(result["data"]["id"]).to eq(invoice_1.id.to_s)
    end

    it 'by created_at' do
      create(:invoice)
      invoice_1 = create(:invoice, created_at: "2012-03-27 14:53:59 UTC")

      get "/api/v1/invoices/find?created_at=#{invoice_1.created_at}"

      result = JSON.parse(response.body)

      expect(result["data"]["id"]).to eq(invoice_1.id.to_s)
    end

    it 'by updated_at' do
      create(:invoice)
      invoice_1 = create(:invoice, updated_at: "2012-03-27 14:53:59 UTC")

      get "/api/v1/invoices/find?updated_at=#{invoice_1.updated_at}"

      result = JSON.parse(response.body)

      expect(result["data"]["id"]).to eq(invoice_1.id.to_s)
    end
  end

  context 'Multi-Finders' do
    it 'by ID' do
      create(:invoice)
      invoice_1 = create(:invoice)

      get "/api/v1/invoices/find_all?id=#{invoice_1.id}"

      result = JSON.parse(response.body)

      expect(result["data"][0]["id"]).to eq(invoice_1.id.to_s)
    end

    it 'by customer_id' do
      customer = create(:customer)
      create(:invoice, customer: customer)
      create(:invoice, customer: customer)
      create(:invoice)

      get "/api/v1/invoices/find_all?customer_id=#{customer.id}"

      result = JSON.parse(response.body)

      expect(result["data"].count).to eq(2)

      expect(result["data"][0]["attributes"]["customer_id"]).to eq(customer.id)
      expect(result["data"][1]["attributes"]["customer_id"]).to eq(customer.id)
    end

    it 'by merchant_id' do
      merchant = create(:merchant)
      create(:invoice, merchant: merchant)
      create(:invoice, merchant: merchant)
      create(:invoice)

      get "/api/v1/invoices/find_all?merchant_id=#{merchant.id}"

      result = JSON.parse(response.body)

      expect(result["data"].count).to eq(2)

      expect(result["data"][0]["attributes"]["merchant_id"]).to eq(merchant.id)
      expect(result["data"][1]["attributes"]["merchant_id"]).to eq(merchant.id)
    end

    it 'by status' do
      status = 'shipped'
      create(:invoice, status: status)
      create(:invoice, status: status)

      get "/api/v1/invoices/find_all?status=#{status}"

      result = JSON.parse(response.body)

      expect(result["data"].count).to eq(2)
      expect(result["data"][0]["attributes"]["status"]).to eq(status)
      expect(result["data"][1]["attributes"]["status"]).to eq(status)
    end

    it 'by created_at' do
      created_at = "2012-03-27 14:53:59 UTC"
      i1 = create(:invoice, created_at: created_at)
      i2 = create(:invoice, created_at: created_at)
      create(:invoice)

      get "/api/v1/invoices/find_all?created_at=#{created_at}"

      result = JSON.parse(response.body)

      expect(result["data"].count).to eq(2)

      expect(result["data"][0]["attributes"]["customer_id"]).to eq(i1.customer.id)
      expect(result["data"][1]["attributes"]["customer_id"]).to eq(i2.customer.id)
    end

    it 'by updated_at' do
      updated_at = "2012-03-27 14:53:59 UTC"
      i1 = create(:invoice, updated_at: updated_at)
      i2 = create(:invoice, updated_at: updated_at)
      create(:invoice)

      get "/api/v1/invoices/find_all?updated_at=#{updated_at}"

      result = JSON.parse(response.body)

      expect(result["data"].count).to eq(2)

      expect(result["data"][0]["attributes"]["customer_id"]).to eq(i1.customer.id)
      expect(result["data"][1]["attributes"]["customer_id"]).to eq(i2.customer.id)
    end
  end

  context 'Random' do
    it 'resource' do
      invoice_1 = create(:invoice)
      invoice_2 = create(:invoice)

      get '/api/v1/invoices/random.json'

      result = JSON.parse(response.body)

      expect(result["data"]["id"]).to eq(invoice_1.id.to_s).or eq(invoice_2.id.to_s)
    end
  end

  context 'Relationships' do
    it 'returns a collection of associated transactions' do
      invoice_1 = create(:invoice)
      invoice_2 =create(:invoice)

      transaction_1 = create(:transaction, invoice: invoice_1)
      transaction_2 = create(:transaction, invoice: invoice_1)
      create(:transaction, invoice: invoice_2)

      get "/api/v1/invoices/#{invoice_1.id}/transactions"

      result = JSON.parse(response.body)

      expect(result["data"].count).to eq(2)
      expect(result["data"][0]["id"]).to eq(transaction_1.id.to_s).or eq(transaction_2.id.to_s)
      expect(result["data"][1]["id"]).to eq(transaction_1.id.to_s).or eq(transaction_2.id.to_s)
    end

    it 'returns a collection of associated invoice items' do
      invoice_1 = create(:invoice)
      invoice_2 =create(:invoice)

      ii1 = create(:invoice_item, invoice: invoice_1)
      ii2 = create(:invoice_item, invoice: invoice_1)
      create(:invoice_item, invoice: invoice_2)

      get "/api/v1/invoices/#{invoice_1.id}/invoice_items"

      result = JSON.parse(response.body)

      expect(result["data"].count).to eq(2)
      expect(result["data"][0]["id"]).to eq(ii1.id.to_s).or eq(ii2.id.to_s)
      expect(result["data"][1]["id"]).to eq(ii1.id.to_s).or eq(ii2.id.to_s)
    end

    it 'returns a collection of associated items' do
      invoice_1 = create(:invoice)
      invoice_2 = create(:invoice)

      i1 = create(:item)
      i2 = create(:item)
      i3 = create(:item)

      create(:invoice_item, invoice: invoice_1, item: i1)
      create(:invoice_item, invoice: invoice_1, item: i2)
      create(:invoice_item, invoice: invoice_2, item: i3)

      get "/api/v1/invoices/#{invoice_1.id}/items"

      result = JSON.parse(response.body)

      expect(result["data"].count).to eq(2)
      expect(result["data"][0]["id"]).to eq(i1.id.to_s).or eq(i2.id.to_s)
      expect(result["data"][1]["id"]).to eq(i1.id.to_s).or eq(i2.id.to_s)
    end

    it 'returns the associated customer' do
      c1 = create(:customer)
      c2 = create(:customer)

      create(:invoice, customer: c2)
      invoice_1 = create(:invoice, customer: c1)

      get "/api/v1/invoices/#{invoice_1.id}/customer"

      result = JSON.parse(response.body)

      expect(result["data"]["id"]).to eq(c1.id.to_s)
    end

    it 'returns the associated merchant' do
      m1 = create(:merchant)
      m2 = create(:merchant)

      create(:invoice, merchant: m2)
      invoice_1 = create(:invoice, merchant: m1)

      get "/api/v1/invoices/#{invoice_1.id}/merchant"

      result = JSON.parse(response.body)

      expect(result["data"]["id"]).to eq(m1.id.to_s)
    end
  end
end
