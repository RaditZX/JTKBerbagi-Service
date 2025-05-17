require 'rails_helper'

RSpec.describe "penggalangan_danas/edit", type: :view do
  let(:penggalangan_dana) {
    PenggalanganDana.create!(
      title: "MyString",
      body: "MyText"
    )
  }

  before(:each) do
    assign(:penggalangan_dana, penggalangan_dana)
  end

  it "renders the edit penggalangan_dana form" do
    render

    assert_select "form[action=?][method=?]", penggalangan_dana_path(penggalangan_dana), "post" do

      assert_select "input[name=?]", "penggalangan_dana[title]"

      assert_select "textarea[name=?]", "penggalangan_dana[body]"
    end
  end
end
