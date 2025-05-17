require 'rails_helper'

RSpec.describe "admins/new", type: :view do
  before(:each) do
    assign(:admin, Admin.new(
      nama: "MyString",
      role: "MyString",
      username: "MyString",
      password: "MyString",
      no_telepon: "MyString"
    ))
  end

  it "renders new admin form" do
    render

    assert_select "form[action=?][method=?]", admins_path, "post" do

      assert_select "input[name=?]", "admin[nama]"

      assert_select "input[name=?]", "admin[role]"

      assert_select "input[name=?]", "admin[username]"

      assert_select "input[name=?]", "admin[password]"

      assert_select "input[name=?]", "admin[no_telepon]"
    end
  end
end
