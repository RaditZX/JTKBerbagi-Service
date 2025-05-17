require 'rails_helper'

RSpec.describe "admins/show", type: :view do
  before(:each) do
    assign(:admin, Admin.create!(
      nama: "Nama",
      role: "Role",
      username: "Username",
      password: "Password",
      no_telepon: "No Telepon"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Nama/)
    expect(rendered).to match(/Role/)
    expect(rendered).to match(/Username/)
    expect(rendered).to match(/Password/)
    expect(rendered).to match(/No Telepon/)
  end
end
