require 'rails_helper'

RSpec.describe "penggalangan_danas/index", type: :view do
  before(:each) do
    assign(:penggalangan_danas, [
      PenggalanganDana.create!(
        title: "Title",
        body: "MyText"
      ),
      PenggalanganDana.create!(
        title: "Title",
        body: "MyText"
      )
    ])
  end

  it "renders a list of penggalangan_danas" do
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
    assert_select cell_selector, text: Regexp.new("Title".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("MyText".to_s), count: 2
  end
end
