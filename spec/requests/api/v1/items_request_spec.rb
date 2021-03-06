require 'rails_helper'

describe 'Item API' do
  context 'Record Endpoint' do
    it 'sends a list of items' do
      create_list(:item, 3)

      get '/api/v1/items.json'

      expect(response).to be_successful

      items = JSON.parse(response.body)

      expect(items["data"].count).to eq(3)
      expect(items["data"].first).to have_key("id")
      expect(items["data"].first["type"]).to eq("item")
    end

    it 'sends a single item' do
      i1 = create(:item)
      create_list(:item, 2)

      get "/api/v1/items/#{i1.id}.json"

      expect(response).to be_successful

      items = JSON.parse(response.body)

      expect(items["data"]["id"]).to eq(i1.id.to_s)
    end
  end

  context 'Single Finder' do
    it 'by ID' do
      create(:item)
      item_1 = create(:item)

      get "/api/v1/items/find?id=#{item_1.id}"

      result = JSON.parse(response.body)

      expect(result["data"]["id"]).to eq(item_1.id.to_s)
    end

    it 'by name' do
      item_1 = create(:item)

      get "/api/v1/items/find?name=#{item_1.name}"

      result = JSON.parse(response.body)

      expect(result["data"]["attributes"]["name"]).to eq(item_1.name)
    end

    it 'by description' do
      item_1 = create(:item)

      get "/api/v1/items/find?description=#{item_1.description}"

      result = JSON.parse(response.body)

      expect(result["data"]["attributes"]["description"]).to eq(item_1.description)
    end

    it 'by unit_price' do
      create(:item)
      item_1 = create(:item)

      get "/api/v1/items/find?unit_price=#{item_1.unit_price}"

      result = JSON.parse(response.body)

      expect(result["data"]["id"]).to eq(item_1.id.to_s)
    end

    it 'by merchant_id' do
      create(:item)
      item_1 = create(:item)

      get "/api/v1/items/find?merchant_id=#{item_1.merchant_id}"

      result = JSON.parse(response.body)

      expect(result["data"]["id"]).to eq(item_1.id.to_s)
    end

    it 'by created_at' do
      create(:item)
      item_1 = create(:item, created_at: "2012-03-27 14:53:59 UTC")

      get "/api/v1/items/find?created_at=#{item_1.created_at}"

      result = JSON.parse(response.body)

      expect(result["data"]["id"]).to eq(item_1.id.to_s)
    end

    it 'by updated_at' do
      create(:item)
      item_1 = create(:item, updated_at: "2012-03-27 14:53:59 UTC")

      get "/api/v1/items/find?updated_at=#{item_1.updated_at}"

      result = JSON.parse(response.body)

      expect(result["data"]["id"]).to eq(item_1.id.to_s)
    end
  end

  context 'Multi-Finders' do
    it 'by ID' do
      create(:item)
      item_1 = create(:item)

      get "/api/v1/items/find_all?id=#{item_1.id}"

      result = JSON.parse(response.body)

      expect(result["data"][0]["id"]).to eq(item_1.id.to_s)
    end

    it 'by name' do
      name = 'generic'
      create(:item, name: name)
      create(:item, name: name)
      create(:item)

      get "/api/v1/items/find_all?name=#{name}"

      result = JSON.parse(response.body)

      expect(result["data"].count).to eq(2)
      expect(result["data"][0]["attributes"]["name"]).to eq(name)
      expect(result["data"][1]["attributes"]["name"]).to eq(name)
    end

    it 'by description' do
      description = 'generic'
      create(:item, description: description)
      create(:item, description: description)
      create(:item)

      get "/api/v1/items/find_all?description=#{description}"

      result = JSON.parse(response.body)

      expect(result["data"].count).to eq(2)
      expect(result["data"][0]["attributes"]["description"]).to eq(description)
      expect(result["data"][1]["attributes"]["description"]).to eq(description)
    end

    xit 'by unit_price' do
      unit_price = '10292'
      create(:item, unit_price: unit_price)
      create(:item, unit_price: unit_price)
      create(:item)

      get "/api/v1/items/find_all?unit_price=#{unit_price}"

      result = JSON.parse(response.body)

      expect(result["data"].count).to eq(2)

      expect(result["data"][0]["attributes"]["unit_price"]).to eq(unit_price)
      expect(result["data"][1]["attributes"]["unit_price"]).to eq(unit_price)
    end

    xit 'by created_at' do
      created_at = "2012-03-27 14:53:59 UTC"
      create(:item, created_at: created_at)
      create(:item, created_at: created_at)
      create(:item)

      get "/api/v1/items/find_all?created_at=#{created_at}"

      result = JSON.parse(response.body)

      expect(result["data"].count).to eq(2)

      expect(result["data"][0]["attributes"]["created_at"]).to eq(created_at)
      expect(result["data"][1]["attributes"]["created_at"]).to eq(created_at)
    end

    xit 'by updated_at' do
      updated_at = "2012-03-27 14:53:59 UTC"
      create(:item, updated_at: updated_at)
      create(:item, updated_at: updated_at)
      create(:item)

      get "/api/v1/items/find_all?updated_at=#{updated_at}"

      result = JSON.parse(response.body)

      expect(result["data"].count).to eq(2)
      expect(result["data"][0]["attributes"]["updated_at"]).to eq(updated_at)
      expect(result["data"][1]["attributes"]["updated_at"]).to eq(updated_at)
    end
  end

  context 'Random' do
    it 'resource' do
      item_1 = create(:item)
      item_2 = create(:item)

      get '/api/v1/items/random.json'

      result = JSON.parse(response.body)
      expect(result["data"]["id"]).to eq(item_1.id.to_s).or eq(item_2.id.to_s)
    end
  end

  context 'Relationships' do
    it 'returns a collection of associated invoice items' do
      create(:item)
      item_1 = create(:item)

      invoice_item_1 = create(:invoice_item, item: item_1)
      invoice_item_2 = create(:invoice_item, item: item_1)

      get "/api/v1/items/#{item_1.id}/invoice_items"

      result = JSON.parse(response.body)

      expect(result["data"].count).to eq(2)
      expect(result["data"][0]["id"]).to eq(invoice_item_1.id.to_s).or eq(invoice_item_2.id.to_s)
      expect(result["data"][1]["id"]).to eq(invoice_item_1.id.to_s).or eq(invoice_item_2.id.to_s)
    end
    it 'returns the associated merchant' do
      m1 = create(:merchant)
      item_1 = create(:item, merchant: m1)
      create(:invoice, merchant: m1)

      get "/api/v1/items/#{item_1.id}/merchant"

      result = JSON.parse(response.body)

      expect(result["data"]["id"]).to eq(m1.id.to_s)
    end
  end

  context 'Business Intelligence' do
    it 'returns the top x items ranked by total revenue generated' do
      item_1 = create(:item)
      item_2 = create(:item)
      item_3 = create(:item)

      invoice_1 = create(:invoice)

      create(:invoice_item, item: item_1, invoice: invoice_1, unit_price: 100, quantity: 2)
      create(:invoice_item, item: item_1, invoice: invoice_1, unit_price: 100, quantity: 2)
      create(:invoice_item, item: item_2, invoice: invoice_1, unit_price: 100, quantity: 2)
      create(:invoice_item, item: item_3, invoice: invoice_1, unit_price: 1, quantity: 2)

      create(:transaction, result: "failed", invoice: invoice_1)
      create(:transaction, result: "success", invoice: invoice_1)

      get "/api/v1/items/most_revenue?quantity=2"

      result = JSON.parse(response.body)

      expect(result["data"].count).to eq(2)
      expect(result["data"][0]["id"]).to eq(item_1.id.to_s)
      expect(result["data"][1]["id"]).to eq(item_2.id.to_s)
    end

    it 'returns the top x item instances ranked by total number sold' do
      item_1 = create(:item)
      item_2 = create(:item)
      item_3 = create(:item)

      invoice_1 = create(:invoice)

      create(:invoice_item, item: item_1, invoice: invoice_1, unit_price: 100, quantity: 2)
      create(:invoice_item, item: item_1, invoice: invoice_1, unit_price: 100, quantity: 2)
      create(:invoice_item, item: item_2, invoice: invoice_1, unit_price: 100, quantity: 2)
      create(:invoice_item, item: item_3, invoice: invoice_1, unit_price: 1, quantity: 2)

      create(:transaction, result: "failed", invoice: invoice_1)
      create(:transaction, result: "success", invoice: invoice_1)

      get '/api/v1/items/most_items?quantity=2'

      result = JSON.parse(response.body)

      expect(result["data"].count).to eq(2)
      expect(result["data"][0]["id"]).to eq(item_1.id.to_s)
      expect(result["data"][1]["id"]).to eq(item_2.id.to_s)
    end

    xit 'returns the date with the most sales for the given item using the invoice date. If there are multiple days with equal number of sales, return the most recent day' do
      get "/api/v1/items/#{item_1.id}/best_day"
    end
  end
end
