require 'rails_helper'

RSpec.describe "penggalangan_danas/new", type: :view do
  before(:each) do
    assign(:penggalangan_dana, PenggalanganDana.new(
      title: "MyString",
      body: "MyText"
    ))
  end

  it "renders new penggalangan_dana form" do
    render

    assert_select "form[action=?][method=?]", penggalangan_danas_path, "post" do

      assert_select "input[name=?]", "penggalangan_dana[title]"

      assert_select "textarea[name=?]", "penggalangan_dana[body]"
    end
  end
end
