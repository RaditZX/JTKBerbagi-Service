require 'rails_helper'

RSpec.describe "admins/edit", type: :view do
  let(:admin) {
    Admin.create!(
      nama: "MyString",
      role: "MyString",
      username: "MyString",
      password: "MyString",
      no_telepon: "MyString"
    )
  }

  before(:each) do
    assign(:admin, admin)
  end

  it "renders the edit admin form" do
    render

    assert_select "form[action=?][method=?]", admin_path(admin), "post" do

      assert_select "input[name=?]", "admin[nama]"

      assert_select "input[name=?]", "admin[role]"

      assert_select "input[name=?]", "admin[username]"

      assert_select "input[name=?]", "admin[password]"

      assert_select "input[name=?]", "admin[no_telepon]"
    end
  end
end
