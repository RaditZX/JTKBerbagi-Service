require 'rails_helper'

RSpec.describe "admins/index", type: :view do
  before(:each) do
    assign(:admins, [
      Admin.create!(
        nama: "Nama",
        role: "Role",
        username: "Username",
        password: "Password",
        no_telepon: "No Telepon"
      ),
      Admin.create!(
        nama: "Nama",
        role: "Role",
        username: "Username",
        password: "Password",
        no_telepon: "No Telepon"
      )
    ])
  end

  it "renders a list of admins" do
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
    assert_select cell_selector, text: Regexp.new("Nama".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Role".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Username".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Password".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("No Telepon".to_s), count: 2
  end
end
