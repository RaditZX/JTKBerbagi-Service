require "rails_helper"

RSpec.describe PenggalanganDanasController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/penggalangan_danas").to route_to("penggalangan_danas#index")
    end

    it "routes to #new" do
      expect(get: "/penggalangan_danas/new").to route_to("penggalangan_danas#new")
    end

    it "routes to #show" do
      expect(get: "/penggalangan_danas/1").to route_to("penggalangan_danas#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/penggalangan_danas/1/edit").to route_to("penggalangan_danas#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/penggalangan_danas").to route_to("penggalangan_danas#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/penggalangan_danas/1").to route_to("penggalangan_danas#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/penggalangan_danas/1").to route_to("penggalangan_danas#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/penggalangan_danas/1").to route_to("penggalangan_danas#destroy", id: "1")
    end
  end
end
